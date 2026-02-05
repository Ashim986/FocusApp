import SwiftUI

struct SequenceBubbleRow: View {
    let items: [TraceValue]
    let showIndices: Bool
    let cycleIndex: Int?
    let isTruncated: Bool
    let isDoubly: Bool
    let pointers: [PointerMarker]

    let bubbleSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    let pointerSpacing: CGFloat

    private var centerSpacing: CGFloat { bubbleSize * 1.9 }
    private var labelHeight: CGFloat { bubbleSize * 0.4 }
    private let labelSpacing: CGFloat = 4
    private var arrowGap: CGFloat { bubbleSize * 0.2 }
    private var arrowLineWidth: CGFloat { max(1.5, bubbleSize * 0.067) }
    private var arrowHeadSize: CGFloat { bubbleSize * 0.27 }
    private let arrowColor = Color.appPurple.opacity(0.8)
    private var loopArrowHeight: CGFloat { bubbleSize * 0.6 }
    private let loopArrowColor = Color.appPurple.opacity(0.95)
    private var doublyOffset: CGFloat { bubbleSize * 0.27 }
    private var pointerHeight: CGFloat { pointerFontSize + pointerVerticalPadding * 2 + 4 }

    init(
        items: [TraceValue],
        showIndices: Bool,
        cycleIndex: Int?,
        isTruncated: Bool,
        isDoubly: Bool,
        pointers: [PointerMarker],
        bubbleSize: CGFloat = 30,
        pointerFontSize: CGFloat = 8,
        pointerHorizontalPadding: CGFloat = 6,
        pointerVerticalPadding: CGFloat = 2,
        pointerSpacing: CGFloat = 2
    ) {
        self.items = items
        self.showIndices = showIndices
        self.cycleIndex = cycleIndex
        self.isTruncated = isTruncated
        self.isDoubly = isDoubly
        self.pointers = pointers
        self.bubbleSize = bubbleSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
        self.pointerSpacing = pointerSpacing
    }

    var body: some View {
        let bubbleItems = bubbleItems(for: renderItems)
        let cycleTarget = resolvedCycleIndex
        let loopInset = cycleTarget == nil ? 0 : loopArrowHeight
        let maxPointerCount = pointersByIndex.values.map(\.count).max() ?? 0
        let pointerInset = maxPointerCount == 0
            ? 0
            : CGFloat(maxPointerCount) * (pointerHeight + pointerSpacing) + 4
        let groupHeight = bubbleSize + (showIndices ? (labelHeight + labelSpacing) : 0)
        let rowHeight = groupHeight + loopInset + pointerInset + (isDoubly ? doublyOffset : 0)
        let totalWidth = bubbleSize + CGFloat(max(renderItems.count - 1, 0)) * centerSpacing

        return ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    guard renderItems.count > 1 else { return }
                    let y = loopInset + pointerInset + bubbleSize / 2
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

                        if isDoubly {
                            let backY = y + doublyOffset
                            let backStart = CGPoint(
                                x: xPosition(for: index + 1) - bubbleRadius - arrowGap,
                                y: backY
                            )
                            let backEnd = CGPoint(
                                x: xPosition(for: index) + bubbleRadius + arrowGap,
                                y: backY
                            )
                            guard backStart.x > backEnd.x else { continue }
                            var backPath = Path()
                            backPath.move(to: backStart)
                            backPath.addLine(to: backEnd)
                            context.stroke(backPath, with: .color(arrowColor.opacity(0.75)), lineWidth: 1.6)
                            drawArrowHead(
                                context: &context,
                                from: backStart,
                                to: backEnd,
                                color: arrowColor.opacity(0.85)
                            )
                        }
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
                    ZStack(alignment: .top) {
                        VStack(spacing: showIndices ? labelSpacing : 0) {
                            TraceBubble(text: model.text, fill: model.fill, size: bubbleSize)
                            if showIndices {
                                Text("\(index)")
                                    .font(.system(size: max(8, bubbleSize * 0.28), weight: .semibold))
                                    .foregroundColor(Color.appGray500)
                                    .frame(height: labelHeight)
                            }
                        }
                        if let pointerStack = pointersByIndex[index] {
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
                            .offset(y: -pointerInset)
                        }
                    }
                    .frame(width: bubbleSize, height: groupHeight, alignment: .top)
                    .position(x: xPosition(for: index), y: loopInset + pointerInset + groupHeight / 2)
                }
            }
            .frame(width: totalWidth, height: rowHeight)
            .padding(.vertical, 2)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: renderItems)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: pointers.map(\.id))
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
        let span = abs(start.x - end.x)
        let additionalLift = min(36, max(12, span * 0.2))
        let controlY = max(2, y - bubbleRadius - loopInset - additionalLift)
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
        case .list(let list):
            return "l\(list.nodes.count)-\(list.cycleIndex ?? -1)-\(list.isTruncated)-\(list.isDoubly)"
        case .tree(let tree):
            return "t\(tree.nodes.count)-\(tree.rootId ?? "nil")"
        case .listPointer(let id), .treePointer(let id):
            return "p\(id)"
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

    private var pointersByIndex: [Int: [PointerMarker]] {
        var grouped: [Int: [PointerMarker]] = [:]
        for pointer in pointers {
            guard let index = pointer.index else { continue }
            grouped[index, default: []].append(pointer)
        }
        return grouped
    }
}

struct TraceBubbleItem: Identifiable {
    let id: String
    let value: TraceValue
}
