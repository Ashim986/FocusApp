import SwiftUI

enum TraceStructure {
    case list(TraceList)
    case listGroup([NamedTraceList])
    case listArray(ListArrayStructure)
    case tree(TraceTree)
    case array([TraceValue])
    case graph([[Int]])
    case dictionary([DictionaryEntry])
}

struct NamedTraceList: Identifiable {
    let id = UUID()
    let name: String
    let list: TraceList
}

struct CombinedListViewModel {
    let items: [TraceValue]
    let pointers: [PointerMarker]
    let isTruncated: Bool
    let gapIndices: Set<Int>
}

struct ListArrayStructure {
    let heads: [TraceValue]
    let lists: [NamedTraceList]
}

struct DataJourneyStructureCanvasView: View {
    let inputEvent: DataJourneyEvent?
    let selectedEvent: DataJourneyEvent?
    let previousEvent: DataJourneyEvent?
    let outputEvent: DataJourneyEvent?
    let structureOverride: TraceStructure?
    let playbackIndex: Int
    let beginsAtZero: Bool
    let header: AnyView?
    let footer: AnyView?

    private let structureBubbleSize: CGFloat = 40
    private let structurePointerFontSize: CGFloat = 10
    private let structurePointerHorizontalPadding: CGFloat = 9
    private let structurePointerVerticalPadding: CGFloat = 3
    private let combinedMaxItems = 40

    init(
        inputEvent: DataJourneyEvent?,
        selectedEvent: DataJourneyEvent?,
        previousEvent: DataJourneyEvent? = nil,
        outputEvent: DataJourneyEvent? = nil,
        structureOverride: TraceStructure? = nil,
        playbackIndex: Int = 0,
        beginsAtZero: Bool = false,
        header: AnyView? = nil,
        footer: AnyView? = nil
    ) {
        self.inputEvent = inputEvent
        self.selectedEvent = selectedEvent
        self.previousEvent = previousEvent
        self.outputEvent = outputEvent
        self.structureOverride = structureOverride
        self.playbackIndex = playbackIndex
        self.beginsAtZero = beginsAtZero
        self.header = header
        self.footer = footer
    }

