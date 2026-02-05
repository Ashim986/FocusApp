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
            let label = compact ? "\(map.count)" : "{\(map.count)}"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .list(let list):
            let label = compact ? "\(list.nodes.count)" : "[\(list.nodes.count)]"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .tree(let tree):
            let label = compact ? "\(tree.nodes.count)" : "tree"
            return TraceBubbleModel(text: label, fill: Color.appGray700)
        case .listPointer, .treePointer:
            return TraceBubbleModel(text: "ptr", fill: Color.appGray700)
        case .typed(_, let inner):
            return from(inner, compact: compact)
        }
    }

}
