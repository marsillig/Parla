import SwiftUI

struct SessionResultView: View {
    @Environment(SessionEngine.self) private var engine
    @State private var animating = false

    var body: some View {
        VStack(spacing: Design.Spacing.lg) {
            Spacer()

            VStack(spacing: Design.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Design.Color.success.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Design.Color.success)
                }
                .scaleEffect(animating ? 1 : 0.5)
                .opacity(animating ? 1 : 0)

                Text("Sessione completata!")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(Design.Color.textPrimary)
                    .opacity(animating ? 1 : 0)

                VStack(spacing: Design.Spacing.sm) {
                    resultRow(label: "Frasi", value: "\(engine.phraseResults.count)")
                    Divider().opacity(0.3)
                    resultRow(label: "Precisione", value: "\(Int(engine.overallAccuracy * 100))%")
                    Divider().opacity(0.3)
                    resultRow(label: "Corrette", value: "\(engine.phraseResults.filter(\.isCorrect).count)")
                    Divider().opacity(0.3)
                    resultRow(label: "Modalità", value: engine.mode == .dictation ? "Dettato" : "Pronuncia")
                }
                .padding(Design.Spacing.md)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.Radius.md))
                .offset(y: animating ? 0 : 20)
                .opacity(animating ? 1 : 0)

                if !engine.allWordErrors.isEmpty {
                    VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.caption)
                            Text("Parole da ripassare")
                                .font(Design.Typography.title)
                                .foregroundColor(Design.Color.textPrimary)
                        }
                        ForEach(engine.allWordErrors.prefix(8)) { error in
                            HStack(spacing: Design.Spacing.sm) {
                                Text(error.correctWord)
                                    .font(Design.Typography.body.weight(.medium))
                                    .foregroundColor(Design.Color.error)
                                Text("→")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(Design.Color.textSecondary)
                                Text("\(error.count) errori")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(Design.Color.textSecondary)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(Design.Spacing.md)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.Radius.md))
                    .offset(y: animating ? 0 : 20)
                    .opacity(animating ? 1 : 0)
                }
            }
            .glassCard(radius: Design.Radius.xxl)
            .padding(.horizontal, 60)

            Button(action: restart) {
                Label("Nuova sessione", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(PrimaryButtonStyle())
            .controlSize(.large)
            .opacity(animating ? 1 : 0)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.3).delay(0.1)) {
                animating = true
            }
        }
    }

    private func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Design.Typography.body)
                .foregroundColor(Design.Color.textSecondary)
            Spacer()
            Text(value)
                .font(Design.Typography.body.weight(.semibold))
                .foregroundColor(Design.Color.textPrimary)
        }
    }

    private func restart() {
        engine.startSession(
            count: engine.sessionCount,
            difficulty: engine.selectedDifficulty,
            topic: engine.selectedTopic,
            mode: engine.mode
        )
    }
}