    var body: some View {
        guard let structure else {
            return AnyView(EmptyView())
        }
        return AnyView(
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Structure")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.appGray400)

                    if let header {
                        header
                    }

                    Spacer()
                }
                .padding(.top, -16)

                switch structure {
                case .list(let list):
                    let motions = listPointerMotions(from: previousEvent, to: selectedEvent, list: list)
                    SequenceBubbleRow(
                        items: list.nodes.isEmpty ? [.null] : list.nodes.map(\.value),
                        showIndices: false,
                        cycleIndex: list.cycleIndex,
                        isTruncated: list.isTruncated,
                        isDoubly: list.isDoubly,
                        pointers: pointerMarkers(for: list),
                        pointerMotions: motions,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .listGroup(let lists):
                    let combined = combinedListViewModel(for: lists)
                    let motions = combinedPointerMotions(from: previousEvent, to: selectedEvent, lists: lists)
                    let finalLinks = outputSequenceLinks(for: lists)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            listLabel("combined", color: Color.appPurple, background: Color.appPurple.opacity(0.18))
                                .frame(width: 64, alignment: .leading)

                            SequenceBubbleRow(
                                items: combined.items,
                                showIndices: false,
                                cycleIndex: nil,
                                isTruncated: combined.isTruncated,
                                isDoubly: false,
                                pointers: combined.pointers,
                                pointerMotions: motions,
                                sequenceLinks: finalLinks,
                                gapIndices: combined.gapIndices,
                                bubbleStyle: .solid,
                                bubbleSize: structureBubbleSize,
                                pointerFontSize: structurePointerFontSize,
                                pointerHorizontalPadding: structurePointerHorizontalPadding,
                                pointerVerticalPadding: structurePointerVerticalPadding
                            )
                        }

                        Rectangle()
                            .fill(Color.appGray700.opacity(0.6))
                            .frame(height: 1)
                            .padding(.leading, 64)

                        ForEach(lists) { entry in
                            HStack(alignment: .center, spacing: 10) {
                                let accent = PointerPalette.color(for: entry.name)
                                listLabel(
                                    entry.name,
                                    color: accent,
                                    background: accent.opacity(0.18)
                                )
                                .frame(width: 64, alignment: .leading)

                                SequenceBubbleRow(
                                    items: entry.list.nodes.isEmpty ? [.null] : entry.list.nodes.map(\.value),
                                    showIndices: false,
                                    cycleIndex: entry.list.cycleIndex,
                                    isTruncated: entry.list.isTruncated,
                                    isDoubly: entry.list.isDoubly,
                                    pointers: pointerMarkers(for: entry.list),
                                    bubbleStyle: .solid,
                                    bubbleSize: structureBubbleSize,
                                    pointerFontSize: structurePointerFontSize,
                                    pointerHorizontalPadding: structurePointerHorizontalPadding,
                                    pointerVerticalPadding: structurePointerVerticalPadding
                                )
                            }
                        }
                    }
                case .listArray(let listArray):
                    let combined = combinedListViewModel(for: listArray.lists)
                    let motions = combinedPointerMotions(from: previousEvent, to: selectedEvent, lists: listArray.lists)
                    let finalLinks = outputSequenceLinks(for: listArray.lists)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            listLabel("combined", color: Color.appPurple, background: Color.appPurple.opacity(0.18))
                                .frame(width: 64, alignment: .leading)

                            SequenceBubbleRow(
                                items: combined.items,
                                showIndices: false,
                                cycleIndex: nil,
                                isTruncated: combined.isTruncated,
                                isDoubly: false,
                                pointers: combined.pointers,
                                pointerMotions: motions,
                                sequenceLinks: finalLinks,
                                gapIndices: combined.gapIndices,
                                bubbleStyle: .solid,
                                bubbleSize: structureBubbleSize,
                                pointerFontSize: structurePointerFontSize,
                                pointerHorizontalPadding: structurePointerHorizontalPadding,
                                pointerVerticalPadding: structurePointerVerticalPadding
                            )
                        }

                        HStack(alignment: .center, spacing: 10) {
                            listLabel("heads", color: Color.appCyan, background: Color.appCyan.opacity(0.18))
                                .frame(width: 64, alignment: .leading)

                            SequenceBubbleRow(
                                items: listArray.heads.isEmpty ? [.null] : listArray.heads,
                                showIndices: true,
                                cycleIndex: nil,
                                isTruncated: false,
                                isDoubly: false,
                                pointers: listArrayHeadPointers(for: listArray),
                                bubbleStyle: .solid,
                                bubbleSize: structureBubbleSize,
                                pointerFontSize: structurePointerFontSize,
                                pointerHorizontalPadding: structurePointerHorizontalPadding,
                                pointerVerticalPadding: structurePointerVerticalPadding
                            )
                        }

                        Rectangle()
                            .fill(Color.appGray700.opacity(0.6))
                            .frame(height: 1)
                            .padding(.leading, 64)

