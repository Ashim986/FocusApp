@testable import FocusApp
import XCTest

final class DataJourneyPointerMotionTests: XCTestCase {
    func testTreePointerMotionCapturesNestedPointers() {
        let previous = DataJourneyEvent(
            kind: .step,
            line: nil,
            label: "prev",
            values: [
                "meta": .object([
                    "slow": .treePointer("a")
                ])
            ]
        )
        let current = DataJourneyEvent(
            kind: .step,
            line: nil,
            label: "curr",
            values: [
                "meta": .object([
                    "slow": .treePointer("b")
                ])
            ]
        )
        let view = DataJourneyStructureCanvasView(inputEvent: nil, selectedEvent: current)

        let motions = view.treePointerMotions(from: previous, to: current)

        XCTAssertEqual(motions.count, 1)
        XCTAssertEqual(motions[0].name, "meta.slow")
        XCTAssertEqual(motions[0].fromId, "a")
        XCTAssertEqual(motions[0].toId, "b")
    }
}
