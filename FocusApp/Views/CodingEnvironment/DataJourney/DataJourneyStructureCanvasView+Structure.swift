import SwiftUI

extension DataJourneyStructureCanvasView {
    var structure: TraceStructure? {
        if let structureOverride { return structureOverride }
        if let fromInput = Self.structure(in: inputEvent) { return fromInput }
        return Self.structure(in: selectedEvent)
    }

    static func structure(in event: DataJourneyEvent?) -> TraceStructure? {
        guard let event else { return nil }
        let keys = event.values.keys.sorted()

        var lists: [NamedTraceList] = []
        var fallback: TraceStructure?
        for key in keys {
            guard let value = event.values[key] else { continue }
            if handleList(value: value, name: key, lists: &lists) { continue }
            if handleTyped(value: value, fallback: &fallback) { continue }
            if handleArray(value: value, name: key, fallback: &fallback) { continue }
            if handleTree(value: value, fallback: &fallback) { continue }
            if handleObject(value: value, fallback: &fallback) { continue }
            if handleString(value: value, fallback: &fallback) { continue }
        }
        return finalizeStructure(lists: lists, fallback: fallback)
    }

    private static func handleList(
        value: TraceValue,
        name: String,
        lists: inout [NamedTraceList]
    ) -> Bool {
        guard case .list(let list) = value else { return false }
        lists.append(NamedTraceList(name: name, list: list))
        return true
    }

    private static func handleTyped(
        value: TraceValue,
        fallback: inout TraceStructure?
    ) -> Bool {
        guard case .typed(let type, let inner) = value,
              let typedItems = typedSequenceItems(from: inner) else { return false }
        let lowered = type.lowercased()
        if lowered == "set" {
            fallback = fallback ?? .set(typedItems)
            return true
        }
        if lowered == "stack" {
            fallback = fallback ?? .stack(typedItems)
            return true
        }
        if lowered == "queue" {
            fallback = fallback ?? .queue(typedItems)
            return true
        }
        return false
    }

    private static func handleArray(
        value: TraceValue,
        name: String,
        fallback: inout TraceStructure?
    ) -> Bool {
        guard case .array(let items) = value else { return false }
        let loweredName = name.lowercased()
        if loweredName.contains("stack") {
            fallback = fallback ?? .stack(items)
            return true
        }
        if loweredName.contains("queue") {
            fallback = fallback ?? .queue(items)
            return true
        }
        if let listArray = listArrayStructure(from: items) {
            fallback = .listArray(listArray)
            return true
        }
        if let grid = matrixStructure(from: items, name: loweredName) {
            fallback = fallback ?? .matrix(grid)
            return true
        }
        if let adjacency = graphAdjacency(from: items) {
            fallback = fallback ?? .graph(adjacency)
        } else {
            fallback = fallback ?? .array(items)
        }
        return true
    }

    private static func handleTree(
        value: TraceValue,
        fallback: inout TraceStructure?
    ) -> Bool {
        guard case .tree(let tree) = value else { return false }
        fallback = fallback ?? .tree(tree)
        return true
    }

    private static func handleObject(
        value: TraceValue,
        fallback: inout TraceStructure?
    ) -> Bool {
        guard case .object(let map) = value else { return false }
        fallback = fallback ?? .dictionary(dictionaryEntries(from: map))
        return true
    }

    private static func handleString(
        value: TraceValue,
        fallback: inout TraceStructure?
    ) -> Bool {
        guard case .string(let stringValue) = value else { return false }
        let items = stringValue.map { TraceValue.string(String($0)) }
        fallback = fallback ?? .array(items)
        return true
    }

    private static func typedSequenceItems(from value: TraceValue) -> [TraceValue]? {
        switch value {
        case .array(let items):
            return items
        case .list(let list):
            return list.nodes.map(\.value)
        default:
            return nil
        }
    }

    private static func finalizeStructure(
        lists: [NamedTraceList],
        fallback: TraceStructure?
    ) -> TraceStructure? {
        if lists.count > 1 {
            return .listGroup(lists)
        }
        if let list = lists.first {
            return .list(list.list)
        }
        return fallback
    }

    static func graphAdjacency(from items: [TraceValue]) -> [[Int]]? {
        guard !items.isEmpty else { return nil }
        var rows: [[Int]] = []
        for item in items {
            guard case .array(let inner) = item else { return nil }
            var row: [Int] = []
            for value in inner {
                guard case .number(let number, let isInt) = value else { return nil }
                let intValue = Int(number)
                if !isInt && Double(intValue) != number { return nil }
                row.append(intValue)
            }
            rows.append(row)
        }
        let nodeCount = rows.count
        let isMatrix = rows.allSatisfy { $0.count == nodeCount } &&
            rows.flatMap { $0 }.allSatisfy { $0 == 0 || $0 == 1 }
        if isMatrix {
            var adjacency: [[Int]] = Array(repeating: [], count: nodeCount)
            for rowIndex in 0..<nodeCount {
                for colIndex in 0..<nodeCount where rows[rowIndex][colIndex] != 0 {
                    adjacency[rowIndex].append(colIndex)
                }
            }
            return adjacency
        }
        return rows
    }

    static func listArrayStructure(from items: [TraceValue]) -> ListArrayStructure? {
        guard !items.isEmpty else { return nil }
        var lists: [NamedTraceList] = []
        var heads: [TraceValue] = []
        for (index, item) in items.enumerated() {
            switch item {
            case .list(let list):
                lists.append(NamedTraceList(name: "list[\(index)]", list: list))
                heads.append(list.nodes.first?.value ?? .null)
            case .null:
                let emptyList = TraceList(nodes: [], cycleIndex: nil, isTruncated: false, isDoubly: false)
                lists.append(NamedTraceList(name: "list[\(index)]", list: emptyList))
                heads.append(.null)
            default:
                return nil
            }
        }
        return ListArrayStructure(heads: heads, lists: lists)
    }

    static func dictionaryEntries(from map: [String: TraceValue]) -> [DictionaryEntry] {
        map.keys.sorted().compactMap { key in
            guard let value = map[key] else { return nil }
            return DictionaryEntry(key: key, value: value)
        }
    }

    // MARK: - Matrix Detection

    static func matrixStructure(
        from items: [TraceValue],
        name: String
    ) -> [[TraceValue]]? {
        guard items.count >= 2 else { return nil }
        var rows: [[TraceValue]] = []
        for item in items {
            guard case .array(let inner) = item, !inner.isEmpty else { return nil }
            rows.append(inner)
        }
        let colCount = rows[0].count
        guard rows.allSatisfy({ $0.count == colCount }) else { return nil }
        let matrixNames = ["grid", "board", "matrix", "dp", "table", "maze", "map"]
        let nameHint = matrixNames.contains(where: { name.contains($0) })
        if nameHint { return rows }
        let allPrimitive = rows.allSatisfy { row in
            row.allSatisfy { isPrimitive($0) }
        }
        guard allPrimitive else { return nil }
        let allBinaryInt = rows.allSatisfy { row in
            row.allSatisfy { value in
                guard case .number(let num, let isInt) = value, isInt else { return false }
                return num == 0 || num == 1
            }
        }
        if allBinaryInt && colCount == rows.count {
            return nil
        }
        return rows
    }

    private static func isPrimitive(_ value: TraceValue) -> Bool {
        switch value {
        case .null, .bool, .number, .string:
            return true
        default:
            return false
        }
    }
}
