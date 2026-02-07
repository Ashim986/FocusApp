import FocusDesignSystem
import SwiftUI

/// Dual visualization for heap data: array view on top, implicit binary tree below.
struct HeapView: View {
    let items: [TraceValue]
    let isMinHeap: Bool
    let pointers: [PointerMarker]
    let highlightedIndices: Set<Int>
    let bubbleSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    @Environment(\.dsTheme) var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    init(
        items: [TraceValue],
        isMinHeap: Bool = true,
        pointers: [PointerMarker] = [],
        highlightedIndices: Set<Int> = [],
        bubbleSize: CGFloat = 40,
        pointerFontSize: CGFloat = 10,
        pointerHorizontalPadding: CGFloat = 9,
        pointerVerticalPadding: CGFloat = 3
    ) {
        self.items = items
        self.isMinHeap = isMinHeap
        self.pointers = pointers
        self.highlightedIndices = highlightedIndices
        self.bubbleSize = bubbleSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
            // Label
            HStack(spacing: DSLayout.spacing(6)) {
                Text(isMinHeap ? "min-heap" : "max-heap")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(palette.purple)
                    .padding(.horizontal, DSLayout.spacing(6))
                    .padding(.vertical, DSLayout.spacing(2))
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(palette.purple.opacity(0.15))
                    )

                Text("array")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(palette.gray400)
            }

            // Array view
            SequenceBubbleRow(
                items: items,
                showIndices: true,
                cycleIndex: nil,
                isTruncated: false,
                isDoubly: false,
                pointers: pointers,
                highlightedIndices: highlightedIndices,
                bubbleStyle: .solid,
                bubbleSize: bubbleSize,
                pointerFontSize: pointerFontSize,
                pointerHorizontalPadding: pointerHorizontalPadding,
                pointerVerticalPadding: pointerVerticalPadding
            )

            // Separator with "tree view" label
            HStack(spacing: DSLayout.spacing(6)) {
                Rectangle()
                    .fill(palette.gray700.opacity(0.4))
                    .frame(height: 1)
                    .frame(maxWidth: 30)

                Text("tree view")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(palette.gray400)

                Rectangle()
                    .fill(palette.gray700.opacity(0.4))
                    .frame(height: 1)
            }

            // Tree view — reuse the existing TraceTree + TreeGraphView
            let tree = TraceTree.fromLevelOrder(items)
            let treeHighlights = highlightedTreeNodeIds
            TreeGraphView(
                tree: tree,
                pointers: treePointers(for: tree),
                highlightedNodeIds: treeHighlights,
                bubbleStyle: .solid,
                nodeSize: bubbleSize,
                pointerFontSize: pointerFontSize,
                pointerHorizontalPadding: pointerHorizontalPadding,
                pointerVerticalPadding: pointerVerticalPadding
            )
        }
    }

    /// Convert array-index-based pointers to tree-node-ID-based pointers.
    private func treePointers(for tree: TraceTree) -> [PointerMarker] {
        pointers.compactMap { pointer -> PointerMarker? in
            guard let index = pointer.index else { return nil }
            let nodeId = "i\(index)"
            guard tree.nodes.contains(where: { $0.id == nodeId }) else { return nil }
            return PointerMarker(
                name: pointer.name,
                nodeId: nodeId,
                palette: palette
            )
        }
    }

    /// Convert highlighted array indices to tree node IDs.
    private var highlightedTreeNodeIds: Set<String> {
        Set(highlightedIndices.map { "i\($0)" })
    }
}
