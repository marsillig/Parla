import SwiftUI

struct ContentView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var selectedDifficulty: Difficulty = .a1
    @State private var selectedTopic: Topic? = nil

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .horizontal)

            ZStack {
                if !engine.isSessionActive && !engine.isFinished {
                    WelcomeView(
                        selectedDifficulty: $selectedDifficulty,
                        selectedTopic: $selectedTopic
                    )
                    .transition(.opacity)
                } else if engine.isFinished {
                    SessionResultView()
                        .transition(.opacity)
                } else {
                    switch engine.mode {
                    case .dictation:
                        DictationView()
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    case .pronunciation:
                        PronunciationView()
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    case .matching:
                        MatchingGameView()
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(LiquidGlassBackground(isActive: engine.isSessionActive))
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Spacer()

            if engine.isSessionActive || engine.isFinished {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.resetToHome()
                    }
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Torna alla home")
                .transition(.opacity)
            }
        }
        .padding(.horizontal, Design.Spacing.md)
        .padding(.vertical, 10)
    }

}
