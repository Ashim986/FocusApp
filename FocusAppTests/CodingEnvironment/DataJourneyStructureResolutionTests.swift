@testable import FocusApp
import XCTest

final class DataJourneyStructureResolutionTests: XCTestCase {
    func testStructurePrefersCandidateWithPointerCoverage() {
        let inputList = makeList([1, 2], ids: ["in0", "in1"])
        let outputList = makeList([7, 8], ids: ["out0", "out1"])
        let inputEvent = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: ["head": .list(inputList)]
        )
        let selectedEvent = DataJourneyEvent(
            kind: .step,
            line: 10,
            label: "loop",
            values: ["curr": .listPointer("out0")]
        )
        let outputEvent = DataJourneyEvent(
            kind: .output,
            line: nil,
            label: nil,
            values: ["result": .list(outputList)]
        )

        let view = DataJourneyStructureCanvasView(
            inputEvent: inputEvent,
            selectedEvent: selectedEvent,
            outputEvent: outputEvent
        )

        guard case .list(let resolvedList) = view.structure else {
            XCTFail("Expected list structure")
            return
        }
        XCTAssertEqual(resolvedList.nodes.first?.id, "out0")
    }

    func testStructureFallsBackToSelectedWhenNoPointerHints() {
        let inputList = makeList([1], ids: ["in0"])
        let selectedList = makeList([9], ids: ["sel0"])
        let inputEvent = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: ["head": .list(inputList)]
        )
        let selectedEvent = DataJourneyEvent(
            kind: .step,
            line: 20,
            label: "step",
            values: [
                "head": .list(selectedList),
                "i": .number(0, isInt: true)
            ]
        )

        let view = DataJourneyStructureCanvasView(
            inputEvent: inputEvent,
            selectedEvent: selectedEvent
        )

        guard case .list(let resolvedList) = view.structure else {
            XCTFail("Expected list structure")
            return
        }
        XCTAssertEqual(resolvedList.nodes.first?.id, "sel0")
    }

    func testOffGraphPointerBadgesContainOnlyUnresolvedPointers() {
        let inputList = makeList([1, 2], ids: ["in0", "in1"])
        let inputEvent = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: ["head": .list(inputList)]
        )
        let selectedEvent = DataJourneyEvent(
            kind: .step,
            line: 30,
            label: "step",
            values: [
                "head": .listPointer("in0"),
                "curr": .listPointer("missing")
            ]
        )
        let view = DataJourneyStructureCanvasView(
            inputEvent: inputEvent,
            selectedEvent: selectedEvent
        )

        guard let structure = view.structure else {
            XCTFail("Expected structure")
            return
        }

        let offGraph = view.offGraphPointerBadges(for: structure)
        let names = offGraph.map(\.name)
        XCTAssertTrue(names.contains("curr"))
        XCTAssertFalse(names.contains("head"))
    }

    private func makeList(_ values: [Int], ids: [String]) -> TraceList {
        let nodes = values.enumerated().map { index, value in
            TraceListNode(
                id: ids[index],
                value: .number(Double(value), isInt: true)
            )
        }
        return TraceList(nodes: nodes, cycleIndex: nil, isTruncated: false, isDoubly: false)
    }
}
