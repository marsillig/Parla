import AppKit
import SwiftUI

struct MatchingGameView: View {
    @State private var game = MatchingGameEngine()

    var body: some View {
        ZStack {
            if game.isFinished {
                resultView
            } else if let round = game.currentRound {
                roundView(round)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if game.rounds.isEmpty {
                game.start()
            }
        }
    }

    private func roundView(_ round: MatchGameRound) -> some View {
        VStack(spacing: 16) {
            Text("\(game.currentIndex + 1)/\(game.rounds.count)")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            MatchGameImage(item: round.item)
                .frame(width: 190, height: 190)

            answerTarget(for: round)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(round.choices, id: \.self) { word in
                    Button(word) {
                        _ = game.submit(word)
                    }
                    .buttonStyle(
                        MatchWordButtonStyle(
                            state: choiceState(for: word, round: round)
                        )
                    )
                    .disabled(game.isAnswered)
                    .draggable(word)
                    .accessibilityLabel(word)
                }
            }

            if game.isAnswered {
                Button("Prossima") {
                    game.next()
                }
                .buttonStyle(PrimaryButtonStyle())
                .keyboardShortcut(.return, modifiers: [])
                .accessibilityLabel("Prossima immagine")
            }
        }
        .padding(24)
        .frame(maxWidth: 720)
        .background(.black.opacity(0.72), in: RoundedRectangle(cornerRadius: Design.Radius.md))
        .padding(.horizontal, 32)
    }

    private func answerTarget(for round: MatchGameRound) -> some View {
        Group {
            if let selectedWord = game.selectedWord {
                if selectedWord == round.item.italian {
                    Text(selectedWord)
                } else {
                    HStack(spacing: 8) {
                        Text(selectedWord)
                            .strikethrough()
                        Image(systemName: "arrow.right")
                        Text(round.item.italian)
                    }
                }
            } else {
                Text("?")
            }
        }
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(targetColor(for: round))
        .frame(width: 300, height: 54)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: Design.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: Design.Radius.sm)
                .stroke(targetColor(for: round).opacity(0.8), lineWidth: 2)
        )
        .dropDestination(for: String.self) { words, _ in
            guard let word = words.first, round.choices.contains(word) else { return false }
            _ = game.submit(word)
            return true
        }
        .accessibilityLabel("Risposta")
        .accessibilityValue(game.selectedWord ?? "Vuota")
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Text("\(game.score)/\(game.rounds.count)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Button("Gioca ancora") {
                game.start()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityLabel("Gioca ancora")
        }
        .padding(40)
        .background(.black.opacity(0.72), in: RoundedRectangle(cornerRadius: Design.Radius.md))
    }

    private func choiceState(for word: String, round: MatchGameRound) -> MatchWordButtonStyle.State {
        guard game.isAnswered else { return .idle }
        if word == round.item.italian { return .correct }
        if word == game.selectedWord { return .incorrect }
        return .idle
    }

    private func targetColor(for round: MatchGameRound) -> Color {
        guard let selectedWord = game.selectedWord else { return .white.opacity(0.65) }
        return selectedWord == round.item.italian ? Design.Color.success : Design.Color.error
    }
}

private struct MatchGameImage: View {
    let item: MatchGameItem

    var body: some View {
        Group {
            if let image = image(named: item.imageName) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else if let systemImageName = item.systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.brown)
                    .padding(40)
            } else {
                Text(item.placeholder)
                    .font(.system(size: item.placeholder.count > 1 ? 72 : 108))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.94, green: 0.92, blue: 0.88))
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm))
        .accessibilityLabel(item.spanish)
    }

    private func image(named name: String) -> NSImage? {
        let bundles = [Bundle.module, Bundle.main]
        for bundle in bundles {
            let url = bundle.url(forResource: name, withExtension: "png", subdirectory: "GameImages")
                ?? bundle.url(forResource: name, withExtension: "png")
            if let url, let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}

private struct MatchWordButtonStyle: ButtonStyle {
    enum State {
        case idle
        case correct
        case incorrect
    }

    let state: State

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.65 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.sm)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm))
    }

    private var backgroundColor: Color {
        switch state {
        case .idle: return .white.opacity(0.08)
        case .correct: return Design.Color.success
        case .incorrect: return Design.Color.error
        }
    }
}
