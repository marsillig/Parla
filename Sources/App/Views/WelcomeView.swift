import SwiftUI

struct WelcomeView: View {
    @Environment(SessionEngine.self) private var engine
    @Binding var selectedDifficulty: Difficulty
    @Binding var selectedTopic: Topic?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Parla")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                Text("Seleziona il livello")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 12) {
                    ForEach(Difficulty.allCases, id: \.self) { d in
                        Button(action: { selectedDifficulty = d }) {
                            Text(d.label)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: Design.Radius.sm)
                                        .fill(selectedDifficulty == d
                                              ? Design.Color.accent
                                              : .white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Design.Radius.sm)
                                        .stroke(selectedDifficulty == d
                                                ? Design.Color.accentLight.opacity(0.6)
                                                : .white.opacity(0.15), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 8) {
                    Text("Argomento:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    Picker(selection: $selectedTopic) {
                        Text("Tutti").tag(Optional<Topic>.none)
                        ForEach(engine.allTopics, id: \.self) { t in
                            Text(t.label).tag(Optional.some(t))
                        }
                    } label: {}
                        .pickerStyle(.menu)
                        .frame(width: 160)
                        .labelsHidden()
                        .tint(.white)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: Design.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.lg)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )

            HStack(spacing: 16) {
                modeCard(
                    icon: "ear.fill",
                    title: "Dettato"
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.mode = .dictation
                    }
                    startSession()
                }

                modeCard(
                    icon: "mic.fill",
                    title: "Pronuncia"
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.mode = .pronunciation
                    }
                    startSession()
                }

                modeCard(
                    icon: "square.grid.2x2.fill",
                    title: "Abbina"
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.mode = .matching
                        engine.isFinished = false
                        engine.isSessionActive = true
                    }
                }
            }

            Spacer()
        }
    }

    private func modeCard(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Design.Color.accent, in: RoundedRectangle(cornerRadius: Design.Radius.sm))

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 126)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.md)
                    .fill(.black.opacity(0.58))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.md)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func startSession() {
        engine.startSession(
            difficulty: selectedDifficulty,
            topic: selectedTopic,
            mode: engine.mode
        )
    }
}
