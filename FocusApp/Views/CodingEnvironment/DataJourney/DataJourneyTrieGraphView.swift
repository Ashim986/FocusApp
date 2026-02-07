import FocusDesignSystem
import SwiftUI

/// Renders a trie as an N-ary tree layout with character-labeled edges and isEnd highlighting.
struct TrieGraphView: View {
    let trie: TraceTrie
    let pointers: [PointerMarker]
    let nodeSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    @Environment(\.dsTheme) var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    private let horizontalSpacing: CGFloat = 12
    private let verticalSpacing: CGFloat = 50
    private var pointerHeight: CGFloat { pointerFontSize + pointerVerticalPadding * 2 + 4 }

    init(
        trie: TraceTrie,
        pointers: [PointerMarker] = [],
        nodeSize: CGFloat = 40,
        pointerFontSize: CGFloat = 10,
        pointerHorizontalPadding: CGFloat = 9,
        pointerVerticalPadding: CGFloat = 3
    ) {
        self.trie = trie
        self.pointers = pointers
        self.nodeSize = nodeSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
    }

    var body: some View {
        let layout = TrieLayout(trie: trie, nodeSize: nodeSize, hSpacing: horizontalSpacing, vSpacing: verticalSpacing)
        let pointerMap = groupedPointers
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    for edge in layout.edges {
                        var path = Path()
                        path.move(to: edge.from)
                        path.addLine(to: edge.to)
                        context.stroke(
                            path,
                            with: .color(palette.gray600.opacity(0.5)),
                            lineWidth: 1.5
                        )
                        // Edge character label
                        let midX = (edge.from.x + edge.to.x) / 2
                        let midY = (edge.from.y + edge.to.y) / 2
                        let text = Text(edge.character)
                            .font(.system(size: max(8, nodeSize * 0.28), weight: .bold, design: .monospaced))
                            .foregroundColor(palette.cyan)
                        context.draw(context.resolve(text), at: CGPoint(x: midX - 6, y: midY))
                    }
                }
                .frame(width: layout.totalWidth, height: layout.totalHeight)

                ForEach(layout.nodes) { node in
                    ZStack(alignment: .top) {
                        let fill = node.isEnd ? palette.green.opacity(0.7) : palette.gray700
                        let label = node.character.isEmpty ? "root" : node.character
                        TraceBubble(
                            text: label,
                            fill: fill,
                            size: nodeSize,
                            style: .solid
                        )
                        if node.isEnd {
                            Circle()
                                .stroke(palette.green, lineWidth: 2)
                                .frame(width: nodeSize + 4, height: nodeSize + 4)
                        }
                        if let pointerStack = pointerMap[node.trieNodeId] {
                            let stackHeight = CGFloat(pointerStack.count) * pointerHeight
                            VStack(spacing: DSLayout.spacing(2)) {
                                ForEach(pointerStack) { pointer in
                                    PointerBadge(
                                        text: pointer.name,
                                        color: pointer.color,
                                        fontSize: pointerFontSize,
                                        horizontalPadding: pointerHorizontalPadding,
                                        verticalPadding: pointerVerticalPadding
                                    )
                                }
                            }
                            .offset(y: -(nodeSize / 2 + stackHeight))
                        }
                    }
                    .position(node.position)
                }
            }
            .frame(width: layout.totalWidth, height: layout.totalHeight)
        }
    }

    private var groupedPointers: [String: [PointerMarker]] {
        var grouped: [String: [PointerMarker]] = [:]
        for pointer in pointers {
            guard let nodeId = pointer.nodeId else { continue }
            grouped[nodeId, default: []].append(pointer)
        }
        return grouped
    }
}

// MARK: - Trie Layout Engine

struct TrieLayout {
    struct LayoutNode: Identifiable {
        let id = UUID()
        let trieNodeId: String
        let character: String
        let isEnd: Bool
        let position: CGPoint
    }

    struct LayoutEdge: Identifiable {
        let id = UUID()
        let from: CGPoint
        let to: CGPoint
        let character: String
    }

    let nodes: [LayoutNode]
    let edges: [LayoutEdge]
    let totalWidth: CGFloat
    let totalHeight: CGFloat

    init(trie: TraceTrie, nodeSize: CGFloat, hSpacing: CGFloat, vSpacing: CGFloat) {
        let nodeById = Dictionary(uniqueKeysWithValues: trie.nodes.map { ($0.id, $0) })
        guard let rootId = trie.rootId, nodeById[rootId] != nil else {
            self.nodes = []
            self.edges = []
            self.totalWidth = nodeSize
            self.totalHeight = nodeSize
            return
        }

        var layoutNodes: [LayoutNode] = []
        var layoutEdges: [LayoutEdge] = []

        // BFS to compute subtree widths, then position nodes
        func subtreeWidth(_ nodeId: String) -> CGFloat {
            guard let node = nodeById[nodeId] else { return nodeSize }
            if node.children.isEmpty { return nodeSize }
            let childrenWidth = node.children.reduce(CGFloat(0)) { sum, childId in
                sum + subtreeWidth(childId)
            }
            let gaps = CGFloat(max(node.children.count - 1, 0)) * hSpacing
            return max(nodeSize, childrenWidth + gaps)
        }

        func layoutNode(_ nodeId: String, x: CGFloat, y: CGFloat) {
            guard let node = nodeById[nodeId] else { return }
            let pos = CGPoint(x: x, y: y)
            layoutNodes.append(LayoutNode(
                trieNodeId: node.id,
                character: node.character,
                isEnd: node.isEnd,
                position: pos
            ))

            let totalChildWidth = node.children.reduce(CGFloat(0)) { sum, childId in
                sum + subtreeWidth(childId)
            }
            let gaps = CGFloat(max(node.children.count - 1, 0)) * hSpacing
            let allChildWidth = totalChildWidth + gaps
            var childX = x - allChildWidth / 2

            for childId in node.children {
                let childWidth = subtreeWidth(childId)
                let childCenterX = childX + childWidth / 2
                let childY = y + vSpacing
                let childNode = nodeById[childId]
                layoutEdges.append(LayoutEdge(
                    from: pos,
                    to: CGPoint(x: childCenterX, y: childY),
                    character: childNode?.character ?? ""
                ))
                layoutNode(childId, x: childCenterX, y: childY)
                childX += childWidth + hSpacing
            }
        }

        let rootWidth = subtreeWidth(rootId)
        let rootX = max(nodeSize, rootWidth / 2)
        let rootY = nodeSize
        layoutNode(rootId, x: rootX, y: rootY)

        // Compute depth for height
        func maxDepth(_ nodeId: String, depth: Int) -> Int {
            guard let node = nodeById[nodeId] else { return depth }
            if node.children.isEmpty { return depth }
            return node.children.map { maxDepth($0, depth: depth + 1) }.max() ?? depth
        }

        let depth = maxDepth(rootId, depth: 0)
        let height = CGFloat(depth + 1) * vSpacing + nodeSize * 2

        self.nodes = layoutNodes
        self.edges = layoutEdges
        self.totalWidth = max(nodeSize * 2, rootWidth + nodeSize)
        self.totalHeight = max(nodeSize * 2, height)
    }
}
