import SwiftUI

enum TraceStructure {
    case list(TraceList)
    case tree(TraceTree)
    case array([TraceValue])
    case graph([[Int]])
    case dictionary([DictionaryEntry])
}

struct DataJourneyStructureCanvasView: View {
    let inputEvent: DataJourneyEvent?
    let selectedEvent: DataJourneyEvent?

    var body: some View {
        guard let structure else {
            return AnyView(EmptyView())
        }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Structure")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray400)

                switch structure {
                case .list(let list):
                    SequenceBubbleRow(
                        items: list.nodes.map(\.value),
                        showIndices: false,
                        cycleIndex: list.cycleIndex,
                        isTruncated: list.isTruncated,
                        isDoubly: list.isDoubly,
                        pointers: pointerMarkers
                    )
                case .tree(let tree):
                    TreeGraphView(tree: tree, pointers: pointerMarkers)
                case .array(let items):
                    SequenceBubbleRow(
                        items: items,
                        showIndices: true,
                        cycleIndex: nil,
                        isTruncated: false,
                        isDoubly: false,
                        pointers: pointerMarkers
                    )
                case .graph(let adjacency):
                    GraphView(adjacency: adjacency, pointers: pointerMarkers)
                case .dictionary(let entries):
                    DictionaryStructureRow(entries: entries, pointers: pointerMarkers)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appGray900.opacity(0.45))
            )
        )
    }

    private var structure: TraceStructure? {
        if let fromInput = structure(in: inputEvent) { return fromInput }
        return structure(in: selectedEvent)
    }

    private func structure(in event: DataJourneyEvent?) -> TraceStructure? {
        guard let event else { return nil }
        for key in event.values.keys.sorted() {
            guard let value = event.values[key] else { continue }
            switch value {
            case .list(let list):
                return .list(list)
            case .tree(let tree):
                return .tree(tree)
            case .array(let items):
                if let adjacency = graphAdjacency(from: items) {
                    return .graph(adjacency)
                }
                return .array(items)
            case .object(let map):
                return .dictionary(dictionaryEntries(from: map))
            default:
                continue
            }
        }
        return nil
    }

    private var pointerMarkers: [PointerMarker] {
        guard let selectedEvent, let structure else { return [] }
        switch structure {
        case .list(let list):
            return listPointers(in: selectedEvent, list: list)
        case .tree:
            return treePointers(in: selectedEvent)
        case .array(let items):
            return arrayPointers(in: selectedEvent, items: items)
        case .graph(let adjacency):
            return graphPointers(in: selectedEvent, adjacency: adjacency)
        case .dictionary(let entries):
            return dictionaryPointers(in: selectedEvent, entries: entries)
        }
    }

    private func listPointers(in event: DataJourneyEvent, list: TraceList) -> [PointerMarker] {
        var idToIndex: [String: Int] = [:]
        for (index, node) in list.nodes.enumerated() {
            idToIndex[node.id] = index
        }
        return event.values.compactMap { key, value in
            guard case .listPointer(let id) = value,
                  let index = idToIndex[id] else { return nil }
            return PointerMarker(name: key, index: index)
        }
        .sorted { $0.name < $1.name }
    }

    private func treePointers(in event: DataJourneyEvent) -> [PointerMarker] {
        event.values.compactMap { key, value in
            guard case .treePointer(let id) = value else { return nil }
            return PointerMarker(name: key, nodeId: id)
        }
        .sorted { $0.name < $1.name }
    }

    private func arrayPointers(in event: DataJourneyEvent, items: [TraceValue]) -> [PointerMarker] {
        event.values.compactMap { key, value in
            guard case .number(let number, let isInt) = value, isInt else { return nil }
            let index = Int(number)
            guard items.indices.contains(index), isIndexName(key) else { return nil }
            return PointerMarker(name: key, index: index)
        }
        .sorted { $0.name < $1.name }
    }

    private func graphPointers(in event: DataJourneyEvent, adjacency: [[Int]]) -> [PointerMarker] {
        event.values.compactMap { key, value in
            guard case .number(let number, let isInt) = value, isInt else { return nil }
            let index = Int(number)
            guard adjacency.indices.contains(index), isIndexName(key) else { return nil }
            return PointerMarker(name: key, index: index)
        }
        .sorted { $0.name < $1.name }
    }

    private func dictionaryPointers(in event: DataJourneyEvent, entries: [DictionaryEntry]) -> [PointerMarker] {
        let keyToIndex = Dictionary(uniqueKeysWithValues: entries.enumerated().map { ($0.element.key, $0.offset) })
        return event.values.compactMap { key, value in
            switch value {
            case .string(let stringValue):
                guard let index = keyToIndex[stringValue] else { return nil }
                return PointerMarker(name: key, index: index)
            case .number(let number, let isInt):
                guard isInt else { return nil }
                let stringValue = "\(Int(number))"
                guard let index = keyToIndex[stringValue] else { return nil }
                return PointerMarker(name: key, index: index)
            default:
                return nil
            }
        }
        .sorted { $0.name < $1.name }
    }

    private func isIndexName(_ name: String) -> Bool {
        let lowered = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if lowered.hasSuffix("index") { return true }
        let allowed = ["i", "j", "k", "idx", "index", "left", "right", "mid", "lo", "hi", "start", "end"]
        return allowed.contains(lowered)
    }

    private func graphAdjacency(from items: [TraceValue]) -> [[Int]]? {
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

    private func dictionaryEntries(from map: [String: TraceValue]) -> [DictionaryEntry] {
        map.keys.sorted().compactMap { key in
            guard let value = map[key] else { return nil }
            return DictionaryEntry(key: key, value: value)
        }
    }
}

struct DictionaryEntry: Identifiable {
    let id = UUID()
    let key: String
    let value: TraceValue
}

struct DictionaryStructureRow: View {
    let entries: [DictionaryEntry]
    let pointers: [PointerMarker]

    private let pointerSpacing: CGFloat = 2
    private let pointerHeight: CGFloat = 14

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    let model = TraceBubbleModel.from(entry.value)
                    let pointerStack = pointersByIndex[index] ?? []
                    VStack(spacing: 4) {
                        ZStack(alignment: .top) {
                            HStack(spacing: 6) {
                                TraceBubble(text: entry.key, fill: Color.appGray700)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color.appPurple.opacity(0.8))
                                TraceBubble(text: model.text, fill: model.fill)
                            }
                            if !pointerStack.isEmpty {
                                VStack(spacing: pointerSpacing) {
                                    ForEach(pointerStack) { pointer in
                                        PointerBadge(text: pointer.name, color: pointer.color)
                                            .frame(height: pointerHeight)
                                    }
                                }
                                .offset(y: -18)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var pointersByIndex: [Int: [PointerMarker]] {
        var grouped: [Int: [PointerMarker]] = [:]
        for pointer in pointers {
            guard let index = pointer.index else { continue }
            grouped[index, default: []].append(pointer)
        }
        return grouped
    }
}
