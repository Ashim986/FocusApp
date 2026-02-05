import SwiftUI

enum TraceStructure {
    case list(TraceList)
    case tree(TraceTree)
    case array([TraceValue])
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
                        pointers: pointerMarkers
                    )
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
                return .array(items)
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

    private func isIndexName(_ name: String) -> Bool {
        let lowered = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if lowered.hasSuffix("index") { return true }
        let allowed = ["i", "j", "k", "idx", "index", "left", "right", "mid", "lo", "hi", "start", "end"]
        return allowed.contains(lowered)
    }
}
