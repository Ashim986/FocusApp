import SwiftUI

extension DataJourneyStructureCanvasView {
    private enum StructureSource: Int {
        // When step events only contain pointers (no structured list snapshots),
        // prefer rendering the input structure over output on tie, so pointer motion
        // reads left-to-right from the original input.
        case output = 1
        case input = 2
        case selected = 3
    }

    private struct StructureCandidate {
        let source: StructureSource
        let structure: TraceStructure
    }

    private struct PointerStructureMatch {
        let coverage: Int
        let source: Int
        let structure: TraceStructure
    }

    var structure: TraceStructure? {
        if let structureOverride { return structureOverride }
        let candidates = structureCandidates()
        guard !candidates.isEmpty else { return nil }

        if let selectedEvent {
            let selectedPointers = pointerCandidates(in: selectedEvent)
            if !selectedPointers.isEmpty,
               let resolved = bestPointerStructure(
                   from: candidates,
                   pointerCandidates: selectedPointers
               ) {
                return resolved
            }
        }

        return fallbackStructure(from: candidates)
    }

    private func structureCandidates() -> [StructureCandidate] {
        var candidates: [StructureCandidate] = []
        if let structure = Self.structure(in: selectedEvent) {
            candidates.append(StructureCandidate(source: .selected, structure: structure))
        }
        if let structure = Self.structure(in: outputEvent) {
            candidates.append(StructureCandidate(source: .output, structure: structure))
        }
        if let structure = Self.structure(in: inputEvent) {
            candidates.append(StructureCandidate(source: .input, structure: structure))
        }
        return candidates
    }

    private func bestPointerStructure(
        from candidates: [StructureCandidate],
        pointerCandidates: [(name: String, value: TraceValue)]
    ) -> TraceStructure? {
        var best: PointerStructureMatch?
        for candidate in candidates {
            let coverage = pointerCoverage(
                of: candidate.structure,
                pointerCandidates: pointerCandidates
            )
            guard coverage > 0 else { continue }
            let sourcePriority = candidate.source.rawValue
            if let currentBest = best {
                if coverage > currentBest.coverage ||
                    (coverage == currentBest.coverage && sourcePriority > currentBest.source) {
                    best = PointerStructureMatch(
                        coverage: coverage,
                        source: sourcePriority,
                        structure: candidate.structure
                    )
                }
            } else {
                best = PointerStructureMatch(
                    coverage: coverage,
                    source: sourcePriority,
                    structure: candidate.structure
                )
            }
        }
        return best?.structure
    }

    private func fallbackStructure(from candidates: [StructureCandidate]) -> TraceStructure? {
        if let selected = candidates.first(where: { $0.source == .selected }) {
            return selected.structure
        }
        if let input = candidates.first(where: { $0.source == .input }) {
            return input.structure
        }
        if let output = candidates.first(where: { $0.source == .output }) {
            return output.structure
        }
        return nil
    }

    private func pointerCoverage(
        of structure: TraceStructure,
        pointerCandidates: [(name: String, value: TraceValue)]
    ) -> Int {
        let listNodeIDs = listNodeIDs(in: structure)
        let treeNodeIDs = treeNodeIDs(in: structure)

        var resolvedCount = 0
        for candidate in pointerCandidates {
            switch candidate.value {
            case .listPointer(let id):
                if listNodeIDs.contains(id) {
                    resolvedCount += 1
                }
            case .treePointer(let id):
                if treeNodeIDs.contains(id) {
                    resolvedCount += 1
                }
            default:
                break
            }
        }
        return resolvedCount
    }

    private func listNodeIDs(in structure: TraceStructure) -> Set<String> {
        switch structure {
        case .list(let list):
            return Set(list.nodes.map(\.id))
        case .listGroup(let lists):
            return Set(lists.flatMap { $0.list.nodes.map(\.id) })
        case .listArray(let listArray):
            return Set(listArray.lists.flatMap { $0.list.nodes.map(\.id) })
        default:
            return []
        }
    }

    private func treeNodeIDs(in structure: TraceStructure) -> Set<String> {
        switch structure {
        case .tree(let tree):
            return Set(tree.nodes.map(\.id))
        default:
            return []
        }
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
            if handleTrie(value: value, fallback: &fallback) { continue }
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
        if lowered == "minheap" || lowered == "min-heap" || lowered == "min_heap" {
            fallback = fallback ?? .heap(typedItems, isMinHeap: true)
            return true
        }
        if lowered == "maxheap" || lowered == "max-heap" || lowered == "max_heap" {
            fallback = fallback ?? .heap(typedItems, isMinHeap: false)
            return true
        }
        if lowered == "heap" {
            fallback = fallback ?? .heap(typedItems, isMinHeap: true)
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
        if loweredName.contains("heap") {
            let isMin = loweredName.contains("min")
            fallback = fallback ?? .heap(items, isMinHeap: isMin || !loweredName.contains("max"))
            return true
        }
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

    private static func handleTrie(
        value: TraceValue,
        fallback: inout TraceStructure?
    ) -> Bool {
        guard case .trie(let trieData) = value else { return false }
        fallback = fallback ?? .trie(trieData)
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
        guard stringValue.count >= 2 else { return false }
        let chars = stringValue.map { TraceValue.string(String($0)) }
        fallback = fallback ?? .stringSequence(stringValue, chars)
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
