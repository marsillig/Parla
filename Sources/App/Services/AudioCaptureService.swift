import AVFoundation
import Foundation

enum AudioCaptureError: LocalizedError {
    case recordingDidNotStart

    var errorDescription: String? {
        "Impossibile avviare la registrazione. Controlla il microfono nelle Impostazioni di Sistema."
    }
}

@Observable
@MainActor
final class AudioCaptureService {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var levelTimer: Timer?
    private(set) var isRecording = false
    private(set) var audioLevel: Float = 0

    func startRecording() throws {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("parla_recording_\(UUID().uuidString).m4a")
        recordingURL = fileURL

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        guard audioRecorder?.record() == true else {
            audioRecorder = nil
            recordingURL = nil
            try? FileManager.default.removeItem(at: fileURL)
            throw AudioCaptureError.recordingDidNotStart
        }

        isRecording = true
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self, self.isRecording else {
                    timer.invalidate()
                    return
                }
                self.audioRecorder?.updateMeters()
                self.audioLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0
            }
        }
    }

    func stopRecording() -> URL? {
        let duration = audioRecorder?.currentTime ?? 0
        audioRecorder?.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        isRecording = false
        audioLevel = 0
        guard duration >= 0.5 else {
            if let recordingURL {
                try? FileManager.default.removeItem(at: recordingURL)
            }
            recordingURL = nil
            audioRecorder = nil
            return nil
        }
        return recordingURL
    }

    func cancelRecording() {
        audioRecorder?.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        isRecording = false
        audioLevel = 0
        if let recordingURL {
            try? FileManager.default.removeItem(at: recordingURL)
        }
        recordingURL = nil
        audioRecorder = nil
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
