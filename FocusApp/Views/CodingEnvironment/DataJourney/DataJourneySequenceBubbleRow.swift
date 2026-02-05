import SwiftUI

struct SequenceBubbleRow: View {
    let items: [TraceValue]
    let showIndices: Bool
    let cycleIndex: Int?
    let isTruncated: Bool

    private let bubbleSize: CGFloat = 30
    private let centerSpacing: CGFloat = 58
    private let labelHeight: CGFloat = 12
    private let labelSpacing: CGFloat = 4
    private let arrowGap: CGFloat = 6
    private let arrowLineWidth: CGFloat = 2
    private let arrowHeadSize: CGFloat = 8
    private let arrowColor = Color.appCyan.opacity(0.8)
    private let loopArrowHeight: CGFloat = 18
    private let loopArrowColor = Color.appCyan.opacity(0.95)

    var body: some View {
        let bubbleItems = bubbleItems(for: renderItems)
        let cycleTarget = resolvedCycleIndex
        let loopInset = cycleTarget == nil ? 0 : loopArrowHeight
        let groupHeight = bubbleSize + (showIndices ? (labelHeight + labelSpacing) : 0)
        let rowHeight = groupHeight + loopInset
        let totalWidth = bubbleSize + CGFloat(max(renderItems.count - 1, 0)) * centerSpacing

        return ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    guard renderItems.count > 1 else { return }
                    let y = loopInset + bubbleSize / 2
                    let bubbleRadius = bubbleSize / 2
                    for index in 0..<(renderItems.count - 1) {
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
                        drawArrowHead(context: &context, from: start, to: end, color: arrowColor)
                    }

                    if let cycleTarget {
                        let tailIndex = max(items.count - 1, 0)
                        let startX = xPosition(for: tailIndex)
                        let endX = xPosition(for: cycleTarget)
                        drawCycleArrow(
                            context: &context,
                            startX: startX,
                            endX: endX,
                            y: y,
                            bubbleRadius: bubbleRadius,
                            loopInset: loopInset
                        )
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
                    .frame(width: bubbleSize, height: groupHeight, alignment: .top)
                    .position(x: xPosition(for: index), y: loopInset + groupHeight / 2)
                }
            }
            .frame(width: totalWidth, height: rowHeight)
            .padding(.vertical, 2)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: renderItems)
    }

    private func xPosition(for index: Int) -> CGFloat {
        CGFloat(index) * centerSpacing + bubbleSize / 2
    }

    private func drawArrowHead(context: inout GraphicsContext, from: CGPoint, to: CGPoint, color: Color) {
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
        context.fill(head, with: .color(color))
    }

    private func drawCycleArrow(
        context: inout GraphicsContext,
        startX: CGFloat,
        endX: CGFloat,
        y: CGFloat,
        bubbleRadius: CGFloat,
        loopInset: CGFloat
    ) {
        let start = CGPoint(x: startX, y: y - bubbleRadius - 2)
        let end = CGPoint(x: endX, y: y - bubbleRadius - 2)
        if abs(start.x - end.x) < 1 {
            let radius = bubbleRadius * 0.7
            let center = CGPoint(x: start.x, y: start.y - radius - 2)
            let startAngle = Angle.degrees(20)
            let endAngle = Angle.degrees(340)
            var path = Path()
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.stroke(path, with: .color(loopArrowColor), lineWidth: arrowLineWidth)
            let endPoint = point(on: center, radius: radius, angle: endAngle)
            let tangentPoint = point(on: center, radius: radius, angle: Angle.degrees(330))
            drawArrowHead(context: &context, from: tangentPoint, to: endPoint, color: loopArrowColor)
            return
        }
        let controlY = max(2, y - bubbleRadius - loopInset)
        let control = CGPoint(x: (start.x + end.x) / 2, y: controlY)
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        context.stroke(path, with: .color(loopArrowColor), lineWidth: arrowLineWidth)
        drawArrowHead(context: &context, from: control, to: end, color: loopArrowColor)
    }

    private func point(on center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        let radians = CGFloat(angle.radians)
        return CGPoint(
            x: center.x + cos(radians) * radius,
            y: center.y + sin(radians) * radius
        )
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
        case .list(let items, let cycleIndex, let isTruncated):
            return "l\(items.count)-\(cycleIndex ?? -1)-\(isTruncated)"
        case .typed(let type, let inner):
            return "t\(type)-\(identityKey(for: inner))"
        }
    }

    private var renderItems: [TraceValue] {
        if isTruncated {
            return items + [.string("...")]
        }
        return items
    }

    private var resolvedCycleIndex: Int? {
        guard let cycleIndex else { return nil }
        return (0..<items.count).contains(cycleIndex) ? cycleIndex : nil
    }
}

struct TraceBubbleItem: Identifiable {
    let id: String
    let value: TraceValue
}
