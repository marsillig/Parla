import SwiftUI

struct WelcomeView: View {
    @Environment(SessionEngine.self) private var engine
    @Binding var selectedDifficulty: Difficulty
    @Binding var selectedTopic: Topic?
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Text("Benvenuto in Parla")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Scegli come vuoi practicare l'italiano")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 24) {
                modeCard(
                    icon: "ear.fill",
                    title: "Dettato",
                    description: "Ascolta e scrivi ciò che senti"
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.mode = .dictation
                    }
                    startSession()
                }

                modeCard(
                    icon: "mic.fill",
                    title: "Pronuncia",
                    description: "Leggi ad alta voce e controlla"
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        engine.mode = .pronunciation
                    }
                    startSession()
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }

            Spacer()
        }
    }

    private func modeCard(icon: String, title: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Design.Color.accent.opacity(0.25),
                                    Design.Color.accent.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulse ? 1.15 : 1.0)

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
                        .frame(width: 64, height: 64)
                        .shadow(color: Design.Color.accent.opacity(0.4), radius: 12, x: 0, y: 6)

                    LinearGradient(
                        colors: [.white.opacity(0.25), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                }

                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 160, height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0, green: 0.133, blue: 0.2))
                    .opacity(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(GlassButtonStyle())
    }

    private func startSession() {
        engine.startSession(
            difficulty: selectedDifficulty,
            topic: selectedTopic,
            mode: engine.mode
        )
    }
}
