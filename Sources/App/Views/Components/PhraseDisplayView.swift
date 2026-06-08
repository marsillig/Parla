import SwiftUI

struct PhraseDisplayView: View {
    let phrase: String?
    let isRevealed: Bool
    var textColor: Color = Design.Color.textPrimary

    var body: some View {
        Group {
            if let phrase {
                Text(phrase)
                    .font(Design.Typography.phraseFont)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
            } else {
                Text("...")
                    .font(Design.Typography.phraseFont)
                    .foregroundColor(textColor.opacity(0.3))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: Design.Radius.md))
        .opacity(isRevealed ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: isRevealed)
    }
}
