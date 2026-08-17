import XCTest
@testable import Parla

final class PhraseStoreTests: XCTestCase {
    func testLoadedPhrasesDoNotRepeatItalianText() {
        let phrases = PhraseStore().allPhrases

        XCTAssertEqual(Set(phrases.map(\.italian)).count, phrases.count)
    }
}
