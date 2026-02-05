import SwiftUI

struct DataJourneyView: View {
    let events: [DataJourneyEvent]
    @Binding var selectedEventID: UUID?
    let onSelectEvent: (DataJourneyEvent) -> Void
    let isTruncated: Bool
    @State private var isPlaying = false
    @State private var playbackSpeed = 1.0
    @State private var playbackTask: Task<Void, Never>?

    var body: some View {
        if events.isEmpty || hasNoData {
            emptyState
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let input = inputEvent {
                valuesSection(title: "Input", event: input)
            }

            if !playbackEvents.isEmpty {
                stepControls
            }

            if let selected = selectedEvent {
                valuesSection(title: selectedTitle(for: selected), event: selected)
            }

            if let output = outputEvent {
                valuesSection(title: "Output", event: output)
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Run with input to see the data journey.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.appGray300)
            Text("Add `Trace.step(\"label\", [\"key\": value])` inside loops to visualize iterations.")
                .font(.system(size: 10))
                .foregroundColor(Color.appGray500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button(action: selectPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundColor(currentPlaybackIndex == 0 ? Color.appGray600 : Color.appGray300)
                .disabled(currentPlaybackIndex == 0)

                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundColor(playbackEvents.count > 1 ? Color.appGray300 : Color.appGray600)
                .disabled(playbackEvents.count <= 1)

                Button(action: selectNext) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundColor(currentPlaybackIndex >= playbackEvents.count - 1 ? Color.appGray600 : Color.appGray300)
                .disabled(currentPlaybackIndex >= playbackEvents.count - 1)

                Text(stepLabel(for: playbackEvents[currentPlaybackIndex]))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray300)

                Spacer()

                Picker("Speed", selection: $playbackSpeed) {
                    Text("0.5x").tag(0.5)
                    Text("1x").tag(1.0)
                    Text("1.5x").tag(1.5)
                    Text("2x").tag(2.0)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)

                if !isPlaying, currentPlaybackIndex >= playbackEvents.count - 1 {
                    Button(action: { selectIndex(0) }) {
                        Text("Start Over")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.appGray200)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.appGray800)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Slider(
                value: Binding(
                    get: { Double(currentPlaybackIndex) },
                    set: { selectIndex(Int($0)) }
                ),
                in: 0...Double(max(playbackEvents.count - 1, 0)),
                step: 1
            )
            .tint(Color.appPurple)

            if isTruncated {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.appAmber)
                    Text("Showing first 40 steps. Reduce `Trace.step` calls to see more.")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.appAmber)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(playbackEvents) { event in
                        Button(action: {
                            selectEvent(event)
                        }, label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(event.id == selectedEventID ? Color.appPurple : Color.appGray600)
                                    .frame(width: 6, height: 6)
                                Text(stepLabel(for: event))
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(event.id == selectedEventID ? Color.appPurple.opacity(0.2) : Color.appGray800)
                            )
                        })
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray900.opacity(0.35))
        )
        .onChange(of: isPlaying) { _, playing in
            playbackTask?.cancel()
            guard playing else { return }
            playbackTask = Task {
                await runPlaybackLoop()
            }
        }
        .onChange(of: events.map(\.id)) { _, _ in
            isPlaying = false
            playbackTask?.cancel()
            ensurePlaybackSelection()
        }
        .onAppear {
            ensurePlaybackSelection()
        }
        .onDisappear {
            playbackTask?.cancel()
        }
    }

    private func valuesSection(title: String, event: DataJourneyEvent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.appGray400)

            if event.values.isEmpty {
                Text("No values captured for this step.")
                    .font(.system(size: 10))
                    .foregroundColor(Color.appGray500)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(event.values.keys.sorted(), id: \.self) { key in
                        if let value = event.values[key] {
                            HStack(alignment: .center, spacing: 10) {
                                Text(key)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color.appGray300)
                                    .frame(width: 80, alignment: .leading)

                                TraceValueView(value: value)
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray900.opacity(0.45))
        )
    }

    private var inputEvent: DataJourneyEvent? {
        events.first(where: { $0.kind == .input })
    }

    private var outputEvent: DataJourneyEvent? {
        events.first(where: { $0.kind == .output })
    }

    private var stepEvents: [DataJourneyEvent] {
        events.filter { $0.kind == .step }
    }

    private var playbackEvents: [DataJourneyEvent] {
        if !stepEvents.isEmpty {
            return stepEvents
        }
        return [inputEvent, outputEvent].compactMap { $0 }
    }

    private var selectedEvent: DataJourneyEvent? {
        if let selectedEventID, let event = events.first(where: { $0.id == selectedEventID }) {
            return event
        }
        return stepEvents.first ?? inputEvent ?? outputEvent
    }

    private var hasNoData: Bool {
        let hasValues = events.contains { !$0.values.isEmpty }
        return !hasValues
    }

    private func stepLabel(for event: DataJourneyEvent) -> String {
        if let label = event.label, !label.isEmpty {
            return label
        }
        let index = stepEvents.firstIndex(where: { $0.id == event.id }) ?? 0
        return "Step \(index + 1)"
    }

    private func selectedTitle(for event: DataJourneyEvent) -> String {
        switch event.kind {
        case .input:
            return "Input"
        case .output:
            return "Output"
        case .step:
            return stepLabel(for: event)
        }
    }

    private var currentPlaybackIndex: Int {
        guard !playbackEvents.isEmpty else { return 0 }
        if let selectedEventID,
           let index = playbackEvents.firstIndex(where: { $0.id == selectedEventID }) {
            return index
        }
        return 0
    }

    private func ensurePlaybackSelection() {
        guard !playbackEvents.isEmpty else { return }
        if let selectedEventID,
           playbackEvents.contains(where: { $0.id == selectedEventID }) {
            return
        }
        selectEvent(playbackEvents[0])
    }

    private func selectEvent(_ event: DataJourneyEvent) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedEventID = event.id
            onSelectEvent(event)
        }
    }

    private func selectIndex(_ index: Int) {
        guard playbackEvents.indices.contains(index) else { return }
        selectEvent(playbackEvents[index])
    }

    private func selectPrevious() {
        selectIndex(max(currentPlaybackIndex - 1, 0))
    }

    private func selectNext() {
        selectIndex(min(currentPlaybackIndex + 1, playbackEvents.count - 1))
    }

    private func togglePlayback() {
        guard playbackEvents.count > 1 else { return }
        if !isPlaying && currentPlaybackIndex >= playbackEvents.count - 1 {
            selectIndex(0)
        }
        isPlaying.toggle()
    }

    @MainActor
    private func runPlaybackLoop() async {
        while isPlaying {
            let interval = max(0.2, 1.0 / playbackSpeed)
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            guard isPlaying else { break }
            if currentPlaybackIndex >= playbackEvents.count - 1 {
                isPlaying = false
                break
            }
            selectNext()
        }
    }
}

