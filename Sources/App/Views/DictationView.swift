import SwiftUI

struct DictationView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var speechService = SpeechService()
    @State private var userInput: String = ""
    @State private var submitted = false
    @State private var isRevealed = false
    @State private var slowRate = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: Design.Spacing.lg) {
            if !engine.isSessionActive && !engine.isFinished {
                emptyState
                    .transition(.opacity)
            } else if engine.isFinished {
                SessionResultView()
                    .transition(.opacity)
            } else {
                sessionContent
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: engine.isSessionActive)
        .animation(.easeInOut(duration: 0.3), value: engine.isFinished)
    }

    private var emptyState: some View {
        VStack(spacing: Design.Spacing.md) {
            Image(systemName: "ear.fill")
                .font(.system(size: 48))
                .foregroundColor(Design.Color.accentLight)
            Text("Pronto per il dettato")
                .font(.title2.weight(.medium))
                .foregroundColor(Design.Color.textPrimary)
            Text("Scegli un livello e un argomento,\npoi premi Avvia")
                .font(Design.Typography.body)
                .foregroundColor(Design.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var sessionContent: some View {
        VStack(spacing: Design.Spacing.lg) {
            progressBar

            VStack(spacing: Design.Spacing.lg) {
                PhraseDisplayView(phrase: nil, isRevealed: isRevealed)

                if isRevealed, let phrase = engine.currentPhrase {
                    Text(phrase.italian)
                        .font(Design.Typography.phraseSmall)
                        .foregroundColor(Design.Color.textSecondary)
                        .padding()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                if !submitted {
                    TextField("Scrivi ciò che hai sentito...", text: $userInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18))
                        .padding(Design.Spacing.md)
                        .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: Design.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.md)
                                .stroke(Design.Color.accent.opacity(0.25), lineWidth: 1)
                        )
                        .frame(maxWidth: 420)
                        .focused($inputFocused)
                        .disabled(speechService.isSpeaking)
                        .onSubmit { submit() }

                    ControlBar(
                        canReplay: true,
                        isRevealed: isRevealed,
                        onReplay: { playCurrentPhrase(rate: slowRate ? 0.3 : 0.45) },
                        onSlow: {
                            slowRate.toggle()
                            playCurrentPhrase(rate: slowRate ? 0.3 : 0.45)
                        },
                        onReveal: { isRevealed = true },
                        onNext: {},
                        onSubmit: submit
                    )
                } else {
                    feedbackArea
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .glassCard()
            .padding(.horizontal, 48)

            Spacer()
        }
        .onAppear {
            playCurrentPhrase()
        }
        .onChange(of: speechService.isSpeaking) { _, speaking in
            if !speaking {
                inputFocused = true
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 5) {
            ForEach(0..<engine.phrases.count, id: \.self) { i in
                Capsule()
                    .fill(i == engine.currentIndex ? Design.Color.accent :
                          i < engine.currentIndex ? Design.Color.accent.opacity(0.3) :
                          Design.Color.textSecondary.opacity(0.15))
                    .frame(width: i == engine.currentIndex ? 20 : 8, height: 6)
                    .animation(.spring(duration: 0.4), value: engine.currentIndex)
            }
        }
        .padding(.top, Design.Spacing.sm)
    }

    private var feedbackArea: some View {
        VStack(spacing: Design.Spacing.md) {
            if let lastResult = engine.phraseResults.last {
                WordHighlightView(wordResults: lastResult.wordResults)

                if !lastResult.isCorrect, let phrase = engine.currentPhrase {
                    VStack(spacing: Design.Spacing.xs) {
                        Text("Corretto:")
                            .font(Design.Typography.caption)
                            .foregroundColor(Design.Color.textSecondary)
                        Text(phrase.italian)
                            .font(Design.Typography.phraseSmall)
                            .foregroundColor(Design.Color.textPrimary)
                    }
                    .padding(.top, Design.Spacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                HStack(spacing: 6) {
                    Image(systemName: lastResult.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(lastResult.isCorrect ? Design.Color.success : Design.Color.error)
                    Text(lastResult.isCorrect ? "Perfetto!" : "Riprova")
                        .font(Design.Typography.title)
                        .foregroundColor(lastResult.isCorrect ? Design.Color.success : Design.Color.warning)
                }

                HStack(spacing: Design.Spacing.sm) {
                    Button(action: { playCurrentPhrase() }) {
                        Label("Ascolta", systemImage: "speaker.wave.2")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    if !lastResult.isCorrect {
                        Button(action: retry) {
                            Label("Riprova", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    Button(action: nextPhrase) {
                        Label("Prossima", systemImage: "arrow.right")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .keyboardShortcut(.return, modifiers: [])
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: engine.phraseResults.count)
    }

    private func submit() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        engine.submitAnswer(userInput)
        submitted = true
    }

    private func retry() {
        engine.retryCurrent()
        userInput = ""
        submitted = false
        isRevealed = false
        playCurrentPhrase()
    }

    private func nextPhrase() {
        engine.nextPhrase()
        userInput = ""
        submitted = false
        isRevealed = false
        slowRate = false
        if !engine.isFinished {
            playCurrentPhrase()
            inputFocused = false
        }
    }

    private func playCurrentPhrase(rate: Float = 0.45) {
        guard let phrase = engine.currentPhrase else { return }
        speechService.speak(phrase.italian, rate: rate)
    }
}
