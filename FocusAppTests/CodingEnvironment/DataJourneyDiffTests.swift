@testable import FocusApp
import XCTest

// swiftlint:disable type_body_length
final class DataJourneyDiffTests: XCTestCase {

    // MARK: - Helpers

    /// Creates a DataJourneyEvent with the given values dictionary.
    private func makeEvent(
        kind: DataJourneyEventKind = .step,
        values: [String: TraceValue]
    ) -> DataJourneyEvent {
        DataJourneyEvent(kind: kind, line: nil, label: nil, values: values)
    }

    // MARK: - changedKeys

    func testChangedKeysNilPreviousReturnsAllCurrentKeys() {
        let current = makeEvent(values: ["a": .number(1, isInt: true), "b": .string("hi")])
        let result = TraceValueDiff.changedKeys(previous: nil, current: current)
        XCTAssertEqual(result, ["a", "b"])
    }

    func testChangedKeysNilCurrentReturnsEmpty() {
        let previous = makeEvent(values: ["a": .number(1, isInt: true)])
        let result = TraceValueDiff.changedKeys(previous: previous, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedKeysBothNilReturnsEmpty() {
        let result = TraceValueDiff.changedKeys(previous: nil, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedKeysIdenticalEventsReturnsEmpty() {
        let event1 = makeEvent(values: ["x": .number(5, isInt: true), "y": .bool(true)])
        let event2 = makeEvent(values: ["x": .number(5, isInt: true), "y": .bool(true)])
        let result = TraceValueDiff.changedKeys(previous: event1, current: event2)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedKeysSomeValuesChanged() {
        let previous = makeEvent(values: [
            "a": .number(1, isInt: true),
            "b": .string("old"),
            "c": .bool(true)
        ])
        let current = makeEvent(values: [
            "a": .number(1, isInt: true),
            "b": .string("new"),
            "c": .bool(true)
        ])
        let result = TraceValueDiff.changedKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["b"])
    }

    func testChangedKeysNewKeyAdded() {
        let previous = makeEvent(values: ["a": .number(1, isInt: true)])
        let current = makeEvent(values: [
            "a": .number(1, isInt: true),
            "b": .string("new")
        ])
        let result = TraceValueDiff.changedKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["b"])
    }

    func testChangedKeysKeyRemoved() {
        let previous = makeEvent(values: [
            "a": .number(1, isInt: true),
            "b": .string("gone")
        ])
        let current = makeEvent(values: ["a": .number(1, isInt: true)])
        let result = TraceValueDiff.changedKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["b"])
    }

    func testChangedKeysMultipleChanges() {
        let previous = makeEvent(values: [
            "a": .number(1, isInt: true),
            "b": .string("old")
        ])
        let current = makeEvent(values: [
            "a": .number(2, isInt: true),
            "c": .bool(false)
        ])
        let result = TraceValueDiff.changedKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["a", "b", "c"])
    }

    // MARK: - changedIndices

    func testChangedIndicesNilValuesReturnsEmpty() {
        let result = TraceValueDiff.changedIndices(previous: nil, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedIndicesNilPreviousReturnsAllIndices() {
        let current = TraceValue.array([.number(1, isInt: true), .number(2, isInt: true)])
        let result = TraceValueDiff.changedIndices(previous: nil, current: current)
        XCTAssertEqual(result, [0, 1])
    }

    func testChangedIndicesEqualArraysReturnsEmpty() {
        let array = TraceValue.array([.number(1, isInt: true), .number(2, isInt: true)])
        let result = TraceValueDiff.changedIndices(previous: array, current: array)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedIndicesSingleElementChanged() {
        let previous = TraceValue.array([.number(1, isInt: true), .number(2, isInt: true), .number(3, isInt: true)])
        let current = TraceValue.array([.number(1, isInt: true), .number(99, isInt: true), .number(3, isInt: true)])
        let result = TraceValueDiff.changedIndices(previous: previous, current: current)
        XCTAssertEqual(result, [1])
    }

    func testChangedIndicesDifferentLengthsShorterPrevious() {
        let previous = TraceValue.array([.number(1, isInt: true)])
        let current = TraceValue.array([.number(1, isInt: true), .number(2, isInt: true)])
        let result = TraceValueDiff.changedIndices(previous: previous, current: current)
        XCTAssertEqual(result, [1])
    }

    func testChangedIndicesDifferentLengthsShorterCurrent() {
        let previous = TraceValue.array([.number(1, isInt: true), .number(2, isInt: true)])
        let current = TraceValue.array([.number(1, isInt: true)])
        let result = TraceValueDiff.changedIndices(previous: previous, current: current)
        XCTAssertEqual(result, [1])
    }

    func testChangedIndicesNestedArrays() {
        let inner1 = TraceValue.array([.number(10, isInt: true)])
        let inner2 = TraceValue.array([.number(20, isInt: true)])
        let previous = TraceValue.array([inner1, .string("same")])
        let current = TraceValue.array([inner2, .string("same")])
        let result = TraceValueDiff.changedIndices(previous: previous, current: current)
        XCTAssertEqual(result, [0])
    }

    func testChangedIndicesTypedWrapper() {
        let innerPrev = TraceValue.array([.number(1, isInt: true), .number(2, isInt: true)])
        let innerCurr = TraceValue.array([.number(1, isInt: true), .number(3, isInt: true)])
        let previous = TraceValue.typed("List[int]", innerPrev)
        let current = TraceValue.typed("List[int]", innerCurr)
        let result = TraceValueDiff.changedIndices(previous: previous, current: current)
        XCTAssertEqual(result, [1])
    }

    func testChangedIndicesNonArrayReturnsEmpty() {
        let previous = TraceValue.string("not an array")
        let current = TraceValue.number(42, isInt: true)
        let result = TraceValueDiff.changedIndices(previous: previous, current: current)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - changedNodeIds

    func testChangedNodeIdsNilValuesReturnsEmpty() {
        let result = TraceValueDiff.changedNodeIds(previous: nil, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedNodeIdsSameListReturnsEmpty() {
        let list = TraceValue.list(TraceList(
            nodes: [
                TraceListNode(id: "n1", value: .number(10, isInt: true)),
                TraceListNode(id: "n2", value: .number(20, isInt: true))
            ],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let result = TraceValueDiff.changedNodeIds(previous: list, current: list)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedNodeIdsNodeValueChanged() {
        let previous = TraceValue.list(TraceList(
            nodes: [
                TraceListNode(id: "n1", value: .number(10, isInt: true)),
                TraceListNode(id: "n2", value: .number(20, isInt: true))
            ],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let current = TraceValue.list(TraceList(
            nodes: [
                TraceListNode(id: "n1", value: .number(10, isInt: true)),
                TraceListNode(id: "n2", value: .number(99, isInt: true))
            ],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let result = TraceValueDiff.changedNodeIds(previous: previous, current: current)
        XCTAssertEqual(result, ["n2"])
    }

    func testChangedNodeIdsNodeAdded() {
        let previous = TraceValue.list(TraceList(
            nodes: [TraceListNode(id: "n1", value: .number(10, isInt: true))],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let current = TraceValue.list(TraceList(
            nodes: [
                TraceListNode(id: "n1", value: .number(10, isInt: true)),
                TraceListNode(id: "n2", value: .number(20, isInt: true))
            ],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let result = TraceValueDiff.changedNodeIds(previous: previous, current: current)
        XCTAssertEqual(result, ["n2"])
    }

    func testChangedNodeIdsNodeRemoved() {
        let previous = TraceValue.list(TraceList(
            nodes: [
                TraceListNode(id: "n1", value: .number(10, isInt: true)),
                TraceListNode(id: "n2", value: .number(20, isInt: true))
            ],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let current = TraceValue.list(TraceList(
            nodes: [TraceListNode(id: "n1", value: .number(10, isInt: true))],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let result = TraceValueDiff.changedNodeIds(previous: previous, current: current)
        XCTAssertEqual(result, ["n2"])
    }

    func testChangedNodeIdsTypedWrapper() {
        let innerPrev = TraceValue.list(TraceList(
            nodes: [TraceListNode(id: "n1", value: .number(1, isInt: true))],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let innerCurr = TraceValue.list(TraceList(
            nodes: [TraceListNode(id: "n1", value: .number(2, isInt: true))],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let previous = TraceValue.typed("LinkedList", innerPrev)
        let current = TraceValue.typed("LinkedList", innerCurr)
        let result = TraceValueDiff.changedNodeIds(previous: previous, current: current)
        XCTAssertEqual(result, ["n1"])
    }

    func testChangedNodeIdsNonListReturnsEmpty() {
        let previous = TraceValue.string("not a list")
        let current = TraceValue.number(42, isInt: true)
        let result = TraceValueDiff.changedNodeIds(previous: previous, current: current)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedNodeIdsNilPreviousReturnsAllCurrentIds() {
        let current = TraceValue.list(TraceList(
            nodes: [
                TraceListNode(id: "n1", value: .number(10, isInt: true)),
                TraceListNode(id: "n2", value: .number(20, isInt: true))
            ],
            cycleIndex: nil,
            isTruncated: false,
            isDoubly: false
        ))
        let result = TraceValueDiff.changedNodeIds(previous: nil, current: current)
        XCTAssertEqual(result, ["n1", "n2"])
    }

    // MARK: - changedTreeNodeIds

    func testChangedTreeNodeIdsNilValuesReturnsEmpty() {
        let result = TraceValueDiff.changedTreeNodeIds(previous: nil, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedTreeNodeIdsSameTreeReturnsEmpty() {
        let tree = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: "l", right: "rr"),
                TraceTreeNode(id: "l", value: .number(2, isInt: true), left: nil, right: nil),
                TraceTreeNode(id: "rr", value: .number(3, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let result = TraceValueDiff.changedTreeNodeIds(previous: tree, current: tree)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedTreeNodeIdsNodeValueChanged() {
        let previous = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let current = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(99, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let result = TraceValueDiff.changedTreeNodeIds(previous: previous, current: current)
        XCTAssertEqual(result, ["r"])
    }

    func testChangedTreeNodeIdsChildrenChanged() {
        let previous = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let current = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: "l", right: nil),
                TraceTreeNode(id: "l", value: .number(2, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let result = TraceValueDiff.changedTreeNodeIds(previous: previous, current: current)
        // "r" changed because its left child pointer changed, and "l" is new
        XCTAssertTrue(result.contains("r"))
        XCTAssertTrue(result.contains("l"))
    }

    func testChangedTreeNodeIdsNodeRemoved() {
        let previous = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: "l", right: nil),
                TraceTreeNode(id: "l", value: .number(2, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let current = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let result = TraceValueDiff.changedTreeNodeIds(previous: previous, current: current)
        XCTAssertTrue(result.contains("r"))
        XCTAssertTrue(result.contains("l"))
    }

    func testChangedTreeNodeIdsTypedWrapper() {
        let innerPrev = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let innerCurr = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(5, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let previous = TraceValue.typed("BinaryTree", innerPrev)
        let current = TraceValue.typed("BinaryTree", innerCurr)
        let result = TraceValueDiff.changedTreeNodeIds(previous: previous, current: current)
        XCTAssertEqual(result, ["r"])
    }

    func testChangedTreeNodeIdsNonTreeReturnsEmpty() {
        let previous = TraceValue.array([.number(1, isInt: true)])
        let current = TraceValue.array([.number(2, isInt: true)])
        let result = TraceValueDiff.changedTreeNodeIds(previous: previous, current: current)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedTreeNodeIdsNilPreviousReturnsAllCurrentIds() {
        let current = TraceValue.tree(TraceTree(
            nodes: [
                TraceTreeNode(id: "r", value: .number(1, isInt: true), left: "l", right: nil),
                TraceTreeNode(id: "l", value: .number(2, isInt: true), left: nil, right: nil)
            ],
            rootId: "r",
            isTruncated: false
        ))
        let result = TraceValueDiff.changedTreeNodeIds(previous: nil, current: current)
        XCTAssertEqual(result, ["r", "l"])
    }

    // MARK: - changedMatrixCells

    func testChangedMatrixCellsNilValuesReturnsEmpty() {
        let result = TraceValueDiff.changedMatrixCells(previous: nil, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedMatrixCellsSameMatrixReturnsEmpty() {
        let matrix = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)]),
            .array([.number(3, isInt: true), .number(4, isInt: true)])
        ])
        let result = TraceValueDiff.changedMatrixCells(previous: matrix, current: matrix)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedMatrixCellsSingleCellChanged() {
        let previous = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)]),
            .array([.number(3, isInt: true), .number(4, isInt: true)])
        ])
        let current = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)]),
            .array([.number(3, isInt: true), .number(99, isInt: true)])
        ])
        let result = TraceValueDiff.changedMatrixCells(previous: previous, current: current)
        XCTAssertEqual(result, [MatrixCell(row: 1, col: 1)])
    }

    func testChangedMatrixCellsRowLengthsDiffer() {
        let previous = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)])
        ])
        let current = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true), .number(3, isInt: true)])
        ])
        let result = TraceValueDiff.changedMatrixCells(previous: previous, current: current)
        XCTAssertEqual(result, [MatrixCell(row: 0, col: 2)])
    }

    func testChangedMatrixCellsRowCountDiffers() {
        let previous = TraceValue.array([
            .array([.number(1, isInt: true)])
        ])
        let current = TraceValue.array([
            .array([.number(1, isInt: true)]),
            .array([.number(2, isInt: true)])
        ])
        let result = TraceValueDiff.changedMatrixCells(previous: previous, current: current)
        XCTAssertEqual(result, [MatrixCell(row: 1, col: 0)])
    }

    func testChangedMatrixCellsTypedWrapper() {
        let innerPrev = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)])
        ])
        let innerCurr = TraceValue.array([
            .array([.number(1, isInt: true), .number(9, isInt: true)])
        ])
        let previous = TraceValue.typed("List[List[int]]", innerPrev)
        let current = TraceValue.typed("List[List[int]]", innerCurr)
        let result = TraceValueDiff.changedMatrixCells(previous: previous, current: current)
        XCTAssertEqual(result, [MatrixCell(row: 0, col: 1)])
    }

    func testChangedMatrixCellsNonMatrixReturnsEmpty() {
        let previous = TraceValue.string("not a matrix")
        let current = TraceValue.number(42, isInt: true)
        let result = TraceValueDiff.changedMatrixCells(previous: previous, current: current)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedMatrixCellsMultipleCellsChanged() {
        let previous = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)]),
            .array([.number(3, isInt: true), .number(4, isInt: true)])
        ])
        let current = TraceValue.array([
            .array([.number(10, isInt: true), .number(2, isInt: true)]),
            .array([.number(3, isInt: true), .number(40, isInt: true)])
        ])
        let result = TraceValueDiff.changedMatrixCells(previous: previous, current: current)
        XCTAssertEqual(result, [MatrixCell(row: 0, col: 0), MatrixCell(row: 1, col: 1)])
    }

    func testChangedMatrixCellsNilPreviousReturnsAllCells() {
        let current = TraceValue.array([
            .array([.number(1, isInt: true), .number(2, isInt: true)])
        ])
        let result = TraceValueDiff.changedMatrixCells(previous: nil, current: current)
        XCTAssertEqual(result, [MatrixCell(row: 0, col: 0), MatrixCell(row: 0, col: 1)])
    }

    // MARK: - changedDictKeys

    func testChangedDictKeysNilValuesReturnsEmpty() {
        let result = TraceValueDiff.changedDictKeys(previous: nil, current: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedDictKeysSameDictReturnsEmpty() {
        let dict = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .string("hello")
        ])
        let result = TraceValueDiff.changedDictKeys(previous: dict, current: dict)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedDictKeysValueChanged() {
        let previous = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .string("old")
        ])
        let current = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .string("new")
        ])
        let result = TraceValueDiff.changedDictKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["b"])
    }

    func testChangedDictKeysKeyAdded() {
        let previous = TraceValue.object(["a": .number(1, isInt: true)])
        let current = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .number(2, isInt: true)
        ])
        let result = TraceValueDiff.changedDictKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["b"])
    }

    func testChangedDictKeysKeyRemoved() {
        let previous = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .number(2, isInt: true)
        ])
        let current = TraceValue.object(["a": .number(1, isInt: true)])
        let result = TraceValueDiff.changedDictKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["b"])
    }

    func testChangedDictKeysTypedWrapper() {
        let innerPrev = TraceValue.object([
            "x": .number(1, isInt: true),
            "y": .number(2, isInt: true)
        ])
        let innerCurr = TraceValue.object([
            "x": .number(1, isInt: true),
            "y": .number(99, isInt: true)
        ])
        let previous = TraceValue.typed("Dict[str,int]", innerPrev)
        let current = TraceValue.typed("Dict[str,int]", innerCurr)
        let result = TraceValueDiff.changedDictKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["y"])
    }

    func testChangedDictKeysNonObjectReturnsEmpty() {
        let previous = TraceValue.array([.number(1, isInt: true)])
        let current = TraceValue.string("not a dict")
        let result = TraceValueDiff.changedDictKeys(previous: previous, current: current)
        XCTAssertTrue(result.isEmpty)
    }

    func testChangedDictKeysNilPreviousReturnsAllCurrentKeys() {
        let current = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .number(2, isInt: true)
        ])
        let result = TraceValueDiff.changedDictKeys(previous: nil, current: current)
        XCTAssertEqual(result, ["a", "b"])
    }

    func testChangedDictKeysMultipleChanges() {
        let previous = TraceValue.object([
            "a": .number(1, isInt: true),
            "b": .string("old"),
            "c": .bool(true)
        ])
        let current = TraceValue.object([
            "a": .number(2, isInt: true),
            "b": .string("old"),
            "d": .null
        ])
        let result = TraceValueDiff.changedDictKeys(previous: previous, current: current)
        XCTAssertEqual(result, ["a", "c", "d"])
    }
}
// swiftlint:enable type_body_length
