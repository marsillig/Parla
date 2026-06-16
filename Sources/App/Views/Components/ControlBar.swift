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
        HStack(spacing: 20) {
            Button(action: onReplay) {
                Label("Ascolta (⌘A)", systemImage: "speaker.wave.2")
            }
            .disabled(!canReplay)
            .keyboardShortcut("a", modifiers: .command)

            Button(action: onSlow) {
                Label("Lento (⌘L)", systemImage: "speaker.wave.1")
            }
            .disabled(!canReplay)
            .keyboardShortcut("l", modifiers: .command)

            if !isRevealed {
                Button(action: onReveal) {
                    Label("Risposta (⌘R)", systemImage: "eye")
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            Spacer()

            if let onSubmit {
                Button(action: onSubmit) {
                    Label("Conferma", systemImage: "checkmark")
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            if let onNext {
                Button(action: onNext) {
                    Label("Prossima", systemImage: "arrow.right")
                }
                .buttonStyle(SecondaryButtonStyle())
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(.horizontal, Design.Spacing.md)
        .padding(.vertical, Design.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.Radius.md))
    }
}
