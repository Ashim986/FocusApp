import SwiftUI

struct GraphView: View {
    let adjacency: [[Int]]
    private let nodeSize: CGFloat = 30

    var body: some View {
        GeometryReader { proxy in
            let layout = GraphLayout(adjacency: adjacency, size: proxy.size, nodeSize: nodeSize)
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
                    TraceBubble(text: "\(node.index)", fill: Color.appGray700)
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
    }

    let nodes: [Node]
    let edges: [Edge]
    let height: CGFloat

    init(adjacency: [[Int]], size: CGSize, nodeSize: CGFloat) {
        let count = adjacency.count
        let safeWidth = max(size.width, nodeSize * 4)
        let safeHeight = max(size.height, nodeSize * 4)
        let radius = max(10, min(safeWidth, safeHeight) * 0.5 - nodeSize)
        let center = CGPoint(x: safeWidth / 2, y: safeHeight / 2)

        var positions: [Int: CGPoint] = [:]
        var nodes: [Node] = []
        for index in 0..<count {
            let angle = (Double(index) / Double(max(count, 1))) * (2 * Double.pi) - Double.pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            let position = CGPoint(x: x, y: y)
            positions[index] = position
            nodes.append(Node(index: index, position: position))
        }

        let adjacencySets: [Set<Int>] = adjacency.map { Set($0) }
        let isUndirected = GraphLayout.isGraphUndirected(adjacency: adjacencySets)

        var edges: [Edge] = []
        for index in 0..<count {
            for neighbor in adjacency[index] {
                guard neighbor >= 0, neighbor < count else { continue }
                if isUndirected && neighbor < index { continue }
                guard let from = positions[index], let to = positions[neighbor] else { continue }
                edges.append(Edge(from: from, to: to))
            }
        }

        self.nodes = nodes
        self.edges = edges
        self.height = safeHeight
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
