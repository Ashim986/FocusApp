import SwiftUI

struct TreeGraphView: View {
    let items: [TraceValue]
    private let nodeSize: CGFloat = 30
    private let levelSpacing: CGFloat = 50

    var body: some View {
        GeometryReader { proxy in
            let layout = TreeLayout(items: items, size: proxy.size, nodeSize: nodeSize, levelSpacing: levelSpacing)
            ZStack {
                Canvas { context, _ in
                    for edge in layout.edges {
                        var path = Path()
                        path.move(to: edge.from)
                        path.addLine(to: edge.to)
                        context.stroke(path, with: .color(Color.appGray600.opacity(0.6)), lineWidth: 1)
                    }
                }

                ForEach(layout.nodes) { node in
                    TraceValueNode(value: node.value)
                        .position(node.position)
                }
            }
            .frame(height: layout.height)
        }
        .frame(minHeight: nodeSize + levelSpacing)
    }
}

struct TraceValueNode: View {
    let value: TraceValue

    var body: some View {
        let model = TraceBubbleModel.from(value, compact: true)
        return TraceBubble(text: model.text, fill: model.fill)
    }
}

struct TreeLayout {
    struct Node: Identifiable {
        let id = UUID()
        let index: Int
        let value: TraceValue
        let position: CGPoint
    }

    struct Edge: Identifiable {
        let id = UUID()
        let from: CGPoint
        let to: CGPoint
    }

    let nodes: [Node]
    let edges: [Edge]
    let height: CGFloat

    init(items: [TraceValue], size: CGSize, nodeSize: CGFloat, levelSpacing: CGFloat) {
        var nodes: [Node] = []
        var positions: [Int: CGPoint] = [:]
        var maxLevel = 0

        for (index, value) in items.enumerated() {
            let level = TreeLayout.level(for: index)
            maxLevel = max(maxLevel, level)
            let indexInLevel = index - (1 << level) + 1
            let countAtLevel = 1 << level
            let x = CGFloat(indexInLevel + 1) * size.width / CGFloat(countAtLevel + 1)
            let y = CGFloat(level) * levelSpacing + nodeSize / 2
            let position = CGPoint(x: x, y: y)
            nodes.append(Node(index: index, value: value, position: position))
            positions[index] = position
        }

        var edges: [Edge] = []
        for node in nodes {
            guard node.index > 0 else { continue }
            let parentIndex = (node.index - 1) / 2
            if parentIndex < items.count, items[parentIndex] == .null {
                continue
            }
            guard let parentPosition = positions[parentIndex] else { continue }
            let from = CGPoint(x: parentPosition.x, y: parentPosition.y + nodeSize / 2)
            let to = CGPoint(x: node.position.x, y: node.position.y - nodeSize / 2)
            edges.append(Edge(from: from, to: to))
        }

        self.nodes = nodes
        self.edges = edges
        self.height = CGFloat(maxLevel + 1) * levelSpacing + nodeSize
    }

    private static func level(for index: Int) -> Int {
        var level = 0
        var maxIndexAtLevel = 0
        var nodesAtLevel = 1
        while index > maxIndexAtLevel {
            level += 1
            nodesAtLevel *= 2
            maxIndexAtLevel += nodesAtLevel
        }
        return level
    }
}
