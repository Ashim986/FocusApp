@testable import FocusApp
import XCTest

final class DataJourneyStructureDetectionTests: XCTestCase {
    func testStructureDetectsListGroup() {
        let list1 = makeList([1, 2], prefix: "a")
        let list2 = makeList([3], prefix: "b")
        let event = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: [
                "list1": .list(list1),
                "list2": .list(list2)
            ]
        )

        let structure = DataJourneyStructureCanvasView.structure(in: event)

        guard case .listGroup(let lists) = structure else {
            XCTFail("Expected listGroup structure")
            return
        }
        XCTAssertEqual(lists.count, 2)
    }

    func testStructureDetectsListArray() {
        let list1 = makeList([1], prefix: "a")
        let list2 = makeList([2], prefix: "b")
        let arrayValue: TraceValue = .array([.list(list1), .null, .list(list2)])
        let event = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: ["lists": arrayValue]
        )

        let structure = DataJourneyStructureCanvasView.structure(in: event)

        guard case .listArray(let listArray) = structure else {
            XCTFail("Expected listArray structure")
            return
        }
        XCTAssertEqual(listArray.lists.count, 3)
        XCTAssertEqual(listArray.heads.count, 3)
    }

    func testStructureDetectsGraphAdjacency() {
        let row1: TraceValue = .array([.number(0, isInt: true), .number(1, isInt: true)])
        let row2: TraceValue = .array([.number(1, isInt: true), .number(0, isInt: true)])
        let event = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: ["graph": .array([row1, row2])]
        )

        let structure = DataJourneyStructureCanvasView.structure(in: event)

        guard case .graph(let adjacency) = structure else {
            XCTFail("Expected graph structure")
            return
        }
        XCTAssertEqual(adjacency.count, 2)
    }

    func testStructureDetectsDictionary() {
        let map: [String: TraceValue] = [
            "a": .number(1, isInt: true),
            "b": .string("x")
        ]
        let event = DataJourneyEvent(
            kind: .input,
            line: nil,
            label: nil,
            values: ["dict": .object(map)]
        )

        let structure = DataJourneyStructureCanvasView.structure(in: event)

        guard case .dictionary(let entries) = structure else {
            XCTFail("Expected dictionary structure")
            return
        }
        XCTAssertEqual(entries.count, 2)
    }

    private func makeList(_ values: [Int], prefix: String) -> TraceList {
        let nodes = values.enumerated().map { index, value in
            TraceListNode(
                id: "\(prefix)\(index)",
                value: .number(Double(value), isInt: true)
            )
        }
        return TraceList(nodes: nodes, cycleIndex: nil, isTruncated: false, isDoubly: false)
    }
}
