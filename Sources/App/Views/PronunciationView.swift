import AVFoundation
import SwiftUI

enum PronunciationShortcut: CaseIterable {
    case retry
    case listen
    case recording
    case next

    var title: String {
        switch self {
        case .retry: return "Riprova"
        case .listen: return "Ascolta"
        case .recording: return "La mia voce"
        case .next: return "Prossima"
        }
    }

    var systemImage: String {
        switch self {
        case .retry: return "arrow.counterclockwise"
        case .listen: return "speaker.wave.2"
        case .recording: return "waveform.path.mic"
        case .next: return "arrow.right"
        }
    }

    var hint: String {
        switch self {
        case .retry: return "⌘R"
        case .listen: return "⌘A"
        case .recording: return "⌘V"
        case .next: return "↩"
        }
    }

    var usesCommand: Bool {
        self != .next
    }

    var key: KeyEquivalent {
        switch self {
        case .retry: return "r"
        case .listen: return "a"
        case .recording: return "v"
        case .next: return .return
        }
    }

    var modifiers: EventModifiers {
        usesCommand ? .command : []
    }
}

struct PronunciationView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var audioCapture = AudioCaptureService()
    @State private var speechService = SpeechService()
    @State private var isProcessing = false
    @State private var transcribedText: String = ""
    @State private var submitted = false
    @State private var recordingURL: URL?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var taggedWords: [TaggedWord] = []
    @State private var pulse = false
    @State private var errorMessage: String?

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
        .task {
            await loadModel()
        }
        .onDisappear {
            audioCapture.cancelRecording()
            speechService.stop()
        }
    }

    private var sessionContent: some View {
        VStack(spacing: Design.Spacing.lg) {
            progressBar

            VStack(spacing: Design.Spacing.lg) {
                domainHeader

                PhraseDisplayView(phrase: engine.currentPhrase?.italian, isRevealed: true, textColor: .white)

                if let phrase = engine.currentPhrase {
                    Text(phrase.spanish)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 4)
                }

                if !submitted {
                    VStack(spacing: Design.Spacing.sm) {
                        if engine.transcriptionService.isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Scaricando modello vocale...")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(Design.Color.textSecondary)
                            }
                            .padding()
                        } else if let loadError = engine.transcriptionService.loadError {
                            VStack(spacing: Design.Spacing.sm) {
                                Text(loadError)
                                    .font(Design.Typography.caption)
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                Button("Riprova") {
                                    Task { await loadModel() }
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                            .padding()
                        }

                        Button(action: toggleRecording) {
                            VStack(spacing: 8) {
                                ZStack {
                                    if audioCapture.isRecording {
                                        // Recording state — red pulsing circle
                                        Circle()
                                            .fill(Color.red.opacity(0.15))
                                            .frame(width: 100, height: 100)
                                            .scaleEffect(pulse ? 1.15 : 1.0)

                                        Circle()
                                            .stroke(Color.red.opacity(0.4), lineWidth: 3)
                                            .frame(width: 100, height: 100)
                                            .scaleEffect(pulse ? 1.1 : 1.0)

                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.red.opacity(0.9), .red.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 72, height: 72)
                                            .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 4)

                                        // Recording dot
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 12, height: 12)
                                            .shadow(color: .red.opacity(0.6), radius: 4, x: 0, y: 0)
                                            .offset(y: -38)
                                    } else {
                                        // Idle state — accent glass circle
                                        Circle()
                                            .fill(.white.opacity(0.06))
                                            .frame(width: 100, height: 100)

                                        Circle()
                                            .stroke(.white.opacity(0.15), lineWidth: 2)
                                            .frame(width: 100, height: 100)

                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Design.Color.accent.opacity(0.9),
                                                        Design.Color.accentDim.opacity(0.95)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 72, height: 72)
                                            .shadow(color: Design.Color.accent.opacity(0.4), radius: 10, x: 0, y: 4)

                                        LinearGradient(
                                            colors: [.white.opacity(0.25), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        )
                                        .frame(width: 72, height: 72)
                                        .clipShape(Circle())
                                    }

                                    Image(systemName: audioCapture.isRecording ?
                                          "stop.fill" : "mic.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                }

                                Text(audioCapture.isRecording ? "Ferma" : "Inizia")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(audioCapture.isRecording ? .red : .white.opacity(0.9))
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(isProcessing || !engine.transcriptionService.isLoaded)
                        .opacity(isProcessing || !engine.transcriptionService.isLoaded ? 0.4 : 1)
                        .keyboardShortcut(.space, modifiers: [])
                        .accessibilityLabel(audioCapture.isRecording ? "Ferma registrazione" : "Inizia registrazione")

                        if audioCapture.isRecording {
                            AudioLevelIndicator(level: audioCapture.audioLevel)
                                .frame(height: 50)
                                .padding(.horizontal, 20)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                Text("Registrazione in corso — premi spazio per fermare")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(Design.Color.textSecondary)
                            }
                        }

                        if !audioCapture.isRecording && !engine.transcriptionService.isLoaded && engine.transcriptionService.loadError == nil {
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

                        if let errorMessage {
                            Text(errorMessage)
                                .font(Design.Typography.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.top, Design.Spacing.xs)
                        }
                    }

                } else {
                    feedbackArea
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .glassCard()
            .padding(.horizontal, 48)

            Spacer()
        }
        .onChange(of: audioCapture.isRecording) { _, recording in
            if recording {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            } else {
                pulse = false
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
                VStack(spacing: Design.Spacing.xs) {
                    Text("Hai detto:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    WordHighlightView(wordResults: lastResult.wordResults)
                }

                if !taggedWords.isEmpty {
                    GrammarBreakdownView(taggedWords: taggedWords)
                        .transition(.opacity)
                }

                HStack(spacing: Design.Spacing.sm) {
                    Button(action: retry) {
                        ShortcutButtonLabel(
                            title: PronunciationShortcut.retry.title,
                            systemImage: PronunciationShortcut.retry.systemImage,
                            hint: PronunciationShortcut.retry.hint
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .keyboardShortcut(PronunciationShortcut.retry.key, modifiers: PronunciationShortcut.retry.modifiers)
                    .accessibilityLabel("Riprova")
                    Button(action: { playCurrentPhrase() }) {
                        ShortcutButtonLabel(
                            title: PronunciationShortcut.listen.title,
                            systemImage: PronunciationShortcut.listen.systemImage,
                            hint: PronunciationShortcut.listen.hint
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .keyboardShortcut(PronunciationShortcut.listen.key, modifiers: PronunciationShortcut.listen.modifiers)
                    .accessibilityLabel("Ascolta")
                    Button(action: playRecording) {
                        ShortcutButtonLabel(
                            title: PronunciationShortcut.recording.title,
                            systemImage: PronunciationShortcut.recording.systemImage,
                            hint: PronunciationShortcut.recording.hint
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(recordingURL == nil)
                    .keyboardShortcut(PronunciationShortcut.recording.key, modifiers: PronunciationShortcut.recording.modifiers)
                    .accessibilityLabel("La mia voce")
                    Button(action: nextPhrase) {
                        ShortcutButtonLabel(
                            title: PronunciationShortcut.next.title,
                            systemImage: PronunciationShortcut.next.systemImage,
                            hint: PronunciationShortcut.next.hint
                        )
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .keyboardShortcut(PronunciationShortcut.next.key, modifiers: PronunciationShortcut.next.modifiers)
                    .accessibilityLabel("Prossima frase")
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: engine.phraseResults.count)
    }

    private func toggleRecording() {
        if audioCapture.isRecording {
            stopAndTranscribe()
        } else if !isProcessing {
            Task { await startRecording() }
        }
    }

    private func startRecording() async {
        let granted = await audioCapture.requestPermission()
        guard granted else {
            errorMessage = "Consenti l'accesso al microfono nelle Impostazioni di Sistema per esercitare la pronuncia."
            return
        }
        recordingURL = nil
        transcribedText = ""
        errorMessage = nil
        do {
            try audioCapture.startRecording()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stopAndTranscribe() {
        recordingURL = audioCapture.stopRecording()
        guard let url = recordingURL else {
            errorMessage = "La registrazione deve durare almeno mezzo secondo."
            return
        }

        isProcessing = true
        Task {
            do {
                let text = try await engine.transcriptionService.transcribe(audioURL: url)
                await MainActor.run {
                    transcribedText = text
                    engine.submitAnswer(text)
                    if let phrase = engine.currentPhrase {
                        taggedWords = tagItalianPhrase(phrase.italian)
                    }
                    submitted = true
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
                }
            }
        }
    }

    private func retry() {
        audioPlayer?.stop()
        audioPlayer = nil
        engine.retryCurrent()
        transcribedText = ""
        submitted = false
        taggedWords = []
        errorMessage = nil
    }

    private func nextPhrase() {
        audioPlayer?.stop()
        audioPlayer = nil
        engine.nextPhrase()
        transcribedText = ""
        submitted = false
        taggedWords = []
        errorMessage = nil
    }

    private func playRecording() {
        guard let url = recordingURL else { return }
        audioPlayer?.stop()
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }

    private func playCurrentPhrase(rate: Float = 0.45) {
        guard let phrase = engine.currentPhrase else { return }
        speechService.speak(phrase.italian, rate: rate)
    }

    private func loadModel() async {
        do {
            try await engine.transcriptionService.loadModel()
        } catch {
            // The service exposes a localized, actionable loading state in the view.
        }
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
