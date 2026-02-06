import SwiftUI

struct TreeGraphView: View {
    let tree: TraceTree
    let pointers: [PointerMarker]
    let pointerMotions: [TreePointerMotion]
    let nodeSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    let bubbleStyle: TraceBubble.Style
    private let levelSpacing: CGFloat = 50
    private let pointerSpacing: CGFloat = 2

    private var pointerHeight: CGFloat { pointerFontSize + pointerVerticalPadding * 2 + 4 }

    init(
        tree: TraceTree,
        pointers: [PointerMarker],
        pointerMotions: [TreePointerMotion] = [],
        bubbleStyle: TraceBubble.Style = .solid,
        nodeSize: CGFloat = 30,
        pointerFontSize: CGFloat = 8,
        pointerHorizontalPadding: CGFloat = 6,
        pointerVerticalPadding: CGFloat = 2
    ) {
        self.tree = tree
        self.pointers = pointers
        self.pointerMotions = pointerMotions
        self.nodeSize = nodeSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
        self.bubbleStyle = bubbleStyle
    }

    var body: some View {
        GeometryReader { proxy in
            let layout = TraceTreeLayout(
                tree: tree,
                size: proxy.size,
                nodeSize: nodeSize,
                levelSpacing: levelSpacing
            )
            let topPadding = pointerMotions.isEmpty ? 0 : nodeSize * 0.8
            let bottomPadding = pointerMotions.count >= 3 ? nodeSize * 0.6 : 0
            let yOffset = topPadding
            let pointersById = groupedPointers
            let positions = Dictionary(uniqueKeysWithValues: layout.nodes.map {
                ($0.id, CGPoint(x: $0.position.x, y: $0.position.y + yOffset))
            })
            ZStack {
                Canvas { context, _ in
                    for edge in layout.edges {
                        var path = Path()
                        let from = CGPoint(x: edge.from.x, y: edge.from.y + yOffset)
                        let to = CGPoint(x: edge.to.x, y: edge.to.y + yOffset)
                        path.move(to: from)
                        path.addLine(to: to)
                        context.stroke(path, with: .color(Color.appGray600.opacity(0.6)), lineWidth: 1)
                    }

                    for (index, motion) in pointerMotions.enumerated() {
                        guard let from = positions[motion.fromId],
                              let to = positions[motion.toId],
                              from != to else { continue }
                        let useBottom = index >= 2
                        let laneIndex = max(0, useBottom ? index - 2 : index)
                        drawPointerMotion(
                            context: &context,
                            from: from,
                            to: to,
                            color: motion.color,
                            laneIndex: laneIndex,
                            useBottom: useBottom
                        )
                    }
                }

                ForEach(layout.nodes) { node in
                    ZStack(alignment: .top) {
                        TraceValueNode(value: node.value, size: nodeSize, style: bubbleStyle)
                        if let pointerStack = pointersById[node.id] {
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
                                }
                            }
                            .offset(y: -(nodeSize / 2 + stackHeight))
                        }
                    }
                    .position(CGPoint(x: node.position.x, y: node.position.y + yOffset))
                }
            }
            .frame(height: layout.height + topPadding + bottomPadding)
        }
        .frame(minHeight: nodeSize + levelSpacing)
    }

    private func drawPointerMotion(
        context: inout GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        color: Color,
        laneIndex: Int,
        useBottom: Bool
    ) {
        let direction: CGFloat = from.x <= to.x ? 1 : -1
        let startYOffset = useBottom ? nodeSize * 0.45 : -nodeSize * 0.45
        let endYOffset = useBottom ? nodeSize * 0.45 : -nodeSize * 0.45
        let start = CGPoint(x: from.x + direction * nodeSize * 0.35, y: from.y + startYOffset)
        let end = CGPoint(x: to.x - direction * nodeSize * 0.35, y: to.y + endYOffset)
        let span = abs(end.x - start.x)
        let baseLift = min(56, max(16, span * 0.25))
        let lift = baseLift + CGFloat(laneIndex) * 12
        let controlY = useBottom
            ? max(start.y, end.y) + lift
            : min(start.y, end.y) - lift
        let control = CGPoint(x: (start.x + end.x) / 2, y: controlY)
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        context.stroke(path, with: .color(color.opacity(0.85)), lineWidth: 1.6)
        drawArrowHead(context: &context, from: control, to: end, color: color.opacity(0.95))
    }

    private func drawArrowHead(
        context: inout GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        color: Color
    ) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let length = max(sqrt(dx * dx + dy * dy), 0.001)
        let ux = dx / length
        let uy = dy / length
        let arrowSize: CGFloat = 6
        let base = CGPoint(x: to.x - ux * arrowSize, y: to.y - uy * arrowSize)
        let perp = CGPoint(x: -uy, y: ux)
        let halfWidth = arrowSize * 0.6
        let left = CGPoint(x: base.x + perp.x * halfWidth, y: base.y + perp.y * halfWidth)
        let right = CGPoint(x: base.x - perp.x * halfWidth, y: base.y - perp.y * halfWidth)
        var head = Path()
        head.move(to: to)
        head.addLine(to: left)
        head.addLine(to: right)
        head.closeSubpath()
        context.fill(head, with: .color(color))
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

