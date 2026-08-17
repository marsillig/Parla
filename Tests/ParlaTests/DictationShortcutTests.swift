import XCTest
@testable import Parla

final class DictationShortcutTests: XCTestCase {
    func testButtonsExposeTheirVisibleShortcutHints() {
        XCTAssertEqual(
            DictationShortcut.allCases.map(\.hint),
            ["⌘A", "⌘L", "⌘R", "⌘R", "↩", "↩"]
        )
    }

    func testCommandActionsAndReturnActionsUseTheExpectedModifiers() {
        XCTAssertEqual(
            DictationShortcut.allCases.map(\.usesCommand),
            [true, true, true, true, false, false]
        )
    }
}
