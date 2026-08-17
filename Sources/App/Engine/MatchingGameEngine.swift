import Foundation

@Observable
@MainActor
final class MatchingGameEngine {
    private let items: [MatchGameItem]

    private(set) var rounds: [MatchGameRound] = []
    private(set) var currentIndex = 0
    private(set) var score = 0
    private(set) var selectedWord: String?
    private(set) var isAnswered = false
    private(set) var isFinished = false

    var currentRound: MatchGameRound? {
        guard !isFinished, currentIndex < rounds.count else { return nil }
        return rounds[currentIndex]
    }

    init(items: [MatchGameItem] = MatchGameCatalog.items) {
        self.items = items
    }

    func start(roundCount: Int? = nil) {
        let shuffledItems = items.shuffled()
        let selectedItems = roundCount.map { Array(shuffledItems.prefix($0)) } ?? shuffledItems
        rounds = selectedItems.map { item in
            let sameCategoryItems = items.filter {
                $0.category == item.category && $0.id != item.id
            }
            let distractorPool = sameCategoryItems.count >= 4
                ? sameCategoryItems
                : items.filter { $0.id != item.id }
            let distractors = distractorPool
                .shuffled()
                .prefix(4)
                .map(\.italian)
            return MatchGameRound(
                item: item,
                choices: ([item.italian] + distractors).shuffled()
            )
        }
        currentIndex = 0
        score = 0
        selectedWord = nil
        isAnswered = false
        isFinished = rounds.isEmpty
    }

    @discardableResult
    func submit(_ word: String) -> Bool {
        guard !isAnswered, let currentRound else { return false }
        selectedWord = word
        isAnswered = true
        let isCorrect = word == currentRound.item.italian
        if isCorrect {
            score += 1
        }
        return isCorrect
    }

    func next() {
        guard isAnswered else { return }
        if currentIndex < rounds.count - 1 {
            currentIndex += 1
            selectedWord = nil
            isAnswered = false
        } else {
            currentIndex = rounds.count
            isFinished = true
        }
    }
}
