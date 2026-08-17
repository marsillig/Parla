import XCTest
@testable import Parla

@MainActor
final class MatchingGameEngineTests: XCTestCase {
    func testDefaultSessionUsesEveryImageOnce() {
        let engine = MatchingGameEngine()

        engine.start()

        XCTAssertEqual(engine.rounds.count, 300)
        XCTAssertEqual(Set(engine.rounds.map(\.item.id)).count, 300)
    }

    func testEveryRoundUsesDistractorsFromTheCorrectWordsCategory() throws {
        let engine = MatchingGameEngine()

        engine.start()

        for round in engine.rounds {
            let choiceCategories = try round.choices.map { choice in
                try XCTUnwrap(MatchGameCatalog.items.first { $0.italian == choice }?.category)
            }
            XCTAssertTrue(
                choiceCategories.allSatisfy { $0 == round.item.category },
                "Mixed category choices for \(round.item.italian)"
            )
        }
    }

    func testStartBuildsRequestedRoundsWithFiveUniqueChoices() {
        let engine = MatchingGameEngine(items: sampleItems)

        engine.start(roundCount: 3)

        XCTAssertEqual(engine.rounds.count, 3)
        for round in engine.rounds {
            XCTAssertEqual(round.choices.count, 5)
            XCTAssertEqual(Set(round.choices).count, 5)
            XCTAssertTrue(round.choices.contains(round.item.italian))
        }
    }

    func testCorrectAnswerScoresOnlyOnce() throws {
        let engine = MatchingGameEngine(items: sampleItems)
        engine.start(roundCount: 1)
        let answer = try XCTUnwrap(engine.currentRound?.item.italian)

        XCTAssertTrue(engine.submit(answer))
        XCTAssertEqual(engine.score, 1)
        XCTAssertTrue(engine.isAnswered)
        XCTAssertFalse(engine.submit(answer))
        XCTAssertEqual(engine.score, 1)
    }

    func testIncorrectAnswerDoesNotScore() throws {
        let engine = MatchingGameEngine(items: sampleItems)
        engine.start(roundCount: 1)
        let round = try XCTUnwrap(engine.currentRound)
        let wrongAnswer = try XCTUnwrap(round.choices.first { $0 != round.item.italian })

        XCTAssertFalse(engine.submit(wrongAnswer))
        XCTAssertEqual(engine.score, 0)
        XCTAssertEqual(engine.selectedWord, wrongAnswer)
        XCTAssertTrue(engine.isAnswered)
    }

    func testNextAfterLastRoundFinishesGame() throws {
        let engine = MatchingGameEngine(items: sampleItems)
        engine.start(roundCount: 1)
        let answer = try XCTUnwrap(engine.currentRound?.item.italian)
        _ = engine.submit(answer)

        engine.next()

        XCTAssertTrue(engine.isFinished)
        XCTAssertNil(engine.currentRound)
    }

    func testGeneralKnowledgeCatalogContainsThreeHundredUniqueItems() {
        let items = MatchGameCatalog.items

        XCTAssertEqual(items.count, 300)
        XCTAssertEqual(Set(items.map(\.italian)).count, 300)
        XCTAssertEqual(Set(items.map(\.imageName)).count, 300)
        for category in [
            MatchGameCategory.emotions,
            .food,
            .travel,
            .places,
            .objects,
            .animals,
        ] {
            XCTAssertEqual(items.filter { $0.category == category }.count, 50)
        }
        XCTAssertTrue(items.contains { $0.italian == "felice" })
        XCTAssertTrue(items.contains { $0.italian == "orgoglioso" })
        XCTAssertTrue(items.contains { $0.italian == "lasagna" })
        XCTAssertTrue(items.contains { $0.italian == "campeggio" })
        XCTAssertTrue(items.contains { $0.italian == "museo" })
        XCTAssertTrue(items.contains { $0.italian == "computer" })
        XCTAssertTrue(items.contains { $0.italian == "pinguino" })
    }

    func testTableUsesFurnitureSymbolInsteadOfPlaceSettingEmoji() throws {
        let table = try XCTUnwrap(MatchGameCatalog.items.first { $0.id == "tavolo" })

        XCTAssertEqual(table.systemImageName, "table.furniture")
        XCTAssertTrue(table.placeholder.isEmpty)
    }

    func testEveryEmojiFallbackIsVisuallyDistinct() {
        let fallbacks = MatchGameCatalog.items
            .filter { $0.systemImageName == nil }
            .map(\.placeholder)

        XCTAssertEqual(Set(fallbacks).count, fallbacks.count)
    }

    func testReportedAmbiguousConceptsUseContextualFallbacks() throws {
        let expected: [String: String] = [
            "cascata": "⛰️💧⬇️",
            "lasagna": "🍝🧀",
            "bar": "🏠🍸",
            "itinerario": "🗺️📍",
            "piatto": "🍽️",
            "portafoglio": "👛💳",
            "parco": "🌳🛝",
            "biblioteca": "🏛️📚",
            "fattoria": "🏠🚜",
        ]

        for (id, placeholder) in expected {
            let item = try XCTUnwrap(MatchGameCatalog.items.first { $0.id == id })
            XCTAssertEqual(item.placeholder, placeholder, "Incorrect fallback for \(id)")
        }
    }

    private var sampleItems: [MatchGameItem] {
        [
            MatchGameItem(id: "mela", italian: "mela", spanish: "manzana", imageName: "game_mela", placeholder: "🍎"),
            MatchGameItem(id: "banana", italian: "banana", spanish: "banana", imageName: "game_banana", placeholder: "🍌"),
            MatchGameItem(id: "pane", italian: "pane", spanish: "pan", imageName: "game_pane", placeholder: "🍞"),
            MatchGameItem(id: "caffe", italian: "caffè", spanish: "café", imageName: "game_caffe", placeholder: "☕️"),
            MatchGameItem(id: "acqua", italian: "acqua", spanish: "agua", imageName: "game_acqua", placeholder: "💧"),
            MatchGameItem(id: "casa", italian: "casa", spanish: "casa", imageName: "game_casa", placeholder: "🏠"),
        ]
    }
}
