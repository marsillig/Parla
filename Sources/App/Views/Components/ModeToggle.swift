import SwiftUI

struct ModeToggle: View {
    @Binding var mode: ExerciseMode
    var isEnabled: Bool = true

    @State private var pulse = false
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 16) {
            earButton
            micButton
        }
        .opacity(isEnabled ? 1.0 : 0.4)
        .allowsHitTesting(isEnabled)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var earButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                mode = .dictation
            }
        }) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Design.Color.accent.opacity(0.25),
                                Design.Color.accent.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 32
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulse ? 1.15 : 1.0)

                // Glass body — ear shape
                earShape
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
                    .frame(width: 48, height: 48)
                    .shadow(color: Design.Color.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    .shadow(color: .white.opacity(0.15), radius: 1, x: 0, y: -1)

                // Glass highlight
                LinearGradient(
                    colors: [.white.opacity(0.25), .clear],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .frame(width: 48, height: 48)
                .clipShape(earShape)

                // Ear icon
                Image(systemName: "ear.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .frame(width: 48, height: 48)
            .clipShape(earShape)
        }
        .buttonStyle(GlassButtonStyle())
    }

    private var micButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                mode = .pronunciation
            }
        }) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Design.Color.accent.opacity(0.25),
                                Design.Color.accent.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 32
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulse ? 1.15 : 1.0)

                // Glass body — mic shape
                micShape
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
                    .frame(width: 48, height: 48)
                    .shadow(color: Design.Color.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    .shadow(color: .white.opacity(0.15), radius: 1, x: 0, y: -1)

                // Glass highlight
                LinearGradient(
                    colors: [.white.opacity(0.25), .clear],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .frame(width: 48, height: 48)
                .clipShape(micShape)

                // Mic icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .frame(width: 48, height: 48)
            .clipShape(micShape)
        }
        .buttonStyle(GlassButtonStyle())
    }

    // Ear-shaped path (organic blob)
    private var earShape: some Shape {
        Path { path in
            path.move(to: CGPoint(x: 24, y: 6))
            path.addCurve(
                to: CGPoint(x: 38, y: 14),
                control1: CGPoint(x: 32, y: 6),
                control2: CGPoint(x: 38, y: 8)
            )
            path.addCurve(
                to: CGPoint(x: 40, y: 28),
                control1: CGPoint(x: 40, y: 20),
                control2: CGPoint(x: 40, y: 28)
            )
            path.addCurve(
                to: CGPoint(x: 36, y: 40),
                control1: CGPoint(x: 40, y: 36),
                control2: CGPoint(x: 38, y: 40)
            )
            path.addCurve(
                to: CGPoint(x: 20, y: 42),
                control1: CGPoint(x: 32, y: 44),
                control2: CGPoint(x: 24, y: 42)
            )
            path.addCurve(
                to: CGPoint(x: 12, y: 34),
                control1: CGPoint(x: 16, y: 42),
                control2: CGPoint(x: 12, y: 38)
            )
            path.addCurve(
                to: CGPoint(x: 14, y: 18),
                control1: CGPoint(x: 12, y: 28),
                control2: CGPoint(x: 12, y: 22)
            )
            path.addCurve(
                to: CGPoint(x: 24, y: 6),
                control1: CGPoint(x: 16, y: 10),
                control2: CGPoint(x: 20, y: 6)
            )
            path.closeSubpath()
        }
    }

    // Mic-shaped path (rounded rectangle)
    private var micShape: some Shape {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }
}

struct GlassButtonStyle: ButtonStyle {
    @State private var isPressed = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
            .onAppear {
                isPressed = configuration.isPressed
            }
            .onChange(of: configuration.isPressed) { _, pressed in
                isPressed = pressed
            }
    }
}
