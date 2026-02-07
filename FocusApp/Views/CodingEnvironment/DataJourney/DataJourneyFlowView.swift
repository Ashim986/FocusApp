import FocusDesignSystem
import SwiftUI

/// Compact overview showing data transformation flow: Input -> Key Steps -> Output.
/// Each card shows a mini summary of the event's state, connected by flow arrows.
struct DataJourneyFlowView: View {
    let events: [DataJourneyEvent]
    let inputEvent: DataJourneyEvent?
    let outputEvent: DataJourneyEvent?
    let onSelectEvent: (DataJourneyEvent) -> Void

    @State private var isExpanded = false
    @Environment(\.dsTheme) var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    var body: some View {
        let keyEvents = selectKeyEvents()
        guard !keyEvents.isEmpty else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
                DSButton(
                    "Flow Overview",
                    config: .init(
                        style: .ghost,
                        size: .small,
                        icon: Image(systemName: isExpanded ? "chevron.down" : "chevron.right"),
                        iconPosition: .leading
                    ),
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                if isExpanded {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSLayout.spacing(0)) {
                            ForEach(
                                Array(keyEvents.enumerated()),
                                id: \.element.id
                            ) { index, event in
                                flowCard(for: event)
                                    .onTapGesture { onSelectEvent(event) }

                                if index < keyEvents.count - 1 {
                                    flowArrow()
                                }
                            }
                        }
                        .padding(.horizontal, DSLayout.spacing(4))
                        .padding(.vertical, DSLayout.spacing(8))
                    }
                }
            }
            .padding(DSLayout.spacing(8))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(palette.gray900.opacity(0.3))
            )
        )
    }

    // MARK: - Key Event Selection

    /// Selects 3-5 key events that best represent the data transformation.
    private func selectKeyEvents() -> [DataJourneyEvent] {
        let stepEvents = events.filter { $0.kind == .step }
        var keyEvents: [DataJourneyEvent] = []

        if let input = inputEvent {
            keyEvents.append(input)
        }

        if stepEvents.count <= 3 {
            keyEvents.append(contentsOf: stepEvents)
        } else {
            keyEvents.append(stepEvents[0])

            // Find step with most changes from its predecessor
            var maxChangeIndex = stepEvents.count / 2
            var maxChangeCount = 0
            for stepIndex in 1..<stepEvents.count {
                let prev = stepEvents[stepIndex - 1]
                let curr = stepEvents[stepIndex]
                let changedKeys = TraceValueDiff.changedKeys(
                    previous: prev,
                    current: curr
                )
                if changedKeys.count > maxChangeCount {
                    maxChangeCount = changedKeys.count
                    maxChangeIndex = stepIndex
                }
            }

            // Only add if it's not the first or last
            if maxChangeIndex > 0 && maxChangeIndex < stepEvents.count - 1 {
                keyEvents.append(stepEvents[maxChangeIndex])
            }

            keyEvents.append(stepEvents[stepEvents.count - 1])
        }

        if let output = outputEvent {
            keyEvents.append(output)
        }

        // Deduplicate by ID while preserving order
        var seen = Set<UUID>()
        return keyEvents.filter { seen.insert($0.id).inserted }
    }

    // MARK: - Card View

    private func flowCard(for event: DataJourneyEvent) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
            HStack(spacing: DSLayout.spacing(4)) {
                cardIcon(for: event)
                Text(cardTitle(for: event))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(cardTitleColor(for: event))
            }

            let sortedKeys = event.values.keys.sorted()
            let displayKeys = Array(sortedKeys.prefix(3))
            ForEach(displayKeys, id: \.self) { key in
                if let value = event.values[key] {
                    HStack(spacing: DSLayout.spacing(4)) {
                        Text(key)
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(palette.gray400)
                            .lineLimit(1)
                        Text(valueSummary(value))
                            .font(.system(
                                size: 7,
                                weight: .semibold,
                                design: .monospaced
                            ))
                            .foregroundColor(palette.gray200)
                            .lineLimit(1)
                    }
                }
            }
            if sortedKeys.count > 3 {
                Text("+\(sortedKeys.count - 3) more")
                    .font(.system(size: 7))
                    .foregroundColor(palette.gray500)
            }
        }
        .padding(DSLayout.spacing(8))
        .frame(minWidth: 90, maxWidth: 140, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(cardBackground(for: event))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(cardBorderColor(for: event), lineWidth: 1)
                )
        )
    }

    // MARK: - Arrow

    private func flowArrow() -> some View {
        HStack(spacing: DSLayout.spacing(0)) {
            Rectangle()
                .fill(palette.gray600)
                .frame(width: 16, height: 1.5)
            Image(systemName: "arrowtriangle.right.fill")
                .font(.system(size: 6))
                .foregroundColor(palette.gray600)
        }
        .padding(.horizontal, DSLayout.spacing(2))
    }

    // MARK: - Card Styling

    private func cardTitle(for event: DataJourneyEvent) -> String {
        switch event.kind {
        case .input:
            return "Input"
        case .output:
            return "Output"
        case .step:
            if let label = event.label, !label.isEmpty { return label }
            let index = events.filter { $0.kind == .step }
                .firstIndex(where: { $0.id == event.id }) ?? 0
            return "Step \(index + 1)"
        }
    }

    @ViewBuilder
    private func cardIcon(for event: DataJourneyEvent) -> some View {
        switch event.kind {
        case .input:
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 8))
                .foregroundColor(palette.green)
        case .output:
            Image(systemName: "arrow.left.circle.fill")
                .font(.system(size: 8))
                .foregroundColor(palette.cyan)
        case .step:
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(palette.purple)
        }
    }

    private func cardTitleColor(for event: DataJourneyEvent) -> Color {
        switch event.kind {
        case .input: return palette.green
        case .output: return palette.cyan
        case .step: return palette.gray300
        }
    }

    private func cardBackground(for event: DataJourneyEvent) -> Color {
        switch event.kind {
        case .input: return palette.green.opacity(0.08)
        case .output: return palette.cyan.opacity(0.08)
        case .step: return palette.gray800.opacity(0.6)
        }
    }

    private func cardBorderColor(for event: DataJourneyEvent) -> Color {
        switch event.kind {
        case .input: return palette.green.opacity(0.3)
        case .output: return palette.cyan.opacity(0.3)
        case .step: return palette.gray700.opacity(0.5)
        }
    }

    // MARK: - Value Summary

    // swiftlint:disable:next cyclomatic_complexity
    private func valueSummary(_ value: TraceValue) -> String {
        switch value {
        case .null:
            return "nil"
        case .bool(let boolValue):
            return boolValue ? "true" : "false"
        case .number(let num, let isInt):
            return isInt ? "\(Int(num))" : String(format: "%.1f", num)
        case .string(let str):
            return str.count <= 8 ? "\"\(str)\"" : "\"\(str.prefix(6))...\""
        case .array(let items):
            return "[\(items.count)]"
        case .list(let list):
            return "->\(list.nodes.count)"
        case .tree(let tree):
            return "tree(\(tree.nodes.count))"
        case .object(let map):
            return "{\(map.count)}"
        case .trie(let trieData):
            return "trie(\(trieData.nodes.count))"
        case .listPointer, .treePointer:
            return "ptr"
        case .typed(let type, let inner):
            let lowered = type.lowercased()
            if case .array(let items) = inner {
                return "\(lowered)(\(items.count))"
            }
            return valueSummary(inner)
        }
    }
}
