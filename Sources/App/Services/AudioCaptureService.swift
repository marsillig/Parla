import AVFoundation
import CoreAudio
import Foundation

struct MicDevice: Identifiable, Equatable {
    let id: String
    let name: String
}

@Observable
final class AudioCaptureService: @unchecked Sendable {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var levelTimer: Timer?
    private(set) var isRecording = false
    private(set) var audioLevel: Float = 0
    private var originalDefaultDevice: AudioDeviceID = 0

    var recordingAvailable: Bool {
        recordingURL != nil
    }

    static func availableInputDevices() -> [MicDevice] {
        guard let devices = allAudioDeviceIDs() else { return [] }
        var result: [MicDevice] = []
        for deviceID in devices {
            guard deviceHasInput(deviceID),
                  let name = deviceName(deviceID),
                  let uid = deviceUID(deviceID)
            else { continue }
            result.append(MicDevice(id: uid, name: name))
        }
        return result
    }

    func selectInputDevice(uid: String) {
        guard let deviceID = deviceID(for: uid) else { return }
        setDefaultInputDevice(deviceID)
    }

    func startRecording() throws {
        if let uid = UserDefaults.standard.string(forKey: "selectedMicUID"), !uid.isEmpty {
            selectInputDevice(uid: uid)
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("parla_recording_\(UUID().uuidString).m4a")
        recordingURL = fileURL

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        isRecording = true

        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, self.isRecording else {
                timer.invalidate()
                return
            }
            self.audioRecorder?.updateMeters()
            self.audioLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0
        }
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        isRecording = false
        audioLevel = 0
        return recordingURL
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - CoreAudio Helpers

    private static func allAudioDeviceIDs() -> [AudioDeviceID]? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &dataSize
        ) == noErr else { return nil }
        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var devices = [AudioDeviceID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &dataSize,
            &devices
        ) == noErr else { return nil }
        return devices
    }

    private static func deviceHasInput(_ id: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(id, &propertyAddress, 0, nil, &dataSize) == noErr else {
            return false
        }
        return dataSize > 0
    }

    private static func deviceName(_ id: AudioDeviceID) -> String? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var name: CFString?
        var size = UInt32(MemoryLayout<CFString?>.size)
        guard AudioObjectGetPropertyData(id, &propertyAddress, 0, nil, &size, &name) == noErr,
              let name else { return nil }
        return name as String
    }

    private static func deviceUID(_ id: AudioDeviceID) -> String? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var uid: CFString?
        var size = UInt32(MemoryLayout<CFString?>.size)
        guard AudioObjectGetPropertyData(id, &propertyAddress, 0, nil, &size, &uid) == noErr,
              let uid else { return nil }
        return uid as String
    }

    private static func currentDefaultInputDeviceID() -> AudioDeviceID? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID: AudioDeviceID = 0
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &size,
            &deviceID
        ) == noErr, deviceID > 0 else { return nil }
        return deviceID
    }

    private func deviceID(for uid: String) -> AudioDeviceID? {
        guard let devices = Self.allAudioDeviceIDs() else { return nil }
        for deviceID in devices {
            if Self.deviceUID(deviceID) == uid {
                return deviceID
            }
        }
        return nil
    }

    private func setDefaultInputDevice(_ id: AudioDeviceID) {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = id
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &deviceID
        )
    }
}
