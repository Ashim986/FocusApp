import FocusDesignSystem
import SwiftUI

enum TraceStructure {
    case list(TraceList)
    case listGroup([NamedTraceList])
    case listArray(ListArrayStructure)
    case tree(TraceTree)
    case array([TraceValue])
    case matrix([[TraceValue]])
    case graph([[Int]])
    case dictionary([DictionaryEntry])
    case set([TraceValue])
    case stack([TraceValue])
    case queue([TraceValue])
    case heap([TraceValue], isMinHeap: Bool)
    case stringSequence(String, [TraceValue])
    case trie(TraceTrie)
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

// swiftlint:disable type_body_length
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

    let structureBubbleSize: CGFloat = 40
    let structurePointerFontSize: CGFloat = 10
    let structurePointerHorizontalPadding: CGFloat = 9
    let structurePointerVerticalPadding: CGFloat = 3
    let combinedMaxItems = 40
    @Environment(\.dsTheme) var theme

    var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

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
        let offGraphPointers = offGraphPointerBadges(for: structure)
        return AnyView(
            VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
                HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                    Text("Structure")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(palette.gray400)

                    if let header {
                        header
                    }

                    Spacer()
                }
                .zIndex(1)

                if !offGraphPointers.isEmpty {
                    HStack(alignment: .center, spacing: DSLayout.spacing(6)) {
                        Text("Off-graph")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(palette.gray500)
                        ForEach(offGraphPointers) { pointer in
                            PointerBadge(
                                text: pointer.name,
                                color: pointer.color,
                                fontSize: 8,
                                horizontalPadding: 6,
                                verticalPadding: 2
                            )
                        }
                    }
                    .padding(.bottom, DSLayout.spacing(2))
                }

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
                    VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
                        HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                            listLabel("combined", color: palette.purple, background: palette.purple.opacity(0.18))
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
                            .fill(palette.gray700.opacity(0.6))
                            .frame(height: 1)
                            .padding(.leading, DSLayout.spacing(64))

