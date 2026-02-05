import SwiftUI

struct SequenceBubbleRow: View {
    let items: [TraceValue]
    let showIndices: Bool
    let cycleIndex: Int?
    let isTruncated: Bool
    let isDoubly: Bool
    let pointers: [PointerMarker]
    let pointerMotions: [PointerMotion]
    let sequenceLinks: [SequenceLink]
    let gapIndices: Set<Int>
    let bubbleStyle: TraceBubble.Style

    let bubbleSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    let pointerSpacing: CGFloat

    private var centerSpacing: CGFloat { bubbleSize * 1.9 }
    private var labelHeight: CGFloat { bubbleSize * 0.4 }
    private let labelSpacing: CGFloat = 4
    private var arrowGap: CGFloat { bubbleSize * 0.06 }
    private var arrowLineWidth: CGFloat { max(1.5, bubbleSize * 0.067) }
    private var arrowHeadSize: CGFloat { bubbleSize * 0.27 }
    private var pointerMotionInset: CGFloat { pointerMotions.isEmpty ? 0 : max(12, bubbleSize * 0.55) }
    private var sequenceInset: CGFloat { sequenceLinks.isEmpty ? 0 : max(14, bubbleSize * 0.85) }
    private var sequenceClearance: CGFloat { bubbleSize * 0.25 }
    private var motionInset: CGFloat { pointerMotionInset + sequenceInset }
    private var gapSpacing: CGFloat { max(10, bubbleSize * 0.8) }
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
        pointerMotions: [PointerMotion] = [],
        sequenceLinks: [SequenceLink] = [],
        gapIndices: Set<Int> = [],
        bubbleStyle: TraceBubble.Style = .solid,
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
        self.pointerMotions = pointerMotions
        self.sequenceLinks = sequenceLinks
        self.gapIndices = gapIndices
        self.bubbleStyle = bubbleStyle
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
        let motionInset = motionInset
        let maxPointerCount = pointersByIndex.values.map(\.count).max() ?? 0
        let pointerInset = maxPointerCount == 0
            ? 0
            : CGFloat(maxPointerCount) * (pointerHeight + pointerSpacing) + 4
        let groupHeight = bubbleSize + (showIndices ? (labelHeight + labelSpacing) : 0)
        let totalWidth = (xPositions.last ?? bubbleSize / 2) + bubbleSize / 2
        let sequenceOffsets = sequenceLaneOffsets(for: sequenceLinks)
        let baseRowTop = loopInset + pointerInset + motionInset
        let baseHeight = groupHeight + loopInset + pointerInset + motionInset + (isDoubly ? doublyOffset : 0)
        let arcBaseOffset = bubbleSize / 2 + arrowGap
        let (minOffset, maxOffset) = sequenceArcOffsets(
            links: sequenceLinks,
            laneOffsets: sequenceOffsets,
            arcBaseOffset: arcBaseOffset
        )
        let extraTop = max(0, -(baseRowTop + bubbleSize / 2 + minOffset))
        let extraBottom = max(0, baseRowTop + bubbleSize / 2 + maxOffset - baseHeight)
        let rowHeight = baseHeight + extraTop + extraBottom
        let rowCenterY = baseRowTop + extraTop + bubbleSize / 2
        let topBaseY = rowCenterY - arcBaseOffset
        let bottomBaseY = rowCenterY + arcBaseOffset

        return ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    guard renderItems.count > 1 else { return }
                    let y = loopInset + pointerInset + motionInset + bubbleSize / 2
                    let bubbleRadius = bubbleSize / 2
                    for index in 0..<(renderItems.count - 1) {
                        if gapIndices.contains(index) { continue }
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

                    let motionTop = loopInset + pointerInset + extraTop
                    if !sequenceLinks.isEmpty, sequenceInset > 0 {
                        for link in sequenceLinks {
                            drawSequenceLink(
                                context: &context,
                                link: link,
                                topBaseY: topBaseY,
                                bottomBaseY: bottomBaseY,
                                laneOffset: sequenceOffsets[link.id] ?? 0
                            )
                        }
                    }
                    if !pointerMotions.isEmpty, pointerMotionInset > 0 {
                        let pointerY = motionTop + sequenceInset + pointerMotionInset * 0.6
                        for motion in pointerMotions {
                            drawPointerMotion(
                                context: &context,
                                motion: motion,
                                baseY: pointerY
                            )
                        }
                    }
                }
                .frame(width: totalWidth, height: rowHeight)

