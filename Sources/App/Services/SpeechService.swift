import AVFoundation
import Foundation

@Observable
@MainActor
final class SpeechService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private(set) var isSpeaking = false

    private static var bestVoice: AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let italianVoices = allVoices.filter { $0.language == "it-IT" }

        if let premium = italianVoices.first(where: { $0.quality == .premium }) {
            return premium
        }
        if let alice = italianVoices.first(where: { $0.identifier == "com.apple.voice.compact.it-IT.Alice" }) {
            return alice
        }
        return italianVoices.first ?? AVSpeechSynthesisVoice(language: "it-IT")
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, rate: Float = 0.5) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.bestVoice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.35
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

extension SpeechService: @preconcurrency AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
