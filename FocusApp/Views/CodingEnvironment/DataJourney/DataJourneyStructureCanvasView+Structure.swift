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
            if case .list(let list) = value {
                lists.append(NamedTraceList(name: key, list: list))
                continue
            }
            if case .array(let items) = value {
                if let listArray = listArrayStructure(from: items) {
                    return .listArray(listArray)
                }
                if let adjacency = graphAdjacency(from: items) {
                    fallback = fallback ?? .graph(adjacency)
                } else {
                    fallback = fallback ?? .array(items)
                }
                continue
            }
            if case .tree(let tree) = value {
                fallback = fallback ?? .tree(tree)
                continue
            }
            if case .object(let map) = value {
                fallback = fallback ?? .dictionary(dictionaryEntries(from: map))
            }
        }
        return finalizeStructure(lists: lists, fallback: fallback)
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
}
