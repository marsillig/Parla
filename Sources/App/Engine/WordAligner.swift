import Foundation

struct AlignedWord: Identifiable, Equatable, Sendable {
    let id = UUID()
    let word: String
    let expectedWord: String?
    let status: WordStatus
}

struct WordAligner: Sendable {
    static func align(expected: String, actual: String) -> [AlignedWord] {
        let expectedWords = tokenize(expected)
        let actualWords = tokenize(actual)

        let expectedCount = expectedWords.count
        let actualCount = actualWords.count
        var distance = Array(
            repeating: Array(repeating: 0, count: actualCount + 1),
            count: expectedCount + 1
        )

        for index in 0...expectedCount { distance[index][0] = index }
        for index in 0...actualCount { distance[0][index] = index }

        if expectedCount > 0, actualCount > 0 {
            for expectedIndex in 1...expectedCount {
                for actualIndex in 1...actualCount {
                    let substitutionCost = normalizedEqual(expectedWords[expectedIndex - 1], actualWords[actualIndex - 1]) ? 0 : 1
                    distance[expectedIndex][actualIndex] = min(
                        distance[expectedIndex - 1][actualIndex] + 1,
                        distance[expectedIndex][actualIndex - 1] + 1,
                        distance[expectedIndex - 1][actualIndex - 1] + substitutionCost
                    )
                }
            }
        }

        var result: [AlignedWord] = []
        var expectedIndex = expectedCount
        var actualIndex = actualCount

        while expectedIndex > 0 || actualIndex > 0 {
            if expectedIndex > 0, actualIndex > 0,
               normalizedEqual(expectedWords[expectedIndex - 1], actualWords[actualIndex - 1]),
               distance[expectedIndex][actualIndex] == distance[expectedIndex - 1][actualIndex - 1] {
                result.append(AlignedWord(word: actualWords[actualIndex - 1], expectedWord: expectedWords[expectedIndex - 1], status: .correct))
                expectedIndex -= 1
                actualIndex -= 1
            } else if expectedIndex > 0, actualIndex > 0,
                      distance[expectedIndex][actualIndex] == distance[expectedIndex - 1][actualIndex - 1] + 1 {
                result.append(AlignedWord(word: actualWords[actualIndex - 1], expectedWord: expectedWords[expectedIndex - 1], status: .incorrect))
                expectedIndex -= 1
                actualIndex -= 1
            } else if expectedIndex > 0,
                      distance[expectedIndex][actualIndex] == distance[expectedIndex - 1][actualIndex] + 1 {
                let expectedWord = expectedWords[expectedIndex - 1]
                result.append(AlignedWord(word: expectedWord, expectedWord: expectedWord, status: .missing))
                expectedIndex -= 1
            } else {
                result.append(AlignedWord(word: actualWords[actualIndex - 1], expectedWord: nil, status: .extra))
                actualIndex -= 1
            }
        }

        return Array(result.reversed())
    }

    private static func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
    }

    private static func normalizedEqual(_ expected: String, _ actual: String) -> Bool {
        normalize(expected) == normalize(actual)
    }

    private static func normalize(_ word: String) -> String {
        word.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
    }
}
