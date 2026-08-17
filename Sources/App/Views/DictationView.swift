import SwiftUI

struct DictationView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var speechService = SpeechService()
    @State private var userInput: String = ""
    @State private var submitted = false
    @State private var isRevealed = false
    @State private var slowRate = false
    @State private var taggedWords: [TaggedWord] = []
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: Design.Spacing.lg) {
            if engine.isFinished {
                SessionResultView()
                    .transition(.opacity)
            } else {
                sessionContent
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: engine.isFinished)
    }

    private var sessionContent: some View {
        VStack(spacing: Design.Spacing.lg) {
            progressBar

            VStack(spacing: Design.Spacing.lg) {
                domainHeader

                PhraseDisplayView(phrase: nil, isRevealed: isRevealed)

                if isRevealed, let phrase = engine.currentPhrase {
                    Text(phrase.italian)
                        .font(Design.Typography.phraseFont)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: Design.Radius.md))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                if !submitted {
                    TextField("", text: $userInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(Design.Spacing.md)
                        .background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: Design.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.md)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                        .overlay(alignment: .leading) {
                            if userInput.isEmpty {
                                Text("Scrivi ciò che hai sentito...")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.leading, Design.Spacing.md)
                            }
                        }
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
                        onNext: nil,
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

    @ViewBuilder
    private var domainHeader: some View {
        if let topic = engine.currentPhrase?.topic {
            Text(topic.label.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.white.opacity(0.1), in: Capsule())
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            Text("\(engine.currentIndex + 1)/\(engine.phrases.count)")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text("·")
                .foregroundColor(.white.opacity(0.5))

            Text("\(engine.completedCount)/\(engine.totalPhrases) completate")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, Design.Spacing.sm)
    }

    private var feedbackArea: some View {
        VStack(spacing: Design.Spacing.md) {
            if let lastResult = engine.phraseResults.last {
                if let phrase = engine.currentPhrase {
                    Text(phrase.spanish)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 24)
                }

                WordHighlightView(wordResults: lastResult.wordResults)

                if !taggedWords.isEmpty {
                    GrammarBreakdownView(taggedWords: taggedWords)
                        .transition(.opacity)
                }

                HStack(spacing: Design.Spacing.sm) {
                    Button(action: { playCurrentPhrase() }) {
                        Label("Ascolta", systemImage: "speaker.wave.2")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .keyboardShortcut("a", modifiers: .command)
                    .accessibilityLabel("Ascolta")
                    if !lastResult.isCorrect {
                        Button(action: retry) {
                            Label("Riprova", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .keyboardShortcut("r", modifiers: .command)
                        .accessibilityLabel("Riprova")
                    }
                    Button(action: nextPhrase) {
                        Label("Prossima", systemImage: "arrow.right")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .keyboardShortcut(.return, modifiers: [])
                    .accessibilityLabel("Prossima frase")
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: engine.phraseResults.count)
    }

    private func submit() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        engine.submitAnswer(userInput)
        if let phrase = engine.currentPhrase {
            taggedWords = tagItalianPhrase(phrase.italian)
        }
        submitted = true
    }

    private func retry() {
        engine.retryCurrent()
        userInput = ""
        submitted = false
        isRevealed = false
        taggedWords = []
        playCurrentPhrase()
    }

    private func nextPhrase() {
        engine.nextPhrase()
        userInput = ""
        submitted = false
        isRevealed = false
        slowRate = false
        taggedWords = []
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
