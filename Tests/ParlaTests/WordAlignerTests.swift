import XCTest
@testable import Parla

final class WordAlignerTests: XCTestCase {
    func testExactMatch() {
        let result = WordAligner.align(expected: "Vorrei un caffè", actual: "Vorrei un caffè")
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.allSatisfy { $0.status == .correct })
    }

    func testOneWrongWord() {
        let result = WordAligner.align(expected: "Vorrei un caffè", actual: "Vorrei un latte")
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].status, .correct)
        XCTAssertEqual(result[1].status, .correct)
        XCTAssertEqual(result[2].status, .incorrect)
    }

    func testMissingWord() {
        let result = WordAligner.align(expected: "Vorrei un caffè grazie", actual: "Vorrei un caffè")
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[2].status, .correct)
        XCTAssertEqual(result[3].status, .missing)
    }

    func testExtraWord() {
        let result = WordAligner.align(expected: "Buongiorno", actual: "Buongiorno signore")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].status, .correct)
        XCTAssertEqual(result[1].status, .extra)
    }

    func testExtraWordDoesNotCascadeIntoFalseErrors() {
        let result = WordAligner.align(expected: "Io sono pronto", actual: "Io davvero sono pronto")

        XCTAssertEqual(result.map(\.status), [.correct, .extra, .correct, .correct])
        XCTAssertEqual(result[1].word, "davvero")
        XCTAssertNil(result[1].expectedWord)
    }

    func testMissingWordKeepsRemainingWordsAligned() {
        let result = WordAligner.align(expected: "Io sono molto pronto", actual: "Io sono pronto")

        XCTAssertEqual(result.map(\.status), [.correct, .correct, .missing, .correct])
        XCTAssertEqual(result[2].expectedWord, "molto")
    }

    func testEmptyExpected() {
        let result = WordAligner.align(expected: "", actual: "qualcosa")
        XCTAssertTrue(result.allSatisfy { $0.status == .extra })
    }

    func testEmptyActual() {
        let result = WordAligner.align(expected: "qualcosa", actual: "")
        XCTAssertTrue(result.allSatisfy { $0.status == .missing })
    }

    func testAccentsAreRespected() {
        let result = WordAligner.align(expected: "caffè", actual: "caffe")
        XCTAssertEqual(result.first?.status, .incorrect)
    }

    func testPunctuationDoesNotAffectMatch() {
        let result = WordAligner.align(expected: "Come stai?", actual: "Come stai")
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.status == .correct })
    }

    func testCaseInsensitive() {
        let result = WordAligner.align(expected: "Buongiorno", actual: "buongiorno")
        XCTAssertEqual(result[0].status, .correct)
    }
}
