import FocusDesignSystem
import SwiftUI

/// Collapsible timeline showing how each variable evolves across all playback steps.
struct VariableTimelineView: View {
    let events: [DataJourneyEvent]
    let currentIndex: Int
    let onSelectIndex: (Int) -> Void

    @State private var isExpanded = false
    @Environment(\.dsTheme) private var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    var body: some View {
        let variableNames = collectVariableNames()
        guard !variableNames.isEmpty, events.count >= 2 else {
            return AnyView(EmptyView())
        }
        return AnyView(
            VStack(alignment: .leading, spacing: 6) {
                DSButton(
                    action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } },
                    label: {
                        HStack(spacing: 4) {
                            DSImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(palette.gray400)
                            DSText("Timeline")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(palette.gray400)
                            Spacer()
                        }
                    }
                )
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(variableNames, id: \.self) { name in
                            let series = extractSeries(for: name)
                            HStack(alignment: .center, spacing: 8) {
                                    DSText(name)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(palette.gray300)
                                        .frame(width: 60, alignment: .trailing)

                                timelineRow(series: series)
                            }
                        }
                    }
                    .padding(.leading, 12)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(palette.gray900.opacity(0.3))
            )
        )
    }

    // MARK: - Timeline Row

    @ViewBuilder
    private func timelineRow(series: [TimelinePoint]) -> some View {
        let allNumeric = series.allSatisfy { $0.kind == .numeric }
        let allCollection = series.allSatisfy { $0.kind == .collection }

        if allNumeric {
            sparklineView(series: series)
        } else if allCollection {
            barChartView(series: series)
        } else {
            dotView(series: series)
        }
    }

    // MARK: - Sparkline (numeric values)

    private func sparklineView(series: [TimelinePoint]) -> some View {
        let values = series.map { $0.numericValue ?? 0 }
        let minVal = values.min() ?? 0
        let maxVal = values.max() ?? 1
        let range = max(maxVal - minVal, 1)
        let width: CGFloat = CGFloat(series.count) * 12
        let height: CGFloat = 24

        return ZStack(alignment: .topLeading) {
            Canvas { context, size in
                guard values.count > 1 else { return }
                var path = Path()
                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) / CGFloat(max(values.count - 1, 1)) * size.width
                    let y = size.height - ((value - minVal) / range) * size.height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(path, with: .color(palette.cyan.opacity(0.7)), lineWidth: 1.5)

                // Current index marker
                if currentIndex < values.count {
                    let cx = CGFloat(currentIndex) / CGFloat(max(values.count - 1, 1)) * size.width
                    let cy = size.height - ((values[currentIndex] - minVal) / range) * size.height
                    var dot = Path()
                    dot.addEllipse(in: CGRect(x: cx - 3, y: cy - 3, width: 6, height: 6))
                    context.fill(dot, with: .color(palette.cyan))
                }
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .onTapGesture { location in
                let index = Int((location.x / width) * CGFloat(series.count))
                let clampedIndex = max(0, min(series.count - 1, index))
                onSelectIndex(clampedIndex)
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: - Bar Chart (collection sizes)

    private func barChartView(series: [TimelinePoint]) -> some View {
        let sizes = series.map { $0.collectionSize ?? 0 }
        let maxSize = CGFloat(sizes.max() ?? 1)
        let barWidth: CGFloat = 8
        let spacing: CGFloat = 3
        let height: CGFloat = 24

        return HStack(alignment: .bottom, spacing: spacing) {
            ForEach(Array(sizes.enumerated()), id: \.offset) { index, size in
                let barHeight = max(2, (CGFloat(size) / max(maxSize, 1)) * height)
                let isCurrent = index == currentIndex
                RoundedRectangle(cornerRadius: 2)
                    .fill(isCurrent ? palette.cyan : palette.purple.opacity(0.5))
                    .frame(width: barWidth, height: barHeight)
                    .onTapGesture { onSelectIndex(index) }
            }
        }
        .frame(height: height, alignment: .bottom)
    }

    // MARK: - Dot View (mixed/boolean)

    private func dotView(series: [TimelinePoint]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(series.enumerated()), id: \.offset) { index, point in
                let isCurrent = index == currentIndex
                Circle()
                    .fill(dotColor(for: point))
                    .frame(width: isCurrent ? 8 : 6, height: isCurrent ? 8 : 6)
                    .overlay(
                        isCurrent ? Circle().stroke(Color.white, lineWidth: 1) : nil
                    )
                    .onTapGesture { onSelectIndex(index) }
            }
        }
    }

    private func dotColor(for point: TimelinePoint) -> Color {
        switch point.kind {
        case .boolTrue:
            return palette.green
        case .boolFalse:
            return palette.red
        case .null:
            return palette.gray600
        default:
            return palette.amber.opacity(0.6)
        }
    }

    // MARK: - Data Extraction

    private func collectVariableNames() -> [String] {
        var names: [String] = []
        var seen: Set<String> = []
        for event in events {
            for key in event.values.keys.sorted() where seen.insert(key).inserted {
                names.append(key)
            }
        }
        return names
    }

    private func extractSeries(for name: String) -> [TimelinePoint] {
        events.map { event in
            guard let value = event.values[name] else {
                return TimelinePoint(kind: .null, numericValue: nil, collectionSize: nil)
            }
            return timelinePoint(from: value)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func timelinePoint(from value: TraceValue) -> TimelinePoint {
        switch value {
        case .null:
            return TimelinePoint(kind: .null, numericValue: nil, collectionSize: nil)
        case .bool(let boolValue):
            return TimelinePoint(
                kind: boolValue ? .boolTrue : .boolFalse,
                numericValue: boolValue ? 1 : 0,
                collectionSize: nil
            )
        case .number(let num, _):
            return TimelinePoint(kind: .numeric, numericValue: num, collectionSize: nil)
        case .string(let str):
            return TimelinePoint(kind: .collection, numericValue: nil, collectionSize: str.count)
        case .array(let items):
            return TimelinePoint(kind: .collection, numericValue: nil, collectionSize: items.count)
        case .list(let list):
            return TimelinePoint(kind: .collection, numericValue: nil, collectionSize: list.nodes.count)
        case .tree(let tree):
            return TimelinePoint(kind: .collection, numericValue: nil, collectionSize: tree.nodes.count)
        case .object(let map):
            return TimelinePoint(kind: .collection, numericValue: nil, collectionSize: map.count)
        case .trie(let trieData):
            return TimelinePoint(kind: .collection, numericValue: nil, collectionSize: trieData.nodes.count)
        case .listPointer, .treePointer:
            return TimelinePoint(kind: .other, numericValue: nil, collectionSize: nil)
        case .typed(_, let inner):
            return timelinePoint(from: inner)
        }
    }
}

// MARK: - Supporting Types

struct TimelinePoint {
    enum Kind {
        case numeric
        case collection
        case boolTrue
        case boolFalse
        case null
        case other
    }

    let kind: Kind
    let numericValue: Double?
    let collectionSize: Int?
}
