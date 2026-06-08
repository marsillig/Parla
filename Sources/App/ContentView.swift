import SwiftUI

struct ContentView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var selectedDifficulty: Difficulty = .a1
    @State private var selectedTopic: Topic? = nil
    @State private var sessionCount: Double = 10

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .horizontal)
            ZStack {
                switch engine.mode {
                case .dictation:
                    DictationView()
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                case .pronunciation:
                    PronunciationView()
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LiquidGlassBackground())
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Text("Parla")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(Design.Color.accent)
                .frame(width: 70, alignment: .leading)

            ModeToggle(mode: Binding(
                get: { engine.mode },
                set: { engine.mode = $0 }
            ))
            .frame(width: 220)

            Divider().frame(height: 22)

            Group {
                Picker("Livello", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { d in
                        Text(d.label).tag(d)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 90)

                Picker("Argomento", selection: $selectedTopic) {
                    Text("Tutti").tag(Optional<Topic>.none)
                    ForEach(engine.allTopics, id: \.self) { t in
                        Text(t.label).tag(Optional.some(t))
                    }
                }
                .pickerStyle(.menu)
            }
            .font(Design.Typography.body)

            Spacer()

            HStack(spacing: 6) {
                Text("\(Int(sessionCount))")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(Design.Color.accent)
                    .frame(width: 26)
                Slider(value: $sessionCount, in: 5...25, step: 5)
                    .frame(width: 80)
                    .tint(Design.Color.accent)
                Text("frasi")
                    .font(Design.Typography.caption)
                    .foregroundColor(Design.Color.textSecondary)
            }

            Button(action: startSession) {
                Label("Avvia", systemImage: "play.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(.horizontal, Design.Spacing.md)
        .padding(.vertical, 10)
    }

    private func startSession() {
        engine.startSession(
            count: Int(sessionCount),
            difficulty: selectedDifficulty,
            topic: selectedTopic,
            mode: engine.mode
        )
    }
}