struct TraceValueNode: View {
    let value: TraceValue
    let size: CGFloat
    let style: TraceBubble.Style

    init(value: TraceValue, size: CGFloat = 30, style: TraceBubble.Style = .solid) {
        self.value = value
        self.size = size
        self.style = style
    }

    var body: some View {
        let model = TraceBubbleModel.from(value, compact: true)
        return TraceBubble(text: model.text, fill: model.fill, size: size, style: style)
    }
}

struct TraceTreeLayout {
    struct Node: Identifiable {
        let id: String
        let value: TraceValue
        let position: CGPoint
    }

    struct Edge: Identifiable {
        let id = UUID()
        let from: CGPoint
        let to: CGPoint
    }

    private struct QueueEntry {
        let id: String
        let level: Int
        let heapIndex: Int
    }

    let nodes: [Node]
    let edges: [Edge]
    let height: CGFloat

    init(tree: TraceTree, size: CGSize, nodeSize: CGFloat, levelSpacing: CGFloat) {
        guard let rootId = tree.rootId else {
            self.nodes = []
            self.edges = []
            self.height = nodeSize
            return
        }
        var nodeMap: [String: TraceTreeNode] = [:]
        tree.nodes.forEach { nodeMap[$0.id] = $0 }

        var nodes: [Node] = []
        var positions: [String: CGPoint] = [:]
        var edges: [Edge] = []
        var maxLevel = 0
        var queue: [QueueEntry] = [QueueEntry(id: rootId, level: 0, heapIndex: 1)]
        var visited = Set<String>()

        while !queue.isEmpty {
            let entry = queue.removeFirst()
            guard let node = nodeMap[entry.id], !visited.contains(entry.id) else { continue }
            visited.insert(entry.id)
            maxLevel = max(maxLevel, entry.level)
            let countAtLevel = 1 << entry.level
            let indexInLevel = entry.heapIndex - (1 << entry.level)
            let x = CGFloat(indexInLevel + 1) * size.width / CGFloat(countAtLevel + 1)
            let y = CGFloat(entry.level) * levelSpacing + nodeSize / 2
            let position = CGPoint(x: x, y: y)
            nodes.append(Node(id: node.id, value: node.value, position: position))
            positions[node.id] = position

            if let leftId = node.left {
                queue.append(QueueEntry(id: leftId, level: entry.level + 1, heapIndex: entry.heapIndex * 2))
            }
            if let rightId = node.right {
                queue.append(QueueEntry(id: rightId, level: entry.level + 1, heapIndex: entry.heapIndex * 2 + 1))
            }
        }

        for node in tree.nodes {
            guard let parentPosition = positions[node.id] else { continue }
            if let leftId = node.left, let leftPosition = positions[leftId] {
                edges.append(
                    Edge(
                        from: CGPoint(x: parentPosition.x, y: parentPosition.y + nodeSize / 2),
                        to: CGPoint(x: leftPosition.x, y: leftPosition.y - nodeSize / 2)
                    )
                )
            }
            if let rightId = node.right, let rightPosition = positions[rightId] {
                edges.append(
                    Edge(
                        from: CGPoint(x: parentPosition.x, y: parentPosition.y + nodeSize / 2),
                        to: CGPoint(x: rightPosition.x, y: rightPosition.y - nodeSize / 2)
                    )
                )
            }
        }

        self.nodes = nodes
        self.edges = edges
        self.height = CGFloat(maxLevel + 1) * levelSpacing + nodeSize
    }
}
