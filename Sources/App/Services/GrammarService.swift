import NaturalLanguage

struct TaggedWord: Identifiable {
    let id = UUID()
    let word: String
    let tag: String
    let lemma: String?
}

func tagItalianPhrase(_ phrase: String) -> [TaggedWord] {
    let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
    tagger.string = phrase
    tagger.setLanguage(.italian, range: phrase.startIndex..<phrase.endIndex)

    var results: [TaggedWord] = []
    tagger.enumerateTags(
        in: phrase.startIndex..<phrase.endIndex,
        unit: .word,
        scheme: .lexicalClass
    ) { tag, tokenRange in
        let word = String(phrase[tokenRange])
        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        let raw = tag?.rawValue ?? "?"

        let lemma = tagger.tag(at: tokenRange.lowerBound, unit: .word, scheme: .lemma).0?.rawValue
        let lemmaString: String?
        if let lemma, !lemma.isEmpty, lemma.lowercased() != word.lowercased() {
            lemmaString = lemma
        } else {
            lemmaString = nil
        }

        let italianTag: String
        let tagLemma: String?
        if raw == "Numeral" {
            italianTag = lemmaString ?? word
            tagLemma = nil
        } else {
            italianTag = posLabel(for: raw)
            tagLemma = lemmaString
        }

        results.append(TaggedWord(word: word, tag: italianTag, lemma: tagLemma))
        return true
    }

    return results
}

private func posLabel(for tag: String) -> String {
    switch tag {
    case "Noun": return "sostantivo"
    case "Verb": return "verbo"
    case "Adjective": return "aggettivo"
    case "Adverb": return "avverbio"
    case "Preposition": return "preposizione"
    case "Conjunction": return "congiunzione"
    case "Determiner": return "articolo"
    case "Numeral": return "numero"
    case "Pronoun": return "pronome"
    case "Punctuation", "OtherPunctuation", "SentenceTerminator", "OtherSentenceTerminator", "OpenQuote", "CloseQuote", "Dash", "Other": return "—"
    default: return tag.lowercased()
}

}
