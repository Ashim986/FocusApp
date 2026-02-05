import SwiftUI

struct SequenceBubbleRow: View {
    let items: [TraceValue]
    let showIndices: Bool

    private let bubbleSize: CGFloat = 30
    private let centerSpacing: CGFloat = 58
    private let labelHeight: CGFloat = 12
    private let labelSpacing: CGFloat = 4
    private let arrowGap: CGFloat = 6
    private let arrowLineWidth: CGFloat = 2
    private let arrowHeadSize: CGFloat = 8
    private let arrowColor = Color.appCyan.opacity(0.8)

    var body: some View {
        let rowHeight = bubbleSize + (showIndices ? (labelHeight + labelSpacing) : 0)
        let totalWidth = bubbleSize + CGFloat(max(items.count - 1, 0)) * centerSpacing
        let bubbleItems = bubbleItems(for: items)

        return ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    guard items.count > 1 else { return }
                    let y = bubbleSize / 2
                    let bubbleRadius = bubbleSize / 2
                    for index in 0..<(items.count - 1) {
                        let start = CGPoint(
                            x: xPosition(for: index) + bubbleRadius + arrowGap,
                            y: y
                        )
                        let end = CGPoint(
                            x: xPosition(for: index + 1) - bubbleRadius - arrowGap,
                            y: y
                        )
                        guard end.x > start.x else { continue }
                        var path = Path()
                        path.move(to: start)
                        path.addLine(to: end)
                        context.stroke(path, with: .color(arrowColor), lineWidth: arrowLineWidth)
                        drawArrowHead(context: &context, from: start, to: end)
                    }
                }
                .frame(width: totalWidth, height: rowHeight)

                ForEach(Array(bubbleItems.enumerated()), id: \.element.id) { index, item in
                    let model = TraceBubbleModel.from(item.value)
                    VStack(spacing: showIndices ? labelSpacing : 0) {
                        TraceBubble(text: model.text, fill: model.fill)
                        if showIndices {
                            Text("\(index)")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(Color.appGray500)
                                .frame(height: labelHeight)
                        }
                    }
                    .frame(width: bubbleSize, height: rowHeight, alignment: .top)
                    .position(x: xPosition(for: index), y: rowHeight / 2)
                }
            }
            .frame(width: totalWidth, height: rowHeight)
            .padding(.vertical, 2)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: items)
    }

    private func xPosition(for index: Int) -> CGFloat {
        CGFloat(index) * centerSpacing + bubbleSize / 2
    }

    private func drawArrowHead(context: inout GraphicsContext, from: CGPoint, to: CGPoint) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let length = max(sqrt(dx * dx + dy * dy), 0.001)
        let ux = dx / length
        let uy = dy / length
        let base = CGPoint(x: to.x - ux * arrowHeadSize, y: to.y - uy * arrowHeadSize)
        let perp = CGPoint(x: -uy, y: ux)
        let halfWidth = arrowHeadSize * 0.6
        let left = CGPoint(x: base.x + perp.x * halfWidth, y: base.y + perp.y * halfWidth)
        let right = CGPoint(x: base.x - perp.x * halfWidth, y: base.y - perp.y * halfWidth)
        var head = Path()
        head.move(to: to)
        head.addLine(to: left)
        head.addLine(to: right)
        head.closeSubpath()
        context.fill(head, with: .color(arrowColor))
    }

    private func bubbleItems(for items: [TraceValue]) -> [TraceBubbleItem] {
        var counts: [String: Int] = [:]
        return items.map { value in
            let key = identityKey(for: value)
            let occurrence = (counts[key] ?? 0) + 1
            counts[key] = occurrence
            return TraceBubbleItem(id: "\(key)#\(occurrence)", value: value)
        }
    }

    private func identityKey(for value: TraceValue) -> String {
        switch value {
        case .null:
            return "nil"
        case .bool(let boolValue):
            return boolValue ? "true" : "false"
        case .number(let number, let isInt):
            return isInt ? "i\(Int(number))" : "d\(number)"
        case .string(let stringValue):
            return "s\(stringValue)"
        case .array(let items):
            return "a\(items.count)"
        case .object(let map):
            return "o\(map.count)"
        case .typed(let type, let inner):
            return "t\(type)-\(identityKey(for: inner))"
        }
    }
}

struct TraceBubbleItem: Identifiable {
    let id: String
    let value: TraceValue
}
