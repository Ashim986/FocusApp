import SwiftUI

struct TraceBubble: View {
    enum Style {
        case solid
    }

    let text: String
    let fill: Color
    let size: CGFloat
    let style: Style

    init(text: String, fill: Color, size: CGFloat = 30, style: Style = .solid) {
        self.text = text
        self.fill = fill
        self.size = size
        self.style = style
    }

    var body: some View {
        ZStack {
            bubbleBackground
            Text(text)
                .font(.system(size: max(8, size * 0.33), weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 4)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        switch style {
        case .solid:
            Circle()
                .fill(fill)
        }
    }
}

struct TraceBubbleModel {
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
            let label = dictionaryPreview(map: map, seed: nil)
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .list(let list):
            let label = compact ? "\(list.nodes.count)" : "[\(list.nodes.count)]"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .tree(let tree):
            let label = compact ? "\(tree.nodes.count)" : "tree"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .listPointer, .treePointer:
            return TraceBubbleModel(text: "ptr", fill: Color.appGray700)
        case .typed(let type, let inner):
            return typedBubbleModel(type: type, inner: inner, compact: compact)
        }
    }

    private static func typedBubbleModel(
        type: String,
        inner: TraceValue,
        compact: Bool
    ) -> TraceBubbleModel {
        let lowered = type.lowercased()
        if case .array(let items) = inner {
            switch lowered {
            case "set":
                return TraceBubbleModel(text: "{\(items.count)}", fill: Color.appCyan.opacity(0.25))
            case "stack":
                return TraceBubbleModel(text: "S\(items.count)", fill: Color.appPurple.opacity(0.25))
            case "queue":
                return TraceBubbleModel(text: "Q\(items.count)", fill: Color.appGreen.opacity(0.25))
            default:
                break
            }
        }
        return from(inner, compact: compact)
    }

    static func dictionaryPreview(map: [String: TraceValue], seed: String?) -> String {
        guard !map.isEmpty else { return "[:]" }
        let keys = map.keys.sorted()
        let index = stableIndex(seed: seed ?? keys.joined(separator: "|"), count: keys.count)
        let key = keys[index]
        let keyInitial = initialCharacter(from: key)
        let value = map[key] ?? .null
        let valueInitial = initialCharacter(for: value)
        return "[\(keyInitial):\(valueInitial)]"
    }

    static func arrayInitialPreview(items: [TraceValue]) -> String {
        guard let first = items.first else { return "[]" }
        let initial = initialCharacter(for: first)
        return "[\(initial)]"
    }

    static func initialCharacter(for value: TraceValue) -> String {
        switch value {
        case .string(let stringValue):
            return initialCharacter(from: stringValue)
        case .array(let items):
            guard let first = items.first else { return "?" }
            return initialCharacter(for: first)
        case .list(let list):
            guard let first = list.nodes.first?.value else { return "?" }
            return initialCharacter(for: first)
        case .object(let map):
            return initialCharacter(from: dictionaryPreview(map: map, seed: nil))
        case .typed(_, let inner):
            return initialCharacter(for: inner)
        default:
            let text = from(value, compact: true).text
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