                        ForEach(listArray.lists) { entry in
                            HStack(alignment: .center, spacing: 10) {
                                let accent = PointerPalette.color(for: entry.name)
                                listLabel(
                                    entry.name,
                                    color: accent,
                                    background: accent.opacity(0.18)
                                )
                                .frame(width: 64, alignment: .leading)

                                SequenceBubbleRow(
                                    items: entry.list.nodes.isEmpty ? [.null] : entry.list.nodes.map(\.value),
                                    showIndices: false,
                                    cycleIndex: entry.list.cycleIndex,
                                    isTruncated: entry.list.isTruncated,
                                    isDoubly: entry.list.isDoubly,
                                    pointers: pointerMarkers(for: entry.list),
                                    bubbleStyle: .solid,
                                    bubbleSize: structureBubbleSize,
                                    pointerFontSize: structurePointerFontSize,
                                    pointerHorizontalPadding: structurePointerHorizontalPadding,
                                    pointerVerticalPadding: structurePointerVerticalPadding
                                )
                            }
                        }
                    }
                case .tree(let tree):
                    TreeGraphView(
                        tree: tree,
                        pointers: pointerMarkers,
                        bubbleStyle: .solid,
                        nodeSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .array(let items):
                    SequenceBubbleRow(
                        items: items,
                        showIndices: true,
                        cycleIndex: nil,
                        isTruncated: false,
                        isDoubly: false,
                        pointers: pointerMarkers,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .graph(let adjacency):
                    GraphView(
                        adjacency: adjacency,
                        pointers: pointerMarkers,
                        bubbleStyle: .solid,
                        nodeSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .dictionary(let entries):
                    DictionaryStructureRow(
                        entries: entries,
                        pointers: pointerMarkers,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                }

                if let footer {
                    footer
                        .padding(.top, 6)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appGray900.opacity(0.45))
            )
        )
    }

    private var structure: TraceStructure? {
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
            switch value {
            case .list(let list):
                lists.append(NamedTraceList(name: key, list: list))
            case .array(let items):
                if let listArray = listArrayStructure(from: items) {
                    return .listArray(listArray)
                }
                if let adjacency = graphAdjacency(from: items) {
                    fallback = fallback ?? .graph(adjacency)
                } else {
                    fallback = fallback ?? .array(items)
                }
            case .tree(let tree):
                fallback = fallback ?? .tree(tree)
            case .object(let map):
                fallback = fallback ?? .dictionary(dictionaryEntries(from: map))
            default:
                continue
            }
        }

        if lists.count > 1 {
            return .listGroup(lists)
        }
        if let list = lists.first {
            return .list(list.list)
        }
        return fallback
    }

    private var pointerMarkers: [PointerMarker] {
        guard let selectedEvent, let structure else { return [] }
        switch structure {
        case .list(let list):
            return listPointers(in: selectedEvent, list: list)
        case .listGroup:
            return []
        case .listArray(let listArray):
            return listArrayHeadPointers(for: listArray)
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

    private func pointerMarkers(for list: TraceList) -> [PointerMarker] {
        guard let selectedEvent else { return [] }
        return listPointers(in: selectedEvent, list: list)
    }

    private func arrayPointerMarkers(for items: [TraceValue]) -> [PointerMarker] {
        guard let selectedEvent else { return [] }
        return arrayPointers(in: selectedEvent, items: items)
    }

    private func listArrayHeadPointers(for listArray: ListArrayStructure) -> [PointerMarker] {
        let indexMarkers = arrayPointerMarkers(for: listArray.heads)
        let headMarkers = listHeadPointers(for: listArray)
        return uniquePointerMarkers(indexMarkers + headMarkers)
    }

    private func listHeadPointers(for listArray: ListArrayStructure) -> [PointerMarker] {
        guard let selectedEvent else { return [] }
        var headIdToIndex: [String: Int] = [:]
        for (index, entry) in listArray.lists.enumerated() {
            if let headId = entry.list.nodes.first?.id {
                headIdToIndex[headId] = index
            }
        }
        return pointerCandidates(in: selectedEvent).compactMap { name, value in
            guard case .listPointer(let id) = value,
                  let index = headIdToIndex[id] else { return nil }
            return PointerMarker(name: name, index: index)
        }
    }

    private func uniquePointerMarkers(_ markers: [PointerMarker]) -> [PointerMarker] {
        var seen: Set<String> = []
        let unique = markers.filter { marker in
            seen.insert(marker.id).inserted
        }
        return unique.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func pointerCandidates(in event: DataJourneyEvent) -> [(name: String, value: TraceValue)] {
        var result: [(name: String, value: TraceValue)] = []
        for key in event.values.keys.sorted() {
            guard let value = event.values[key] else { continue }
            collectPointerCandidates(path: key, value: value, into: &result)
        }
        return result
    }

    private func collectPointerCandidates(
        path: String,
        value: TraceValue,
        into result: inout [(name: String, value: TraceValue)]
    ) {
        switch value {
        case .listPointer, .treePointer:
            result.append((path, value))
        case .object(let map):
            for key in map.keys.sorted() {
                guard let nested = map[key] else { continue }
                collectPointerCandidates(path: "\(path).\(key)", value: nested, into: &result)
            }
        case .array(let items):
            for (index, nested) in items.enumerated() {
                collectPointerCandidates(path: "\(path)[\(index)]", value: nested, into: &result)
            }
        case .typed(_, let inner):
            collectPointerCandidates(path: path, value: inner, into: &result)
        default:
            break
        }
    }

    private func combinedListViewModel(for lists: [NamedTraceList]) -> CombinedListViewModel {
        var items: [TraceValue] = []
        var pointers: [PointerMarker] = []
        var gapIndices: Set<Int> = []
        var offset = 0
        var truncated = false

        for (index, entry) in lists.enumerated() {
            let values = entry.list.nodes.map(\.value)
            if items.count + values.count > combinedMaxItems {
                let remaining = max(combinedMaxItems - items.count, 0)
                if remaining > 0 {
                    items.append(contentsOf: values.prefix(remaining))
                }
                truncated = true
                break
            } else {
                items.append(contentsOf: values)
            }

            if let selectedEvent {
                let listMarkers = listPointers(in: selectedEvent, list: entry.list)
                for marker in listMarkers {
                    if let indexValue = marker.index {
                        pointers.append(PointerMarker(name: marker.name, index: indexValue + offset))
                    }
                }
            }

            offset += values.count

            if !values.isEmpty, index < lists.count - 1 {
                let hasFutureValues = lists[(index + 1)...].contains { !$0.list.nodes.isEmpty }
                if hasFutureValues {
                    gapIndices.insert(items.count - 1)
                }
            }
        }

        if lists.contains(where: { $0.list.isTruncated }) {
            truncated = true
        }

        return CombinedListViewModel(
            items: items,
            pointers: pointers.sorted { $0.name < $1.name },
            isTruncated: truncated,
            gapIndices: gapIndices
        )
    }

    private func listPointerMotions(
        from previousEvent: DataJourneyEvent?,
        to currentEvent: DataJourneyEvent?,
        list: TraceList
    ) -> [PointerMotion] {
        guard let previousEvent, let currentEvent else { return [] }
        let previous = listPointerIndices(in: previousEvent, list: list)
        let current = listPointerIndices(in: currentEvent, list: list)
        return pointerMotions(from: previous, to: current)
    }

    private func combinedPointerMotions(
        from previousEvent: DataJourneyEvent?,
        to currentEvent: DataJourneyEvent?,
        lists: [NamedTraceList]
    ) -> [PointerMotion] {
        guard let previousEvent, let currentEvent else { return [] }
        let previous = combinedPointerIndices(in: previousEvent, lists: lists)
        let current = combinedPointerIndices(in: currentEvent, lists: lists)
        return pointerMotions(from: previous, to: current)
    }

    private func pointerMotions(
        from previous: [String: Int],
        to current: [String: Int]
    ) -> [PointerMotion] {
        var motions: [PointerMotion] = []
        for (name, toIndex) in current {
            guard let fromIndex = previous[name], fromIndex != toIndex else { continue }
            motions.append(PointerMotion(name: name, fromIndex: fromIndex, toIndex: toIndex))
        }
        return motions.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func listPointerIndices(in event: DataJourneyEvent, list: TraceList) -> [String: Int] {
        var idToIndex: [String: Int] = [:]
        for (index, node) in list.nodes.enumerated() {
            idToIndex[node.id] = index
        }
        var indices: [String: Int] = [:]
        for candidate in pointerCandidates(in: event) {
            guard case .listPointer(let id) = candidate.value,
                  let index = idToIndex[id] else { continue }
            indices[candidate.name] = index
        }
        return indices
    }

    private func combinedPointerIndices(in event: DataJourneyEvent, lists: [NamedTraceList]) -> [String: Int] {
        let candidates = pointerCandidates(in: event)
        var indices: [String: Int] = [:]
        var offset = 0
        for entry in lists {
            var idToIndex: [String: Int] = [:]
            for (index, node) in entry.list.nodes.enumerated() {
                idToIndex[node.id] = index
            }
            for candidate in candidates {
                guard case .listPointer(let id) = candidate.value,
                      let index = idToIndex[id] else { continue }
                indices[candidate.name] = index + offset
            }
            offset += entry.list.nodes.count
        }
        return indices
    }

    private func outputSequenceLinks(for lists: [NamedTraceList]) -> [SequenceLink] {
        guard let outputList = outputList(from: outputEvent) else { return [] }
        var idToIndex: [String: Int] = [:]
        var offset = 0
        for entry in lists {
            for (index, node) in entry.list.nodes.enumerated() {
                idToIndex[node.id] = index + offset
            }
            offset += entry.list.nodes.count
        }
        var indices: [Int] = []
        for node in outputList.nodes {
            if let index = idToIndex[node.id] {
                indices.append(index)
            }
        }
        guard indices.count > 1 else { return [] }
        let palette: [Color] = [
            Color.appGreen,
            Color.appCyan,
            Color.appAmber,
            Color.appPurple
        ]
        var links: [SequenceLink] = []
        for (index, pair) in zip(indices, indices.dropFirst()).enumerated() {
            let color = palette[index % palette.count]
            links.append(SequenceLink(fromIndex: pair.0, toIndex: pair.1, color: color))
        }
        return visibleSequenceLinks(
            links,
            outputList: outputList,
            idToIndex: idToIndex
        )
    }

    private func visibleSequenceLinks(
        _ links: [SequenceLink],
        outputList: TraceList,
        idToIndex: [String: Int]
    ) -> [SequenceLink] {
        guard !links.isEmpty else { return links }
        guard let selectedEvent else { return links }
        if selectedEvent.kind == .output {
            return links
        }
        if selectedEvent.kind == .input {
            return []
        }
        if let maxPointerIndex = maxPointerIndex(
            in: selectedEvent,
            outputList: outputList,
            idToIndex: idToIndex
        ) {
            let count = min(links.count, max(0, maxPointerIndex))
            return Array(links.prefix(count))
        }
        let offset = beginsAtZero ? 0 : 1
        let count = min(links.count, max(0, playbackIndex + offset))
        return Array(links.prefix(count))
    }

    private func maxPointerIndex(
        in event: DataJourneyEvent,
        outputList: TraceList,
        idToIndex: [String: Int]
    ) -> Int? {
        var maxIndex: Int?
        let candidates = pointerCandidates(in: event)
        for candidate in candidates {
            guard case .listPointer(let id) = candidate.value,
                  outputList.nodes.contains(where: { $0.id == id }),
                  let index = idToIndex[id] else { continue }
            maxIndex = max(maxIndex ?? -1, index)
        }
        return maxIndex
    }

    private func outputList(from event: DataJourneyEvent?) -> TraceList? {
        guard let event else { return nil }
        if let value = event.values["result"],
           let list = firstList(in: value) {
            return list
        }
        for key in event.values.keys.sorted() {
            guard let value = event.values[key],
                  let list = firstList(in: value) else { continue }
            return list
        }
        return nil
    }

    private func firstList(in value: TraceValue) -> TraceList? {
        switch value {
        case .list(let list):
            return list
        case .typed(_, let inner):
            return firstList(in: inner)
        case .array(let items):
            for item in items {
                if let list = firstList(in: item) {
                    return list
                }
            }
            return nil
        case .object(let map):
            for key in map.keys.sorted() {
                if let nested = map[key],
                   let list = firstList(in: nested) {
                    return list
                }
            }
            return nil
        default:
            return nil
        }
    }

    @ViewBuilder
    private func listLabel(_ title: String, color: Color, background: Color) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(background)
            )
    }

    private func listPointers(in event: DataJourneyEvent, list: TraceList) -> [PointerMarker] {
        var idToIndex: [String: Int] = [:]
        for (index, node) in list.nodes.enumerated() {
            idToIndex[node.id] = index
        }
        return pointerCandidates(in: event).compactMap { name, value in
            guard case .listPointer(let id) = value,
                  let index = idToIndex[id] else { return nil }
            return PointerMarker(name: name, index: index)
        }
    }

    private func treePointers(in event: DataJourneyEvent) -> [PointerMarker] {
        pointerCandidates(in: event).compactMap { name, value in
            guard case .treePointer(let id) = value else { return nil }
            return PointerMarker(name: name, nodeId: id)
        }
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

    private static func graphAdjacency(from items: [TraceValue]) -> [[Int]]? {
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

    private static func listArrayStructure(from items: [TraceValue]) -> ListArrayStructure? {
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

    private static func dictionaryEntries(from map: [String: TraceValue]) -> [DictionaryEntry] {
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
    let bubbleStyle: TraceBubble.Style

    let bubbleSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    private let pointerSpacing: CGFloat = 2

    private var pointerHeight: CGFloat { pointerFontSize + pointerVerticalPadding * 2 + 4 }
    private var arrowSize: CGFloat { max(10, bubbleSize * 0.33) }

    init(
        entries: [DictionaryEntry],
        pointers: [PointerMarker],
        bubbleStyle: TraceBubble.Style = .solid,
        bubbleSize: CGFloat = 30,
        pointerFontSize: CGFloat = 8,
        pointerHorizontalPadding: CGFloat = 6,
        pointerVerticalPadding: CGFloat = 2
    ) {
        self.entries = entries
        self.pointers = pointers
        self.bubbleStyle = bubbleStyle
        self.bubbleSize = bubbleSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    let model = TraceBubbleModel.from(entry.value)
                    let keyFill = Color.appGray700
                    let valueFill = model.fill
                    let pointerStack = pointersByIndex[index] ?? []
                    VStack(spacing: 4) {
                        ZStack(alignment: .top) {
                            HStack(spacing: 6) {
                                TraceBubble(
                                    text: entry.key,
                                    fill: keyFill,
                                    size: bubbleSize,
                                    style: bubbleStyle
                                )
                                Image(systemName: "arrow.right")
                                    .font(.system(size: arrowSize, weight: .semibold))
                                    .foregroundColor(Color.appPurple.opacity(0.8))
                                TraceBubble(text: model.text, fill: valueFill, size: bubbleSize, style: bubbleStyle)
                            }
                            if !pointerStack.isEmpty {
                                let stackHeight = CGFloat(pointerStack.count) * pointerHeight +
                                    CGFloat(max(pointerStack.count - 1, 0)) * pointerSpacing
                                VStack(spacing: pointerSpacing) {
                                    ForEach(pointerStack) { pointer in
                                        PointerBadge(
                                            text: pointer.name,
                                            color: pointer.color,
                                            fontSize: pointerFontSize,
                                            horizontalPadding: pointerHorizontalPadding,
                                            verticalPadding: pointerVerticalPadding
                                        )
                                            .frame(height: pointerHeight)
                                    }
                                }
                                .offset(y: -(stackHeight + bubbleSize * 0.2))
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
