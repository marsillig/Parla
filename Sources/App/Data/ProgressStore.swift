import Foundation

@Observable
final class ProgressStore {
    private(set) var results: [SessionResult] = []
    private(set) var completedPhraseIds: Set<Int> = []

    private let defaults = UserDefaults.standard
    private let resultsKey = "parla_session_results"
    private let completedKey = "parla_completed_phrases"

    init() {
        load()
    }

    func save(result: SessionResult) {
        results.append(result)
        persistResults()
    }

    func markPhraseCompleted(id: Int) {
        completedPhraseIds.insert(id)
        persistCompleted()
    }

    func isPhraseCompleted(id: Int) -> Bool {
        completedPhraseIds.contains(id)
    }

    func resetCompleted() {
        completedPhraseIds = []
        persistCompleted()
    }

    var completedCount: Int {
        completedPhraseIds.count
    }

    func recentResults(limit: Int = 20) -> [SessionResult] {
        results.sorted(by: { $0.date > $1.date }).prefix(limit).map { $0 }
    }

    var overallAccuracy: Double {
        guard !results.isEmpty else { return 0 }
        return results.map(\.accuracy).reduce(0, +) / Double(results.count)
    }

    var frequentErrors: [(String, Int)] {
        var counts: [String: Int] = [:]
        for result in results {
            for error in result.wordErrors {
                counts[error.correctWord, default: 0] += error.count
            }
        }
        return counts.sorted(by: { $0.value > $1.value }).prefix(20).map { ($0.key, $0.value) }
    }

    private func load() {
        if let data = defaults.data(forKey: resultsKey),
           let decoded = try? JSONDecoder().decode([SessionResult].self, from: data) {
            results = decoded
        }
        if let data = defaults.data(forKey: completedKey),
           let decoded = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            completedPhraseIds = decoded
        }
    }

    private func persistResults() {
        guard let data = try? JSONEncoder().encode(results) else { return }
        defaults.set(data, forKey: resultsKey)
    }

    private func persistCompleted() {
        guard let data = try? JSONEncoder().encode(completedPhraseIds) else { return }
        defaults.set(data, forKey: completedKey)
    }
}