                        ForEach(lists) { entry in
                            HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                                let accent = PointerPalette.color(for: entry.name, palette: palette)
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
                    VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
                        HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                            listLabel("combined", color: palette.purple, background: palette.purple.opacity(0.18))
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

                        HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                            listLabel("heads", color: palette.cyan, background: palette.cyan.opacity(0.18))
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
                            .fill(palette.gray700.opacity(0.6))
                            .frame(height: 1)
                            .padding(.leading, DSLayout.spacing(64))

                        ForEach(listArray.lists) { entry in
                            HStack(alignment: .center, spacing: DSLayout.spacing(10)) {
                                let accent = PointerPalette.color(for: entry.name, palette: palette)
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
                    let motions = treePointerMotions(from: previousEvent, to: selectedEvent)
                    let treeHighlights = structureTreeHighlights
                    TreeGraphView(
                        tree: tree,
                        pointers: pointerMarkers,
                        pointerMotions: motions,
                        highlightedNodeIds: treeHighlights,
                        bubbleStyle: .solid,
                        nodeSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .array(let items):
                    let arrayHighlights = structureArrayHighlights(items: items)
                    let arrayChanges = structureElementChanges(items: items)
                    SequenceBubbleRow(
                        items: items,
                        showIndices: true,
                        cycleIndex: nil,
                        isTruncated: false,
                        isDoubly: false,
                        pointers: pointerMarkers,
                        highlightedIndices: arrayHighlights,
                        changeTypes: arrayChanges,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .matrix(let grid):
                    let matrixHighlights = structureMatrixHighlights
                    MatrixGridView(
                        grid: grid,
                        pointers: matrixPointerCell(),
                        highlightedCells: matrixHighlights,
                        bubbleSize: structureBubbleSize
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
                case .set(let items):
                    let gaps = Set(items.indices.dropLast())
                    let setChanges = structureElementChanges(items: items)
                    SequenceBubbleRow(
                        items: items,
                        showIndices: false,
                        cycleIndex: nil,
                        isTruncated: false,
                        isDoubly: false,
                        pointers: [],
                        gapIndices: gaps,
                        changeTypes: setChanges,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .stack(let items):
                    let stackChanges = structureElementChanges(items: items)
                    SequenceBubbleRow(
                        items: items,
                        showIndices: false,
                        cycleIndex: nil,
                        isTruncated: false,
                        isDoubly: false,
                        pointers: pointerMarkers,
                        changeTypes: stackChanges,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .queue(let items):
                    let queueChanges = structureElementChanges(items: items)
                    SequenceBubbleRow(
                        items: items,
                        showIndices: false,
                        cycleIndex: nil,
                        isTruncated: false,
                        isDoubly: false,
                        pointers: pointerMarkers,
                        changeTypes: queueChanges,
                        bubbleStyle: .solid,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .heap(let items, let isMinHeap):
                    let heapHighlights = structureArrayHighlights(items: items)
                    HeapView(
                        items: items,
                        isMinHeap: isMinHeap,
                        pointers: pointerMarkers,
                        highlightedIndices: heapHighlights,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .stringSequence(let fullString, let chars):
                    let charHighlights = structureArrayHighlights(items: chars)
                    StringSequenceView(
                        fullString: fullString,
                        characters: chars,
                        pointers: pointerMarkers,
                        highlightedIndices: charHighlights,
                        bubbleSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                case .trie(let trieData):
                    TrieGraphView(
                        trie: trieData,
                        pointers: pointerMarkers,
                        nodeSize: structureBubbleSize,
                        pointerFontSize: structurePointerFontSize,
                        pointerHorizontalPadding: structurePointerHorizontalPadding,
                        pointerVerticalPadding: structurePointerVerticalPadding
                    )
                }

                if let footer {
                    footer
                        .padding(.top, DSLayout.spacing(6))
                }
            }
            .padding(DSLayout.spacing(8))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.gray900.opacity(0.45))
            )
        )
    }

    // MARK: - Diff Highlighting Helpers

    /// Finds the primary structure value from an event for diff computation.
    private func primaryStructureValue(
        in event: DataJourneyEvent?
    ) -> TraceValue? {
        guard let event else { return nil }
        for key in event.values.keys.sorted() {
            guard let value = event.values[key] else { continue }
            switch value {
            case .array, .list, .tree, .object, .typed:
                return value
            default:
                continue
            }
        }
        return nil
    }

    /// Highlighted array indices from diff between previous and current.
    private func structureArrayHighlights(
        items: [TraceValue]
    ) -> Set<Int> {
        guard previousEvent != nil else { return [] }
        let prevValue = primaryStructureValue(in: previousEvent)
        let currValue = primaryStructureValue(in: selectedEvent)
        return TraceValueDiff.changedIndices(
            previous: prevValue,
            current: currValue
        )
    }

    /// Highlighted tree node IDs from diff between previous and current.
    private var structureTreeHighlights: Set<String> {
        guard previousEvent != nil else { return [] }
        let prevValue = primaryStructureValue(in: previousEvent)
        let currValue = primaryStructureValue(in: selectedEvent)
        return TraceValueDiff.changedTreeNodeIds(
            previous: prevValue,
            current: currValue
        )
    }

    /// Per-element change types from diff between previous and current.
    private func structureElementChanges(
        items: [TraceValue]
    ) -> [ChangeType] {
        guard previousEvent != nil else { return [] }
        let prevValue = primaryStructureValue(in: previousEvent)
        let currValue = primaryStructureValue(in: selectedEvent)
        return TraceValueDiff.elementChanges(
            previous: prevValue,
            current: currValue
        )
    }

    /// Highlighted matrix cells from diff between previous and current.
    private var structureMatrixHighlights: Set<MatrixCell> {
        guard previousEvent != nil else { return [] }
        let prevValue = primaryStructureValue(in: previousEvent)
        let currValue = primaryStructureValue(in: selectedEvent)
        return TraceValueDiff.changedMatrixCells(
            previous: prevValue,
            current: currValue
        )
    }
}
// swiftlint:enable type_body_length
