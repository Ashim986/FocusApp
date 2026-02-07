import FocusDesignSystem
import SwiftUI

struct GraphView: View {
    let adjacency: [[Int]]
    let pointers: [PointerMarker]
    let nodeSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    let pointerSpacing: CGFloat
    let bubbleStyle: TraceBubble.Style
    @Environment(\.dsTheme) private var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    private var pointerHeight: CGFloat { pointerFontSize + pointerVerticalPadding * 2 + 4 }

    init(
        adjacency: [[Int]],
        pointers: [PointerMarker],
        bubbleStyle: TraceBubble.Style = .solid,
        nodeSize: CGFloat = 30,
        pointerFontSize: CGFloat = 8,
        pointerHorizontalPadding: CGFloat = 6,
        pointerVerticalPadding: CGFloat = 2,
        pointerSpacing: CGFloat = 2
    ) {
        self.adjacency = adjacency
        self.pointers = pointers
        self.nodeSize = nodeSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
        self.pointerSpacing = pointerSpacing
        self.bubbleStyle = bubbleStyle
    }

    var body: some View {
        GeometryReader { proxy in
            let layout = GraphLayout(adjacency: adjacency, size: proxy.size, nodeSize: nodeSize)
            let pointersByIndex = groupedPointers
            ZStack {
                Canvas { context, _ in
                    for edge in layout.edges {
                        var path = Path()
                        path.move(to: edge.from)
                        path.addLine(to: edge.to)
                        context.stroke(path, with: .color(palette.gray600.opacity(0.6)), lineWidth: 1)
                        if edge.directed {
                            drawEdgeArrowHead(
                                context: &context,
                                from: edge.from,
                                to: edge.to,
                                nodeRadius: nodeSize / 2
                            )
                        }
                    }
                }

                ForEach(layout.nodes) { node in
                    ZStack(alignment: .top) {
                        let fill = palette.gray700
                        TraceBubble(
                            text: "\(node.index)",
                            fill: fill,
                            size: nodeSize,
                            style: bubbleStyle
                        )
                        if let pointerStack = pointersByIndex[node.index] {
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
                    .position(node.position)
                }
            }
            .frame(height: layout.height)
        }
        .frame(height: graphHeight)
    }

    private var graphHeight: CGFloat {
        let base = CGFloat(adjacency.count) * 14
        return max(180, min(260, base))
    }

    private var groupedPointers: [Int: [PointerMarker]] {
        var grouped: [Int: [PointerMarker]] = [:]
        for pointer in pointers {
            guard let index = pointer.index else { continue }
            grouped[index, default: []].append(pointer)
        }
        return grouped
    }

    private func drawEdgeArrowHead(
        context: inout GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        nodeRadius: CGFloat
    ) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let dist = sqrt(dx * dx + dy * dy)
        guard dist > 0 else { return }
        let ux = dx / dist
        let uy = dy / dist
        let tipX = to.x - ux * nodeRadius
        let tipY = to.y - uy * nodeRadius
        let arrowLen: CGFloat = 8
        let arrowWidth: CGFloat = 4
        let baseX = tipX - ux * arrowLen
        let baseY = tipY - uy * arrowLen
        let leftX = baseX - uy * arrowWidth
        let leftY = baseY + ux * arrowWidth
        let rightX = baseX + uy * arrowWidth
        let rightY = baseY - ux * arrowWidth
        var path = Path()
        path.move(to: CGPoint(x: tipX, y: tipY))
        path.addLine(to: CGPoint(x: leftX, y: leftY))
        path.addLine(to: CGPoint(x: rightX, y: rightY))
        path.closeSubpath()
        context.fill(path, with: .color(palette.gray600.opacity(0.7)))
    }
}

struct GraphLayout {
    struct Node: Identifiable {
        let id = UUID()
        let index: Int
        let position: CGPoint
    }

    struct Edge: Identifiable {
        let id = UUID()
        let from: CGPoint
        let to: CGPoint
        let directed: Bool
    }

    let nodes: [Node]
    let edges: [Edge]
    let height: CGFloat

