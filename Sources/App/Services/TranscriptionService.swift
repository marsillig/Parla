import Foundation
import WhisperKit

enum TranscriptionError: Error, LocalizedError {
    case modelNotLoaded
    case transcriptionFailed(String)
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded: return "Il modello vocale non è stato caricato"
        case .transcriptionFailed(let msg): return "Trascrizione fallita: \(msg)"
        case .permissionDenied: return "Permesso microfono negato"
        }
    }
}

@Observable
@MainActor
final class TranscriptionService {
    private var whisperKit: WhisperKit?
    private(set) var isLoaded = false
    private(set) var isLoading = false

    func loadModel() async throws {
        guard !isLoaded else { return }
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        whisperKit = try await WhisperKit(
            model: "base",
            verbose: false,
            prewarm: true,
            load: true,
            download: true
        )
        isLoaded = true
    }

    func transcribe(audioURL: URL) async throws -> String {
        guard let whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }

        let decodeOptions = DecodingOptions(
            verbose: false,
            task: .transcribe,
            language: "it",
            temperature: 0.0,
            skipSpecialTokens: true,
            withoutTimestamps: true
        )

        let results = try await whisperKit.transcribe(
            audioPath: audioURL.path,
            decodeOptions: decodeOptions
        )

        guard let text = results.first?.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TranscriptionError.transcriptionFailed("Nessun testo riconosciuto")
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
