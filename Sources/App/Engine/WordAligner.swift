import Foundation

struct AlignedWord: Identifiable, Equatable, Sendable {
    let id = UUID()
    let word: String
    let status: WordStatus
}

struct WordAligner: Sendable {
    static func align(expected: String, actual: String) -> [AlignedWord] {
        let expectedWords = tokenize(expected)
        let actualWords = tokenize(actual)

        var result: [AlignedWord] = []
        var actualIndex = 0

        for expectedWord in expectedWords {
            if actualIndex < actualWords.count {
                let actualWord = actualWords[actualIndex]
                if normalizedEqual(expectedWord, actualWord) {
                    result.append(AlignedWord(word: actualWord, status: .correct))
                } else {
                    result.append(AlignedWord(word: actualWord, status: .incorrect))
                }
                actualIndex += 1
            } else {
                result.append(AlignedWord(word: expectedWord, status: .missing))
            }
        }

        while actualIndex < actualWords.count {
            result.append(AlignedWord(word: actualWords[actualIndex], status: .extra))
            actualIndex += 1
        }

        return result
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
            .folding(options: .diacriticInsensitive, locale: nil)
    }
}