private struct TraceValueView: View {
    let value: TraceValue

    var body: some View {
        switch value {
        case .null:
            bubble(for: value)
        case .bool(let boolValue):
            bubble(for: .bool(boolValue))
        case .number(let number, let isInt):
            bubble(for: .number(number, isInt: isInt))
        case .string(let stringValue):
            bubble(for: .string(stringValue))
        case .array(let items):
            arrayView(items)
        case .object(let map):
            objectView(map)
        case .typed(let type, let inner):
            typedView(type: type, value: inner)
        }
    }

    @ViewBuilder
    private func arrayView(_ items: [TraceValue]) -> some View {
        if let adjacency = adjacencyList(from: items) {
            GraphView(adjacency: adjacency)
        } else {
            sequenceView(items, showIndices: true)
        }
    }

    private func objectView(_ map: [String: TraceValue]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(map.keys.sorted(), id: \.self) { key in
                if let value = map[key] {
                    HStack(spacing: 6) {
                        Text(key)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color.appGray400)
                        TraceValueView(value: value)
                    }
                }
            }
        }
    }

    private func typedView(type: String, value: TraceValue) -> some View {
        switch type.lowercased() {
        case "list":
            return AnyView(listView(value))
        case "tree":
            return AnyView(treeView(value))
        default:
            return AnyView(TraceValueView(value: value))
        }
    }

    private func listView(_ value: TraceValue) -> some View {
        guard case .array(let items) = value else {
            return AnyView(TraceValueView(value: value))
        }
        return AnyView(
            sequenceView(items, showIndices: false)
        )
    }

    private func treeView(_ value: TraceValue) -> some View {
        guard case .array(let items) = value else {
            return AnyView(TraceValueView(value: value))
        }
        return AnyView(TreeGraphView(items: items))
    }

    private func sequenceView(_ items: [TraceValue], showIndices: Bool) -> some View {
        SequenceBubbleRow(items: items, showIndices: showIndices)
    }

    private func bubble(for value: TraceValue) -> some View {
        let model = TraceBubbleModel.from(value)
        return TraceBubble(text: model.text, fill: model.fill)
    }

    private func adjacencyList(from items: [TraceValue]) -> [[Int]]? {
        guard !items.isEmpty else { return nil }
        var lists: [[Int]] = []
        var allCounts: [Int] = []

        for item in items {
            guard case .array(let inner) = item else { return nil }
            var neighbors: [Int] = []
            for value in inner {
                guard case .number(let number, let isInt) = value else { return nil }
                let intValue = Int(number)
                if isInt == false, Double(intValue) != number { return nil }
                neighbors.append(intValue)
            }
            lists.append(neighbors)
            allCounts.append(inner.count)
        }

        let nodeCount = items.count
        if allCounts.allSatisfy({ $0 == nodeCount }) {
            let matrixValues = lists.flatMap { $0 }
            if matrixValues.allSatisfy({ $0 == 0 || $0 == 1 }) {
                return nil
            }
        }

        return lists
    }
}

