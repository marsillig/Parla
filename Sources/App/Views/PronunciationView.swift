import SwiftUI

struct PronunciationView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var audioCapture = AudioCaptureService()
    @State private var transcriptionService = TranscriptionService()
    @State private var isProcessing = false
    @State private var transcribedText: String = ""
    @State private var submitted = false
    @State private var recordingURL: URL?

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
        .task {
            try? await transcriptionService.loadModel()
        }
    }

    private var emptyState: some View {
        VStack(spacing: Design.Spacing.md) {
            Image(systemName: "mic.fill")
                .font(.system(size: 48))
                .foregroundColor(Design.Color.accentLight)
            Text("Pronto per la pronuncia")
                .font(.title2.weight(.medium))
                .foregroundColor(Design.Color.textPrimary)
            Text("Leggi la frase ad alta voce\ne controlla la tua pronuncia")
                .font(Design.Typography.body)
                .foregroundColor(Design.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var sessionContent: some View {
        VStack(spacing: Design.Spacing.lg) {
            progressBar

            VStack(spacing: Design.Spacing.lg) {
                PhraseDisplayView(phrase: engine.currentPhrase?.italian, isRevealed: true)

                if !submitted {
                    VStack(spacing: Design.Spacing.sm) {
                        if !transcriptionService.isLoaded {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Scaricando modello vocale...")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(Design.Color.textSecondary)
                            }
                            .padding()
                        }

                        ZStack {
                            Circle()
                                .fill(audioCapture.isRecording ?
                                      Design.Color.error.opacity(0.15) :
                                      Design.Color.accent.opacity(0.1))
                                .frame(width: 100, height: 100)

                            Circle()
                                .stroke(audioCapture.isRecording ?
                                        Design.Color.error.opacity(0.3) :
                                        Design.Color.accent.opacity(0.2),
                                        lineWidth: 2)
                                .frame(width: 100, height: 100)
                                .scaleEffect(audioCapture.isRecording ? 1.15 : 1)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                           value: audioCapture.isRecording)

                            Button(action: toggleRecording) {
                                Image(systemName: audioCapture.isRecording ?
                                      "stop.fill" : "mic.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(audioCapture.isRecording ?
                                                     Design.Color.error : Design.Color.accent)
                            }
                            .buttonStyle(.plain)
                            .keyboardShortcut(.space, modifiers: [])
                        }

                        if audioCapture.isRecording {
                            AudioLevelIndicator(level: audioCapture.audioLevel)
                                .frame(height: 50)
                                .padding(.horizontal, 20)
                            Text("Premi spazio o il pulsante per fermare")
                                .font(Design.Typography.caption)
                                .foregroundColor(Design.Color.textSecondary)
                        }

                        if !audioCapture.isRecording && !transcriptionService.isLoaded {
                            Text("Il primo utilizzo scarica il\nmodello di riconoscimento vocale")
                                .font(Design.Typography.caption)
                                .foregroundColor(Design.Color.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        if isProcessing {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Trascrivendo...")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(Design.Color.textSecondary)
                            }
                            .padding(.top, Design.Spacing.xs)
                        }
                    }

                    ControlBar(
                        canReplay: false,
                        isRevealed: false,
                        onReplay: {},
                        onSlow: {},
                        onReveal: {},
                        onNext: {},
                        onSubmit: nil
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
                VStack(spacing: Design.Spacing.xs) {
                    Text("Hai detto:")
                        .font(Design.Typography.caption)
                        .foregroundColor(Design.Color.textSecondary)
                    WordHighlightView(wordResults: lastResult.wordResults)
                }

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
                    Text(lastResult.isCorrect ? "Ottima pronuncia!" : "Riprova")
                        .font(Design.Typography.title)
                        .foregroundColor(lastResult.isCorrect ? Design.Color.success : Design.Color.warning)
                }

                HStack(spacing: Design.Spacing.sm) {
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
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: engine.phraseResults.count)
    }

    private func toggleRecording() {
        if audioCapture.isRecording {
            stopAndTranscribe()
        } else {
            Task { await startRecording() }
        }
    }

    private func startRecording() async {
        let granted = await audioCapture.requestPermission()
        guard granted else { return }
        recordingURL = nil
        transcribedText = ""
        try? audioCapture.startRecording()
    }

    private func stopAndTranscribe() {
        recordingURL = audioCapture.stopRecording()
        guard let url = recordingURL else { return }

        isProcessing = true
        Task {
            do {
                let text = try await transcriptionService.transcribe(audioURL: url)
                await MainActor.run {
                    transcribedText = text
                    engine.submitAnswer(text)
                    submitted = true
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    transcribedText = "[errore]"
                    isProcessing = false
                }
            }
        }
    }

    private func retry() {
        engine.retryCurrent()
        transcribedText = ""
        submitted = false
    }

    private func nextPhrase() {
        engine.nextPhrase()
        transcribedText = ""
        submitted = false
    }
}

struct AudioLevelIndicator: View {
    let level: Float

    var body: some View {
        let normalized = max(0, min(1, Double(level + 60) / 60))
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Design.Color.textSecondary.opacity(0.12))

                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Design.Color.accent, Design.Color.accentLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * normalized, 4))
                    .animation(.linear(duration: 0.05), value: normalized)
            }
        }
        .frame(height: 10)
        .padding(.horizontal, 40)
    }
}
