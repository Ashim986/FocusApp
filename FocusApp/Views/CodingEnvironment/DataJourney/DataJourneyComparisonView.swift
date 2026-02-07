import FocusDesignSystem
import SwiftUI

/// Split-pane before/after comparison view showing previous and current step side by side.
/// Highlights changed values between the two steps for easy visual comparison.
struct DataJourneyComparisonView: View {
    let previousEvent: DataJourneyEvent?
    let currentEvent: DataJourneyEvent?

    @State private var isExpanded = false
    @Environment(\.dsTheme) var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    var body: some View {
        guard previousEvent != nil, currentEvent != nil else {
            return AnyView(EmptyView())
        }
        return AnyView(
            VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
                DSButton(
                    "Compare Steps",
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
                    comparisonContent
                }
            }
            .padding(DSLayout.spacing(8))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(palette.gray900.opacity(0.3))
            )
        )
    }

    // MARK: - Comparison Content

    private var comparisonContent: some View {
        let changedKeys = TraceValueDiff.changedKeys(
            previous: previousEvent,
            current: currentEvent
        )
        let allKeys = collectAllKeys()

        return HStack(alignment: .top, spacing: DSLayout.spacing(8)) {
            // Previous step (left pane)
            comparisonPane(
                title: paneTitle(for: previousEvent, label: "Previous"),
                event: previousEvent,
                allKeys: allKeys,
                changedKeys: changedKeys,
                accent: palette.red
            )

            // Divider
            Rectangle()
                .fill(palette.gray700.opacity(0.5))
                .frame(width: 1)

            // Current step (right pane)
            comparisonPane(
                title: paneTitle(for: currentEvent, label: "Current"),
                event: currentEvent,
                allKeys: allKeys,
                changedKeys: changedKeys,
                accent: palette.green
            )
        }
    }

    // MARK: - Pane

    private func comparisonPane(
        title: String,
        event: DataJourneyEvent?,
        allKeys: [String],
        changedKeys: Set<String>,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(accent)
                .padding(.horizontal, DSLayout.spacing(6))
                .padding(.vertical, DSLayout.spacing(2))
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accent.opacity(0.12))
                )

            ForEach(allKeys, id: \.self) { key in
                let value = event?.values[key]
                let isChanged = changedKeys.contains(key)
                HStack(spacing: DSLayout.spacing(6)) {
                    Text(key)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(isChanged ? accent : palette.gray400)
                        .frame(width: 50, alignment: .leading)
                        .lineLimit(1)

                    if let value {
                        Text(compactSummary(value))
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(isChanged ? palette.gray100 : palette.gray300)
                            .lineLimit(1)
                    } else {
                        Text("—")
                            .font(.system(size: 8))
                            .foregroundColor(palette.gray600)
                    }
                }
                .padding(.vertical, DSLayout.spacing(1))
                .padding(.horizontal, DSLayout.spacing(4))
                .background(
                    isChanged
                        ? RoundedRectangle(cornerRadius: 3)
                            .fill(accent.opacity(0.06))
                        : nil
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func collectAllKeys() -> [String] {
        var keys: [String] = []
        var seen = Set<String>()
        for event in [previousEvent, currentEvent].compactMap({ $0 }) {
            for key in event.values.keys.sorted() where seen.insert(key).inserted {
                keys.append(key)
            }
        }
        return keys
    }

    private func paneTitle(for event: DataJourneyEvent?, label: String) -> String {
        guard let event else { return label }
        if let eventLabel = event.label, !eventLabel.isEmpty {
            return eventLabel
        }
        return label
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func compactSummary(_ value: TraceValue) -> String {
        switch value {
        case .null:
            return "nil"
        case .bool(let boolValue):
            return boolValue ? "true" : "false"
        case .number(let number, let isInt):
            return isInt ? "\(Int(number))" : String(format: "%.2f", number)
        case .string(let stringValue):
            return stringValue.count <= 10 ? "\"\(stringValue)\"" : "\"\(stringValue.prefix(8))…\""
        case .array(let items):
            if items.count <= 4 {
                let previews = items.prefix(4).map { compactSummary($0) }
                return "[\(previews.joined(separator: ", "))]"
            }
            return "[\(items.count) items]"
        case .list(let list):
            return "→\(list.nodes.count) nodes"
        case .tree(let tree):
            return "tree(\(tree.nodes.count))"
        case .object(let map):
            return "{\(map.count) keys}"
        case .trie(let trieData):
            return "trie(\(trieData.nodes.count))"
        case .listPointer, .treePointer:
            return "ptr"
        case .typed(let type, let inner):
            let lowered = type.lowercased()
            if case .array(let items) = inner {
                return "\(lowered)(\(items.count))"
            }
            return compactSummary(inner)
        }
    }
}
