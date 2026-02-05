import SwiftUI

struct TraceBubble: View {
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
        case .typed(_, let inner):
            return from(inner, compact: compact)
        }
    }
}
