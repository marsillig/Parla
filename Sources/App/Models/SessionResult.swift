import Foundation

struct WordError: Codable, Identifiable, Equatable {
    let id = UUID()
    let word: String
    let correctWord: String
    let count: Int

    enum CodingKeys: String, CodingKey {
        case word, correctWord, count
    }
}

struct SessionResult: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let mode: ExerciseMode
    let phraseIds: [Int]
    let wordErrors: [WordError]
    let accuracy: Double

    init(mode: ExerciseMode, phraseIds: [Int], wordErrors: [WordError], accuracy: Double) {
        self.id = UUID()
        self.date = Date()
        self.mode = mode
        self.phraseIds = phraseIds
        self.wordErrors = wordErrors
        self.accuracy = accuracy
    }
}

struct PhraseResult: Codable, Equatable {
    let phrase: Phrase
    let userAnswer: String
    let wordResults: [WordResult]
    let isCorrect: Bool
    let accuracy: Double
}

struct WordResult: Codable, Equatable, Identifiable {
    let id = UUID()
    let word: String
    let expectedWord: String?
    let status: WordStatus

    enum CodingKeys: String, CodingKey {
        case word, expectedWord, status
    }
}

enum WordStatus: String, Codable, Equatable, Sendable {
    case correct
    case incorrect
    case missing
    case extra
}
