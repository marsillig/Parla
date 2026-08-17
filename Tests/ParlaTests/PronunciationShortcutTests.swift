import XCTest
@testable import Parla

final class PronunciationShortcutTests: XCTestCase {
    func testFeedbackButtonsExposeTheirVisibleShortcutHints() {
        XCTAssertEqual(
            PronunciationShortcut.allCases.map(\.hint),
            ["⌘R", "⌘A", "⌘V", "↩"]
        )
    }

    func testUtilityActionsUseCommandAndNextUsesReturn() {
        XCTAssertEqual(
            PronunciationShortcut.allCases.map(\.usesCommand),
            [true, true, true, false]
        )
    }
}
