import SwiftUI

enum DictationShortcut: CaseIterable {
    case listen
    case slow
    case reveal
    case retry
    case confirm
    case next

    var hint: String {
        switch self {
        case .listen: return "⌘A"
        case .slow: return "⌘L"
        case .reveal, .retry: return "⌘R"
        case .confirm, .next: return "↩"
        }
    }

    var usesCommand: Bool {
        switch self {
        case .listen, .slow, .reveal, .retry: return true
        case .confirm, .next: return false
        }
    }

    var key: KeyEquivalent {
        switch self {
        case .listen: return "a"
        case .slow: return "l"
        case .reveal, .retry: return "r"
        case .confirm, .next: return .return
        }
    }

    var modifiers: EventModifiers {
        usesCommand ? .command : []
    }
}

struct ShortcutButtonLabel: View {
    let title: String
    let systemImage: String
    let hint: String

    var body: some View {
        HStack(spacing: 8) {
            Label(title, systemImage: systemImage)
            Text(hint)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .opacity(0.65)
        }
        .fixedSize()
    }
}

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
                ShortcutButtonLabel(title: "Ascolta", systemImage: "speaker.wave.2", hint: DictationShortcut.listen.hint)
            }
            .disabled(!canReplay)
            .keyboardShortcut(DictationShortcut.listen.key, modifiers: DictationShortcut.listen.modifiers)
            .accessibilityLabel("Ascolta")

            Button(action: onSlow) {
                ShortcutButtonLabel(title: "Lento", systemImage: "speaker.wave.1", hint: DictationShortcut.slow.hint)
            }
            .disabled(!canReplay)
            .keyboardShortcut(DictationShortcut.slow.key, modifiers: DictationShortcut.slow.modifiers)
            .accessibilityLabel("Riproduci lentamente")

            if !isRevealed {
                Button(action: onReveal) {
                    ShortcutButtonLabel(title: "Risposta", systemImage: "eye", hint: DictationShortcut.reveal.hint)
                }
                .keyboardShortcut(DictationShortcut.reveal.key, modifiers: DictationShortcut.reveal.modifiers)
                .accessibilityLabel("Mostra risposta")
            }

            Spacer()

            if let onSubmit {
                Button(action: onSubmit) {
                    ShortcutButtonLabel(title: "Conferma", systemImage: "checkmark", hint: DictationShortcut.confirm.hint)
                }
                .buttonStyle(PrimaryButtonStyle())
                .keyboardShortcut(DictationShortcut.confirm.key, modifiers: DictationShortcut.confirm.modifiers)
                .accessibilityLabel("Conferma risposta")
            }

            if let onNext {
                Button(action: onNext) {
                    ShortcutButtonLabel(title: "Prossima", systemImage: "arrow.right", hint: DictationShortcut.next.hint)
                }
                .buttonStyle(SecondaryButtonStyle())
                .keyboardShortcut(DictationShortcut.next.key, modifiers: DictationShortcut.next.modifiers)
                .accessibilityLabel("Prossima frase")
            }
        }
        .padding(.horizontal, Design.Spacing.md)
        .padding(.vertical, Design.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.Radius.md))
    }
}
