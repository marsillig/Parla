import SwiftUI

enum Design {
    // MARK: - Colors
    enum Color {
        static let background = LinearGradient(
            colors: [
                SwiftUI.Color(red: 0.98, green: 0.95, blue: 0.88),
                SwiftUI.Color(red: 0.95, green: 0.88, blue: 0.76),
                SwiftUI.Color(red: 0.92, green: 0.82, blue: 0.68),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accent = SwiftUI.Color(red: 0.76, green: 0.42, blue: 0.24)
        static let accentLight = SwiftUI.Color(red: 0.90, green: 0.60, blue: 0.40)
        static let accentDim = SwiftUI.Color(red: 0.60, green: 0.30, blue: 0.15)

        static let surfaceLight = SwiftUI.Color.white.opacity(0.55)
        static let surfaceMedium = SwiftUI.Color.white.opacity(0.35)

        static let textPrimary = SwiftUI.Color(red: 0.15, green: 0.12, blue: 0.10)
        static let textSecondary = SwiftUI.Color(red: 0.45, green: 0.40, blue: 0.35)

        static let success = SwiftUI.Color(red: 0.30, green: 0.65, blue: 0.35)
        static let error = SwiftUI.Color(red: 0.80, green: 0.30, blue: 0.25)
        static let warning = SwiftUI.Color(red: 0.85, green: 0.55, blue: 0.15)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    // MARK: - Shadows
    enum Shadow {
        static let card = SwiftUI.Color.black.opacity(0.06)
        static let elevated = SwiftUI.Color.black.opacity(0.10)
    }

    // MARK: - Typography
    enum Typography {
        static let phraseFont = Font.system(size: 28, weight: .medium, design: .serif)
        static let phraseSmall = Font.system(size: 20, weight: .medium, design: .serif)
        static let title = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 15)
        static let caption = Font.system(size: 12)
        static let label = Font.system(size: 13, weight: .medium)
    }
}

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    var radius: CGFloat = Design.Radius.xl
    var padding: CGFloat = Design.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: radius))
            .shadow(color: Design.Shadow.card, radius: 8, y: 2)
    }
}

extension View {
    func glassCard(radius: CGFloat = Design.Radius.xl, padding: CGFloat = Design.Spacing.lg) -> some View {
        modifier(GlassCard(radius: radius, padding: padding))
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.Typography.label)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Design.Color.accent, in: RoundedRectangle(cornerRadius: Design.Radius.sm))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.Typography.label)
            .foregroundColor(Design.Color.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.sm)
                    .stroke(Design.Color.accent.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