private struct TreeGraphView: View {
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

private struct TraceValueNode: View {
    let value: TraceValue

    var body: some View {
        let model = TraceBubbleModel.from(value, compact: true)
        return TraceBubble(text: model.text, fill: model.fill)
    }
}

private struct SequenceBubbleRow: View {
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

private struct TraceBubbleItem: Identifiable {
    let id: String
    let value: TraceValue
}

private struct TreeLayout {
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

private struct GraphView: View {
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

private struct GraphLayout {
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

private struct TraceBubble: View {
    let text: String
    let fill: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 4)
        }
        .frame(width: 30, height: 30)
    }
}

private struct TraceBubbleModel {
    let text: String
    let fill: Color

    static func from(_ value: TraceValue, compact: Bool = false) -> TraceBubbleModel {
        switch value {
        case .null:
            return TraceBubbleModel(text: "nil", fill: Color.appGray700)
        case .bool(let boolValue):
            return TraceBubbleModel(
                text: boolValue ? "true" : "false",
                fill: Color.appPurple.opacity(0.3)
            )
        case .number(let number, let isInt):
            let text = isInt ? "\(Int(number))" : String(format: "%.2f", number)
            return TraceBubbleModel(text: text, fill: Color.appAmber.opacity(0.3))
        case .string(let stringValue):
            return TraceBubbleModel(text: stringValue, fill: Color.appGreen.opacity(0.25))
        case .array(let items):
            let label = compact ? "\(items.count)" : "[\(items.count)]"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .object(let map):
            let label = compact ? "\(map.count)" : "{\(map.count)}"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .typed(_, let inner):
            return from(inner, compact: compact)
        }
    }
}