                ForEach(Array(bubbleItems.enumerated()), id: \.element.id) { index, item in
                    let model = TraceBubbleModel.from(item.value)
                    let fill = model.fill
                    ZStack(alignment: .top) {
                        VStack(spacing: showIndices ? labelSpacing : 0) {
                            TraceBubble(text: model.text, fill: fill, size: bubbleSize, style: bubbleStyle)
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
                    .position(
                        x: xPosition(for: index),
                        y: loopInset + pointerInset + motionInset + extraTop + groupHeight / 2
                    )
                }
            }
            .frame(width: totalWidth, height: rowHeight)
            .padding(.vertical, 2)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: renderItems)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: pointers.map(\.id))
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: pointerMotions.map(\.id))
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: gapIndices)
    }

    private func xPosition(for index: Int) -> CGFloat {
        guard xPositions.indices.contains(index) else { return bubbleSize / 2 }
        return xPositions[index]
    }

    private var xPositions: [CGFloat] {
        guard !renderItems.isEmpty else { return [] }
        var positions: [CGFloat] = []
        var current = bubbleSize / 2
        positions.append(current)
        for index in 1..<renderItems.count {
            let previousIndex = index - 1
            var spacing = centerSpacing
            if gapIndices.contains(previousIndex) {
                spacing += gapSpacing
            }
            current += spacing
            positions.append(current)
        }
        return positions
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

    private func drawPointerMotion(
        context: inout GraphicsContext,
        motion: PointerMotion,
        baseY: CGFloat
    ) {
        let fromIndex = motion.fromIndex
        let toIndex = motion.toIndex
        guard renderItems.indices.contains(fromIndex),
              renderItems.indices.contains(toIndex),
              fromIndex != toIndex else { return }
        let start = CGPoint(x: xPosition(for: fromIndex), y: baseY)
        let end = CGPoint(x: xPosition(for: toIndex), y: baseY)
        let span = abs(end.x - start.x)
        let lift = min(28, max(12, span * 0.25))
        let control = CGPoint(x: (start.x + end.x) / 2, y: baseY - lift)
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        context.stroke(path, with: .color(motion.color.opacity(0.8)), lineWidth: arrowLineWidth)
        drawArrowHead(context: &context, from: control, to: end, color: motion.color.opacity(0.9))
    }

    private func drawSequenceLink(
        context: inout GraphicsContext,
        link: SequenceLink,
        topBaseY: CGFloat,
        bottomBaseY: CGFloat,
        laneOffset: CGFloat
    ) {
        guard renderItems.indices.contains(link.fromIndex),
              renderItems.indices.contains(link.toIndex),
              link.fromIndex != link.toIndex else { return }
        let useBottom = laneOffset >= 0
        let offsetMagnitude = max(abs(laneOffset), sequenceClearance)
        let adjustedY = useBottom
            ? bottomBaseY + offsetMagnitude
            : topBaseY - offsetMagnitude
        let direction: CGFloat = link.toIndex >= link.fromIndex ? 1 : -1
        let inset = bubbleSize / 2 + arrowGap
        let endInset = inset + arrowHeadSize * 0.6
        let start = CGPoint(
            x: xPosition(for: link.fromIndex) + direction * inset,
            y: adjustedY
        )
        let end = CGPoint(
            x: xPosition(for: link.toIndex) - direction * endInset,
            y: adjustedY
        )
        let span = abs(end.x - start.x)
        let liftBase = min(28, max(10, span * 0.24))
        let lift = liftBase + offsetMagnitude * 0.35
        let bendDirection: CGFloat = useBottom ? 1 : -1
        let controlY = adjustedY + bendDirection * lift
        let control = CGPoint(x: (start.x + end.x) / 2, y: controlY)
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        context.stroke(path, with: .color(link.color.opacity(0.85)), lineWidth: arrowLineWidth)
        drawArrowHead(context: &context, from: control, to: end, color: link.color.opacity(0.95))
    }

    private func sequenceLaneOffsets(for links: [SequenceLink]) -> [String: CGFloat] {
        guard !links.isEmpty else { return [:] }
        struct Lane {
            var lastEndX: CGFloat
            let offset: CGFloat
        }
        struct Span {
            let start: CGFloat
            let end: CGFloat
        }
        func overlaps(_ a: Span, _ b: Span) -> Bool {
            a.start < b.end && a.end > b.start
        }
        let unit = max(8, min(sequenceInset * 0.22, bubbleSize * 0.4))
        let startInset = bubbleSize * 0.33
        let endInset = startInset + arrowHeadSize * 0.55
        let minGap = bubbleSize * 0.45
        var topLanes: [Lane] = []
        var bottomLanes: [Lane] = []
        var topSpans: [Span] = []
        var assignments: [String: CGFloat] = [:]
        let sorted = links.compactMap { link -> (SequenceLink, CGFloat, CGFloat, CGFloat)? in
            let direction: CGFloat = link.toIndex >= link.fromIndex ? 1 : -1
            let startX = xPosition(for: link.fromIndex) + direction * startInset
            let endX = xPosition(for: link.toIndex) - direction * endInset
            let normalizedStart = min(startX, endX)
            let normalizedEnd = max(startX, endX)
            if normalizedEnd <= normalizedStart {
                return nil
            }
            return (link, normalizedStart, normalizedEnd, normalizedEnd - normalizedStart)
        }.sorted { lhs, rhs in
            if lhs.3 != rhs.3 { return lhs.3 > rhs.3 }
            return lhs.1 < rhs.1
        }
        for (link, normalizedStart, normalizedEnd, _) in sorted {
            let span = Span(start: normalizedStart, end: normalizedEnd)
            let overlapCount = topSpans.filter { overlaps($0, span) }.count
            let useBottom = overlapCount >= 2
            if useBottom {
                var laneIndex: Int?
                for index in bottomLanes.indices {
                    if normalizedStart > bottomLanes[index].lastEndX + minGap {
                        laneIndex = index
                        break
                    }
                }
                if laneIndex == nil {
                    let idx = bottomLanes.count
                    let magnitude = sequenceClearance + CGFloat(idx) * unit
                    bottomLanes.append(Lane(lastEndX: normalizedEnd, offset: magnitude))
                    laneIndex = idx
                } else if let index = laneIndex {
                    bottomLanes[index].lastEndX = max(bottomLanes[index].lastEndX, normalizedEnd)
                }
                if let index = laneIndex {
                    assignments[link.id] = bottomLanes[index].offset
                }
            } else {
                var laneIndex: Int?
                for index in topLanes.indices {
                    if normalizedStart > topLanes[index].lastEndX + minGap {
                        laneIndex = index
                        break
                    }
                }
                if laneIndex == nil {
                    let idx = topLanes.count
                    let magnitude = sequenceClearance + CGFloat(idx) * unit
                    topLanes.append(Lane(lastEndX: normalizedEnd, offset: -magnitude))
                    laneIndex = idx
                } else if let index = laneIndex {
                    topLanes[index].lastEndX = max(topLanes[index].lastEndX, normalizedEnd)
                }
                if let index = laneIndex {
                    assignments[link.id] = topLanes[index].offset
                }
                topSpans.append(span)
            }
        }
        return assignments
    }

    private func sequenceArcOffsets(
        links: [SequenceLink],
        laneOffsets: [String: CGFloat],
        arcBaseOffset: CGFloat
    ) -> (min: CGFloat, max: CGFloat) {
        guard !links.isEmpty else { return (0, 0) }
        let inset = bubbleSize / 2 + arrowGap
        let endInset = inset + arrowHeadSize * 0.6
        var minOffset: CGFloat = 0
        var maxOffset: CGFloat = 0
        for link in links {
            guard renderItems.indices.contains(link.fromIndex),
                  renderItems.indices.contains(link.toIndex),
                  link.fromIndex != link.toIndex else { continue }
            let laneOffset = laneOffsets[link.id] ?? 0
            let useBottom = laneOffset >= 0
            let offsetMagnitude = max(abs(laneOffset), sequenceClearance)
            let baseOffset = arcBaseOffset + offsetMagnitude
            let direction: CGFloat = link.toIndex >= link.fromIndex ? 1 : -1
            let startX = xPosition(for: link.fromIndex) + direction * inset
            let endX = xPosition(for: link.toIndex) - direction * endInset
            let span = abs(endX - startX)
            let liftBase = min(28, max(10, span * 0.24))
            let lift = liftBase + offsetMagnitude * 0.35
            let offset = useBottom ? baseOffset : -baseOffset
            let controlOffset = useBottom ? offset + lift : offset - lift
            minOffset = min(minOffset, offset, controlOffset)
            maxOffset = max(maxOffset, offset, controlOffset)
        }
        return (minOffset, maxOffset)
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
        for key in grouped.keys {
            grouped[key]?.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        return grouped
    }
}

struct TraceBubbleItem: Identifiable {
    let id: String
    let value: TraceValue
}