    init(adjacency: [[Int]], size: CGSize, nodeSize: CGFloat) {
        let count = adjacency.count
        let safeWidth = max(size.width, nodeSize * 4)
        let safeHeight = max(size.height, nodeSize * 4)

        let adjacencySets: [Set<Int>] = adjacency.map { Set($0) }
        let isUndirected = GraphLayout.isGraphUndirected(adjacency: adjacencySets)

        var positions: [CGPoint]
        if count <= 6 {
            positions = GraphLayout.circularLayout(
                count: count,
                center: CGPoint(x: safeWidth / 2, y: safeHeight / 2),
                radius: max(10, min(safeWidth, safeHeight) * 0.5 - nodeSize)
            )
        } else {
            positions = GraphLayout.forceDirectedLayout(
                adjacency: adjacency,
                width: safeWidth,
                height: safeHeight,
                nodeSize: nodeSize
            )
        }

        var nodes: [Node] = []
        for index in 0..<count {
            nodes.append(Node(index: index, position: positions[index]))
        }

        var edges: [Edge] = []
        for index in 0..<count {
            for neighbor in adjacency[index] {
                guard neighbor >= 0, neighbor < count else { continue }
                if isUndirected && neighbor < index { continue }
                edges.append(Edge(
                    from: positions[index],
                    to: positions[neighbor],
                    directed: !isUndirected
                ))
            }
        }

        self.nodes = nodes
        self.edges = edges
        self.height = safeHeight
    }

    // MARK: - Circular Layout (for small graphs)

    private static func circularLayout(
        count: Int,
        center: CGPoint,
        radius: CGFloat
    ) -> [CGPoint] {
        (0..<count).map { index in
            let angle = (Double(index) / Double(max(count, 1))) * (2 * .pi) - .pi / 2
            return CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
        }
    }

    // MARK: - Force-Directed Layout (Fruchterman-Reingold)

    private static func forceDirectedLayout(
        adjacency: [[Int]],
        width: CGFloat,
        height: CGFloat,
        nodeSize: CGFloat,
        iterations: Int = 50
    ) -> [CGPoint] {
        let count = adjacency.count
        guard count > 0 else { return [] }

        let area = width * height
        let optimalDistance = sqrt(area / CGFloat(count)) * 0.8
        let margin = nodeSize

        // Initialize positions on a circle
        var positions = circularLayout(
            count: count,
            center: CGPoint(x: width / 2, y: height / 2),
            radius: min(width, height) * 0.35
        )

        var temperature = width / 4

        for _ in 0..<iterations {
            var displacements = Array(repeating: CGPoint.zero, count: count)

            // Repulsive forces between all node pairs
            for nodeIndex in 0..<count {
                for otherIndex in (nodeIndex + 1)..<count {
                    let dx = positions[nodeIndex].x - positions[otherIndex].x
                    let dy = positions[nodeIndex].y - positions[otherIndex].y
                    let dist = max(sqrt(dx * dx + dy * dy), 0.01)
                    let force = (optimalDistance * optimalDistance) / dist
                    let fx = (dx / dist) * force
                    let fy = (dy / dist) * force
                    displacements[nodeIndex].x += fx
                    displacements[nodeIndex].y += fy
                    displacements[otherIndex].x -= fx
                    displacements[otherIndex].y -= fy
                }
            }

            // Attractive forces along edges
            for nodeIndex in 0..<count {
                for neighborIndex in adjacency[nodeIndex] {
                    guard neighborIndex >= 0, neighborIndex < count, neighborIndex > nodeIndex else { continue }
                    let dx = positions[nodeIndex].x - positions[neighborIndex].x
                    let dy = positions[nodeIndex].y - positions[neighborIndex].y
                    let dist = max(sqrt(dx * dx + dy * dy), 0.01)
                    let force = (dist * dist) / optimalDistance
                    let fx = (dx / dist) * force
                    let fy = (dy / dist) * force
                    displacements[nodeIndex].x -= fx
                    displacements[nodeIndex].y -= fy
                    displacements[neighborIndex].x += fx
                    displacements[neighborIndex].y += fy
                }
            }

            // Apply displacements with temperature limiting
            for nodeIndex in 0..<count {
                let dx = displacements[nodeIndex].x
                let dy = displacements[nodeIndex].y
                let dist = max(sqrt(dx * dx + dy * dy), 0.01)
                let limitedDist = min(dist, temperature)
                positions[nodeIndex].x += (dx / dist) * limitedDist
                positions[nodeIndex].y += (dy / dist) * limitedDist
                // Clamp within bounds
                positions[nodeIndex].x = max(margin, min(width - margin, positions[nodeIndex].x))
                positions[nodeIndex].y = max(margin, min(height - margin, positions[nodeIndex].y))
            }

            // Cool down
            temperature *= 0.9
        }

        return positions
    }

    private static func isGraphUndirected(adjacency: [Set<Int>]) -> Bool {
        for (index, neighbors) in adjacency.enumerated() {
            for neighbor in neighbors {
                guard neighbor >= 0, neighbor < adjacency.count else { continue }
                if !adjacency[neighbor].contains(index) {
                    return false
                }
            }
        }
        return true
    }
}
