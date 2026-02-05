import SwiftUI

extension DataJourneyView {
    var content: some View {
        let structure = resolvedStructure
        return VStack(alignment: .leading, spacing: 10) {
            if let input = inputEvent {
                valuesSection(title: "Input", event: input, style: .compact)
            }

            if let structure {
                DataJourneyStructureCanvasView(
                    inputEvent: inputEvent,
                    selectedEvent: selectedEvent,
                    structureOverride: structure,
                    header: playbackEvents.isEmpty ? nil : AnyView(stepControlsHeader(style: .embedded)),
                    footer: playbackEvents.isEmpty ? nil : AnyView(stepControlsTimeline(style: .embedded))
                )
            } else if !playbackEvents.isEmpty {
                stepControls()
            }

            if let selected = selectedEvent {
                valuesSection(title: selectedTitle(for: selected), event: selected)
            }

            if let output = outputEvent {
                valuesSection(title: "Output", event: output)
            }
        }
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Run with input to see the data journey.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.appGray300)
            Text("Add `Trace.step(\"label\", [\"key\": value])` inside loops to visualize iterations.")
                .font(.system(size: 10))
                .foregroundColor(Color.appGray500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    enum ValuesSectionStyle {
        case standard
        case compact
    }

    func valuesSection(
        title: String,
        event: DataJourneyEvent,
        style: ValuesSectionStyle = .standard
    ) -> some View {
        let listContext = resolvedListContext()
        let isCompact = style == .compact
        let verticalPadding: CGFloat = isCompact ? 8 : 10
        let rowSpacing: CGFloat = isCompact ? 6 : 10
        let titleSize: CGFloat = isCompact ? 9 : 10
        let keyWidth: CGFloat = isCompact ? 70 : 80
        let infoSize: CGFloat = isCompact ? 9 : 10
        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: titleSize, weight: .semibold))
                .foregroundColor(Color.appGray400)

            if event.values.isEmpty {
                Text("No values captured for this step.")
                    .font(.system(size: infoSize))
                    .foregroundColor(Color.appGray500)
            } else {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(event.values.keys.sorted(), id: \.self) { key in
                        if let value = event.values[key] {
                            HStack(alignment: .center, spacing: 10) {
                                Text(key)
                                    .font(.system(size: infoSize, weight: .semibold))
                                    .foregroundColor(Color.appGray300)
                                    .frame(width: keyWidth, alignment: .leading)

                                valueView(for: value, listContext: listContext)
                            }
                        }
                    }
                }
            }
        }
        .padding(verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray900.opacity(0.45))
        )
    }

    private var resolvedStructure: TraceStructure? {
        if let fromInput = DataJourneyStructureCanvasView.structure(in: inputEvent) { return fromInput }
        return DataJourneyStructureCanvasView.structure(in: selectedEvent)
    }

    @ViewBuilder
    private func valueView(for value: TraceValue, listContext: TraceList?) -> some View {
        if case .listPointer(let id) = value,
           let listContext,
           let list = traceList(from: listContext, startingAt: id) {
            SequenceBubbleRow(
                items: list.nodes.map(\.value),
                showIndices: false,
                cycleIndex: list.cycleIndex,
                isTruncated: list.isTruncated,
                isDoubly: list.isDoubly,
                pointers: []
            )
        } else {
            TraceValueView(value: value)
        }
    }

    private func resolvedListContext() -> TraceList? {
        if let list = listStructure(in: inputEvent) { return list }
        if let list = listStructure(in: selectedEvent) { return list }
        return nil
    }

    private func listStructure(in event: DataJourneyEvent?) -> TraceList? {
        guard let event else { return nil }
        for key in event.values.keys.sorted() {
            if case .list(let list) = event.values[key] {
                return list
            }
        }
        return nil
    }

    private func traceList(from list: TraceList, startingAt nodeId: String, maxNodes: Int = 40) -> TraceList? {
        var idToIndex: [String: Int] = [:]
        for (index, node) in list.nodes.enumerated() {
            idToIndex[node.id] = index
        }
        guard let startIndex = idToIndex[nodeId] else { return nil }

        func nextIndex(after index: Int) -> Int? {
            if index + 1 < list.nodes.count { return index + 1 }
            return list.cycleIndex
        }

        var visited: [Int: Int] = [:]
        var nodes: [TraceListNode] = []
        var currentIndex: Int? = startIndex
        var cycleIndex: Int?

        while let index = currentIndex, nodes.count < maxNodes {
            if let cycleAt = visited[index] {
                cycleIndex = cycleAt
                break
            }
            visited[index] = nodes.count
            nodes.append(list.nodes[index])
            currentIndex = nextIndex(after: index)
        }

        let truncated = cycleIndex == nil && nodes.count >= maxNodes && currentIndex != nil
        return TraceList(
            nodes: nodes,
            cycleIndex: cycleIndex,
            isTruncated: truncated,
            isDoubly: list.isDoubly
        )
    }
}
