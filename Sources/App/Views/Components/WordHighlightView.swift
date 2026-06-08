import SwiftUI

struct WordHighlightView: View {
    let wordResults: [WordResult]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(wordResults) { result in
                Text(result.word)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(color(for: result.status))
                    .strikethrough(result.status == .incorrect, color: Design.Color.error)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(result.status == .incorrect ?
                        Design.Color.error.opacity(0.08) : .clear,
                        in: RoundedRectangle(cornerRadius: 4))
            }
        }
        .multilineTextAlignment(.center)
        .padding(Design.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.Radius.sm))
    }

    private func color(for status: WordStatus) -> Color {
        switch status {
        case .correct: return Design.Color.success
        case .incorrect: return Design.Color.error
        case .missing: return Design.Color.textSecondary.opacity(0.5)
        case .extra: return Design.Color.warning
        }
    }
}
