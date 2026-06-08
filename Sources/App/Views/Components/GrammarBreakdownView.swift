import SwiftUI

private let posColors: [String: Color] = [
    "sostantivo": Color(red: 0.35, green: 0.60, blue: 0.85),
    "verbo": Color(red: 0.75, green: 0.40, blue: 0.35),
    "aggettivo": Color(red: 0.55, green: 0.70, blue: 0.35),
    "avverbio": Color(red: 0.70, green: 0.50, blue: 0.30),
    "preposizione": Color(red: 0.50, green: 0.55, blue: 0.60),
    "congiunzione": Color(red: 0.60, green: 0.45, blue: 0.65),
    "articolo": Color(red: 0.55, green: 0.55, blue: 0.55),
    "pronome": Color(red: 0.40, green: 0.65, blue: 0.65),
    "—": .clear,
]

struct GrammarBreakdownView: View {
    let taggedWords: [TaggedWord]

    var body: some View {
        let filtered = taggedWords.filter { $0.tag != "—" }

        HStack(spacing: 0) {
            Spacer(minLength: 0)
            ForEach(filtered) { tw in
                wordColumn(tw)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: Design.Radius.sm))
    }

    private func wordColumn(_ tw: TaggedWord) -> some View {
        VStack(spacing: 2) {
            Text(tw.word)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .lineLimit(1)
                .fixedSize()

            Text(tw.tag)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(white: 0.15))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    (posColors[tw.tag] ?? .white).opacity(0.45),
                    in: RoundedRectangle(cornerRadius: 4)
                )
                .lineLimit(1)
                .fixedSize()

            if let lemma = tw.lemma {
                Text(lemma)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize()
            } else {
                Text(" ")
                    .font(.system(size: 12))
                    .fixedSize()
            }
        }
    }
}
