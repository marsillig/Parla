import Foundation

@Observable
final class PhraseStore {
    private(set) var allPhrases: [Phrase] = []

    init() {
        loadPhrases()
    }

    private func loadPhrases() {
        let url = Bundle.module.url(forResource: "phrases", withExtension: "json")
            ?? Bundle.main.url(forResource: "phrases", withExtension: "json")
        guard let url,
              let data = try? Data(contentsOf: url),
              let phrases = try? JSONDecoder().decode([Phrase].self, from: data)
        else {
            assertionFailure("Failed to load phrases.json")
            allPhrases = []
            return
        }
        var seenItalian: Set<String> = []
        allPhrases = phrases.filter { seenItalian.insert($0.italian).inserted }
    }

    func phrases(for difficulty: Difficulty? = nil, topic: Topic? = nil) -> [Phrase] {
        var filtered = allPhrases
        if let d = difficulty {
            filtered = filtered.filter { $0.difficulty == d }
        }
        if let t = topic {
            filtered = filtered.filter { $0.topic == t }
        }
        return filtered
    }

    func randomPhrases(count: Int, difficulty: Difficulty? = nil, topic: Topic? = nil) -> [Phrase] {
        let pool = phrases(for: difficulty, topic: topic)
        guard !pool.isEmpty else { return [] }
        return Array(pool.shuffled().prefix(count))
    }

    var allTopics: [Topic] {
        Array(Set(allPhrases.map(\.topic))).sorted { $0.label < $1.label }
    }
}
