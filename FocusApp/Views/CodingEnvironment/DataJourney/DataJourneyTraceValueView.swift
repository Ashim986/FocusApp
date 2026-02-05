import SwiftUI

struct TraceValueView: View {
    let value: TraceValue

    var body: some View {
        switch value {
        case .null:
            bubble(for: value)
        case .bool(let boolValue):
            bubble(for: .bool(boolValue))
        case .number(let number, let isInt):
            bubble(for: .number(number, isInt: isInt))
        case .string(let stringValue):
            bubble(for: .string(stringValue))
        case .array(let items):
            arrayView(items)
        case .object(let map):
            objectView(map)
        case .list(let list):
            listView(list)
        case .listPointer:
            bubble(for: .string("ptr"))
        case .tree(let tree):
            treeView(tree)
        case .treePointer:
            bubble(for: .string("ptr"))
        case .typed(let type, let inner):
            typedView(type: type, value: inner)
        }
    }

    @ViewBuilder
    private func arrayView(_ items: [TraceValue]) -> some View {
        if let adjacency = adjacencyList(from: items) {
            GraphView(adjacency: adjacency)
        } else {
            sequenceView(items, showIndices: true)
        }
    }

    private func objectView(_ map: [String: TraceValue]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(map.keys.sorted(), id: \.self) { key in
                if let value = map[key] {
                    HStack(spacing: 6) {
                        Text(key)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color.appGray400)
                        TraceValueView(value: value)
                    }
                }
            }
        }
    }

    private func typedView(type: String, value: TraceValue) -> some View {
        switch type.lowercased() {
        case "list":
            return AnyView(listView(value))
        case "tree":
            return AnyView(treeView(value))
        default:
            return AnyView(TraceValueView(value: value))
        }
    }

    private func listView(_ value: TraceValue) -> some View {
        guard case .array(let items) = value else {
            return AnyView(TraceValueView(value: value))
        }
        return AnyView(
            sequenceView(items, showIndices: false)
        )
    }

    private func listView(_ list: TraceList) -> some View {
        let items = list.nodes.map(\.value)
        return sequenceView(
            items,
            showIndices: false,
            cycleIndex: list.cycleIndex,
            isTruncated: list.isTruncated
        )
    }

    private func treeView(_ value: TraceValue) -> some View {
        guard case .array(let items) = value else {
            return AnyView(TraceValueView(value: value))
        }
        let legacyTree = TraceTree.fromLevelOrder(items)
        return AnyView(TreeGraphView(tree: legacyTree, pointers: []))
    }

    private func treeView(_ tree: TraceTree) -> some View {
        AnyView(TreeGraphView(tree: tree, pointers: []))
    }

    private func sequenceView(
        _ items: [TraceValue],
        showIndices: Bool,
        cycleIndex: Int? = nil,
        isTruncated: Bool = false
    ) -> some View {
        SequenceBubbleRow(
            items: items,
            showIndices: showIndices,
            cycleIndex: cycleIndex,
            isTruncated: isTruncated,
            pointers: []
        )
    }

    private func bubble(for value: TraceValue) -> some View {
        let model = TraceBubbleModel.from(value)
        return TraceBubble(text: model.text, fill: model.fill)
    }

    private func adjacencyList(from items: [TraceValue]) -> [[Int]]? {
        guard !items.isEmpty else { return nil }
        var lists: [[Int]] = []
        var allCounts: [Int] = []

        for item in items {
            guard case .array(let inner) = item else { return nil }
            var neighbors: [Int] = []
            for value in inner {
                guard case .number(let number, let isInt) = value else { return nil }
                let intValue = Int(number)
                if isInt == false, Double(intValue) != number { return nil }
                neighbors.append(intValue)
            }
            lists.append(neighbors)
            allCounts.append(inner.count)
        }

        let nodeCount = items.count
        if allCounts.allSatisfy({ $0 == nodeCount }) {
            let matrixValues = lists.flatMap { $0 }
            if matrixValues.allSatisfy({ $0 == 0 || $0 == 1 }) {
                return nil
            }
        }

        return lists
    }
}
