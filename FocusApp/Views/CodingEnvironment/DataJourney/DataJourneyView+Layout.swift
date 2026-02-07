import FocusDesignSystem
import SwiftUI

extension DataJourneyView {
    var content: some View {
        let structure = resolvedStructure
        return VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
            if let structure {
                let beginsAtZero = playbackEvents.first?.label?
                    .lowercased()
                    .contains("begin") == true
                    || playbackEvents.first?.label?
                        .lowercased()
                        .contains("start") == true
                DataJourneyStructureCanvasView(
                    inputEvent: inputEvent,
                    selectedEvent: selectedEvent,
                    previousEvent: previousPlaybackEvent,
                    outputEvent: outputEvent,
                    structureOverride: structure,
                    playbackIndex: currentPlaybackIndex,
                    beginsAtZero: beginsAtZero,
                    header: playbackEvents.isEmpty ? nil : AnyView(stepControlsHeader(style: .embedded)),
                    footer: playbackEvents.isEmpty ? nil : AnyView(stepControlsTimeline(style: .embedded))
                )
            } else if !playbackEvents.isEmpty {
                stepControls()
            }

            // Variable timeline (collapsible)
            if playbackEvents.count >= 2 {
                VariableTimelineView(
                    events: playbackEvents,
                    currentIndex: currentPlaybackIndex,
                    onSelectIndex: { index in
                        guard playbackEvents.indices.contains(index) else { return }
                        let event = playbackEvents[index]
                        selectedEventID = event.id
                        onSelectEvent(event)
                    }
                )
            }

            // Before/after comparison (collapsible)
            if previousPlaybackEvent != nil, selectedEvent != nil {
                DataJourneyComparisonView(
                    previousEvent: previousPlaybackEvent,
                    currentEvent: selectedEvent
                )
            }

            // Flow overview (collapsible)
            if playbackEvents.count >= 3 {
                DataJourneyFlowView(
                    events: events,
                    inputEvent: inputEvent,
                    outputEvent: outputEvent,
                    onSelectEvent: { event in
                        selectedEventID = event.id
                        onSelectEvent(event)
                    }
                )
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
        VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
            Text("Run with input to see the data journey.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(palette.gray300)
            Text("Add `Trace.step(\"label\", [\"key\": value])` inside loops to visualize iterations.")
                .font(.system(size: 10))
                .foregroundColor(palette.gray500)
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
        let listContexts = resolvedListContexts()
        let changedKeys = TraceValueDiff.changedKeys(
            previous: previousPlaybackEvent,
            current: event
        )
        let isCompact = style == .compact
        let verticalPadding: CGFloat = isCompact ? 8 : 10
        let rowSpacing: CGFloat = isCompact ? 6 : 10
        let titleSize: CGFloat = isCompact ? 9 : 10
        let keyWidth: CGFloat = isCompact ? 70 : 80
        let infoSize: CGFloat = isCompact ? 9 : 10
        return VStack(alignment: .leading, spacing: DSLayout.spacing(8)) {
            Text(title)
                .font(.system(size: titleSize, weight: .semibold))
                .foregroundColor(palette.gray400)

            if event.values.isEmpty {
                Text("No values captured for this step.")
                    .font(.system(size: infoSize))
                    .foregroundColor(palette.gray500)
            } else {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(event.values.keys.sorted(), id: \.self) { key in
                        if let value = event.values[key] {
                            let isChanged = changedKeys.contains(key)
                            HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                                Text(key)
                                    .font(.system(size: infoSize, weight: .semibold))
                                    .foregroundColor(
                                        isChanged ? palette.cyan : palette.gray300
                                    )
                                    .frame(width: keyWidth, alignment: .leading)

                                valueView(for: value, listContexts: listContexts)
                            }
                            .padding(.vertical, DSLayout.spacing(2))
                            .padding(.horizontal, DSLayout.spacing(4))
                                .background(
                                    isChanged
                                        ? RoundedRectangle(cornerRadius: 4)
                                            .fill(palette.cyan.opacity(0.08))
                                        : nil
                                )
                        }
                    }
                }
            }
        }
        .padding(verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.gray900.opacity(0.45))
        )
    }

    private var resolvedStructure: TraceStructure? {
        if let fromInput = DataJourneyStructureCanvasView.structure(in: inputEvent) { return fromInput }
        return DataJourneyStructureCanvasView.structure(in: selectedEvent)
    }

    @ViewBuilder
    private func valueView(for value: TraceValue, listContexts: [TraceList]) -> some View {
        if case .listPointer(let id) = value,
           let listContext = listContextContaining(nodeId: id, in: listContexts),
           let list = traceList(from: listContext, startingAt: id) {
            SequenceBubbleRow(
                items: list.nodes.isEmpty ? [.null] : list.nodes.map(\.value),
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

    private func resolvedListContexts() -> [TraceList] {
        if let lists = listStructures(in: inputEvent), !lists.isEmpty { return lists }
        if let lists = listStructures(in: selectedEvent), !lists.isEmpty { return lists }
        return []
    }

    private func listStructures(in event: DataJourneyEvent?) -> [TraceList]? {
        guard let event else { return nil }
        var lists: [TraceList] = []
        for key in event.values.keys.sorted() {
            guard let value = event.values[key] else { continue }
            collectLists(from: value, into: &lists)
        }
        return lists.isEmpty ? nil : lists
    }

    private func listContextContaining(nodeId: String, in lists: [TraceList]) -> TraceList? {
        lists.first { list in
            list.nodes.contains { $0.id == nodeId }
        }
    }

    private func collectLists(from value: TraceValue, into lists: inout [TraceList]) {
        switch value {
        case .list(let list):
            lists.append(list)
        case .array(let items):
            for item in items {
                collectLists(from: item, into: &lists)
            }
        case .typed(_, let inner):
            collectLists(from: inner, into: &lists)
        default:
            break
        }
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
