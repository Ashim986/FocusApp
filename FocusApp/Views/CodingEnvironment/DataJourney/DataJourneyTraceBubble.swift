import FocusDesignSystem
import SwiftUI

struct TraceBubble: View {
    enum Style {
        case solid
    }

    let text: String
    let fill: Color
    let size: CGFloat
    let style: Style
    let highlighted: Bool
    let changeType: ChangeType?
    @Environment(\.dsTheme) var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    init(
        text: String,
        fill: Color,
        size: CGFloat = 30,
        style: Style = .solid,
        highlighted: Bool = false,
        changeType: ChangeType? = nil
    ) {
        self.text = text
        self.fill = fill
        self.size = size
        self.style = style
        self.highlighted = highlighted
        self.changeType = changeType
    }

    var body: some View {
        ZStack {
            bubbleBackground
            Text(text)
                .font(.system(size: max(8, size * 0.33), weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, DSLayout.spacing(4))
        }
        .frame(width: size, height: size)
        .overlay(highlightOverlay)
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        switch style {
        case .solid:
            Circle()
                .fill(fill)
        }
    }

    @ViewBuilder
    private var highlightOverlay: some View {
        if highlighted {
            Circle()
                .stroke(palette.cyan, lineWidth: 2)
                .shadow(color: palette.cyan.opacity(0.6), radius: 4)
        }
        if let changeType {
            changeTypeOverlay(changeType)
        }
    }

    @ViewBuilder
    private func changeTypeOverlay(_ type: ChangeType) -> some View {
        switch type {
        case .added:
            Circle()
                .stroke(palette.green, lineWidth: 1.5)
                .shadow(color: palette.green.opacity(0.5), radius: 3)
        case .removed:
            Circle()
                .fill(palette.red.opacity(0.25))
        case .modified:
            Circle()
                .stroke(palette.amber, lineWidth: 1.5)
                .shadow(color: palette.amber.opacity(0.5), radius: 3)
        case .unchanged:
            EmptyView()
        }
    }
}

struct TraceBubbleModel {
    let text: String
    let fill: Color

    // swiftlint:disable:next cyclomatic_complexity
    static func from(_ value: TraceValue, palette: DataJourneyPalette, compact: Bool = false) -> TraceBubbleModel {
        switch value {
        case .null:
            return TraceBubbleModel(text: "nil", fill: palette.gray700)
        case .bool(let boolValue):
            return TraceBubbleModel(
                text: boolValue ? "true" : "false",
                fill: palette.purple.opacity(0.3)
            )
        case .number(let number, let isInt):
            let text = isInt ? "\(Int(number))" : String(format: "%.2f", number)
            return TraceBubbleModel(text: text, fill: palette.amber.opacity(0.3))
        case .string(let stringValue):
            return TraceBubbleModel(text: stringValue, fill: palette.green.opacity(0.25))
        case .array(let items):
            let label = compact ? "\(items.count)" : "[\(items.count)]"
            return TraceBubbleModel(text: label, fill: palette.gray700)
        case .object(let map):
            let label = dictionaryPreview(map: map, seed: nil, palette: palette)
            return TraceBubbleModel(text: label, fill: palette.gray700)
        case .list(let list):
            let label = compact ? "\(list.nodes.count)" : "[\(list.nodes.count)]"
            return TraceBubbleModel(text: label, fill: palette.gray700)
        case .tree(let tree):
            let label = compact ? "\(tree.nodes.count)" : "tree"
            return TraceBubbleModel(text: label, fill: palette.gray700)
        case .listPointer, .treePointer:
            return TraceBubbleModel(text: "ptr", fill: palette.gray700)
        case .trie(let trieData):
            let label = compact ? "\(trieData.nodes.count)" : "trie"
            return TraceBubbleModel(text: label, fill: palette.gray700)
        case .typed(let type, let inner):
            return typedBubbleModel(type: type, inner: inner, palette: palette, compact: compact)
        }
    }

    private static func typedBubbleModel(
        type: String,
        inner: TraceValue,
        palette: DataJourneyPalette,
        compact: Bool
    ) -> TraceBubbleModel {
        let lowered = type.lowercased()
        if case .array(let items) = inner {
            switch lowered {
            case "set":
                return TraceBubbleModel(text: "{\(items.count)}", fill: palette.cyan.opacity(0.25))
            case "stack":
                return TraceBubbleModel(text: "S\(items.count)", fill: palette.purple.opacity(0.25))
            case "queue":
                return TraceBubbleModel(text: "Q\(items.count)", fill: palette.green.opacity(0.25))
            default:
                break
            }
        }
        return from(inner, palette: palette, compact: compact)
    }

    static func dictionaryPreview(
        map: [String: TraceValue],
        seed: String?,
        palette: DataJourneyPalette
    ) -> String {
        guard !map.isEmpty else { return "[:]" }
        let keys = map.keys.sorted()
        let index = stableIndex(seed: seed ?? keys.joined(separator: "|"), count: keys.count)
        let key = keys[index]
        let keyInitial = initialCharacter(from: key)
        let value = map[key] ?? .null
        let valueInitial = initialCharacter(for: value, palette: palette)
        return "[\(keyInitial):\(valueInitial)]"
    }

    static func arrayInitialPreview(items: [TraceValue], palette: DataJourneyPalette) -> String {
        guard let first = items.first else { return "[]" }
        let initial = initialCharacter(for: first, palette: palette)
        return "[\(initial)]"
    }

    static func initialCharacter(for value: TraceValue, palette: DataJourneyPalette) -> String {
        switch value {
        case .string(let stringValue):
            return initialCharacter(from: stringValue)
        case .array(let items):
            guard let first = items.first else { return "?" }
            return initialCharacter(for: first, palette: palette)
        case .list(let list):
            guard let first = list.nodes.first?.value else { return "?" }
            return initialCharacter(for: first, palette: palette)
        case .object(let map):
            return initialCharacter(from: dictionaryPreview(map: map, seed: nil, palette: palette))
        case .typed(_, let inner):
            return initialCharacter(for: inner, palette: palette)
        default:
            let text = from(value, palette: palette, compact: true).text
            return initialCharacter(from: text)
        }
    }

    static func initialCharacter(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        for char in trimmed {
            if char.isLetter || char.isNumber {
                return String(char)
            }
        }
        return "?"
    }

    static func stableIndex(seed: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let sum = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return abs(sum) % count
    }

}
