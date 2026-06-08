import Foundation

@Observable
final class SessionEngine {
    private let phraseStore: PhraseStore
    private let progressStore: ProgressStore

    var allTopics: [Topic] {
        phraseStore.allTopics
    }

    var mode: ExerciseMode = .dictation
    var phrases: [Phrase] = []
    var currentIndex: Int = 0
    var currentPhrase: Phrase? { currentIndex < phrases.count ? phrases[currentIndex] : nil }
    var phraseResults: [PhraseResult] = []
    var isFinished: Bool = false
    var isSessionActive: Bool = false
    var selectedDifficulty: Difficulty?
    var selectedTopic: Topic?
    var sessionCount: Int = 10

    init(phraseStore: PhraseStore = PhraseStore(), progressStore: ProgressStore = ProgressStore()) {
        self.phraseStore = phraseStore
        self.progressStore = progressStore
    }

    func startSession(count: Int = 10, difficulty: Difficulty? = nil, topic: Topic? = nil, mode: ExerciseMode = .dictation) {
        self.mode = mode
        self.sessionCount = count
        self.selectedDifficulty = difficulty
        self.selectedTopic = topic
        phrases = phraseStore.randomPhrases(count: count, difficulty: difficulty, topic: topic)
        currentIndex = 0
        phraseResults = []
        isFinished = false
        isSessionActive = !phrases.isEmpty
    }

    func submitAnswer(_ answer: String) {
        guard let phrase = currentPhrase else { return }

        let alignment = WordAligner.align(expected: phrase.italian, actual: answer)
        let correctCount = alignment.filter { $0.status == .correct }.count
        let totalCount = alignment.count
        let accuracy = totalCount > 0 ? Double(correctCount) / Double(totalCount) : 0

        let wordResults = alignment.map { aligned in
            WordResult(word: aligned.word, status: aligned.status)
        }

        let result = PhraseResult(
            phrase: phrase,
            userAnswer: answer,
            wordResults: wordResults,
            isCorrect: accuracy == 1.0,
            accuracy: accuracy
        )

        phraseResults.append(result)
    }

    func retryCurrent() {
        if !phraseResults.isEmpty {
            phraseResults.removeLast()
        }
    }

    func nextPhrase() {
        if currentIndex < phrases.count - 1 {
            currentIndex += 1
        } else {
            isFinished = true
            isSessionActive = false
            saveResult()
        }
    }

    var overallAccuracy: Double {
        guard !phraseResults.isEmpty else { return 0 }
        return phraseResults.map(\.accuracy).reduce(0, +) / Double(phraseResults.count)
    }

    var allWordErrors: [WordError] {
        var errors: [String: (correct: String, count: Int)] = [:]
        for result in phraseResults {
            for wordResult in result.wordResults where wordResult.status == .incorrect {
                let expectedWords = result.phrase.italian.lowercased()
                    .trimmingCharacters(in: .punctuationCharacters)
                    .components(separatedBy: .whitespaces)
                if let index = result.wordResults.firstIndex(where: { $0.id == wordResult.id }),
                   index < expectedWords.count {
                    let correct = expectedWords[index]
                    errors[wordResult.word, default: (correct, 0)].count += 1
                }
            }
        }
        return errors.map { WordError(word: $0.key, correctWord: $0.value.correct, count: $0.value.count) }
    }

    private func saveResult() {
        let result = SessionResult(
            mode: mode,
            phraseIds: phrases.map(\.id),
            wordErrors: allWordErrors,
            accuracy: overallAccuracy
        )
        progressStore.save(result: result)
    }
}
