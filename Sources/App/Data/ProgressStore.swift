import Foundation

@Observable
final class ProgressStore {
    private(set) var results: [SessionResult] = []

    private let defaults = UserDefaults.standard
    private let key = "parla_session_results"

    init() {
        load()
    }

    func save(result: SessionResult) {
        results.append(result)
        persist()
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
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SessionResult].self, from: data)
        else { return }
        results = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(results) else { return }
        defaults.set(data, forKey: key)
    }
}
