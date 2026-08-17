import SwiftUI

struct ControlBar: View {
    let canReplay: Bool
    let isRevealed: Bool
    let onReplay: () -> Void
    let onSlow: () -> Void
    let onReveal: () -> Void
    let onNext: (() -> Void)?
    let onSubmit: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onReplay) {
                Label("Ascolta", systemImage: "speaker.wave.2")
            }
            .disabled(!canReplay)
            .keyboardShortcut("a", modifiers: .command)
            .accessibilityLabel("Ascolta")

            Button(action: onSlow) {
                Label("Lento", systemImage: "speaker.wave.1")
            }
            .disabled(!canReplay)
            .keyboardShortcut("l", modifiers: .command)
            .accessibilityLabel("Riproduci lentamente")

            if !isRevealed {
                Button(action: onReveal) {
                    Label("Risposta", systemImage: "eye")
                }
                .keyboardShortcut("r", modifiers: .command)
                .accessibilityLabel("Mostra risposta")
            }

            Spacer()

            if let onSubmit {
                Button(action: onSubmit) {
                    Label("Conferma", systemImage: "checkmark")
                        .fixedSize()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityLabel("Conferma risposta")
            }

            if let onNext {
                Button(action: onNext) {
                    Label("Prossima", systemImage: "arrow.right")
                }
                .buttonStyle(SecondaryButtonStyle())
                .keyboardShortcut(.return, modifiers: [])
                .accessibilityLabel("Prossima frase")
            }
        }
        .padding(.horizontal, Design.Spacing.md)
        .padding(.vertical, Design.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.Radius.md))
    }
}
