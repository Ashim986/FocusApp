import SwiftUI

struct PointerMarker: Identifiable, Hashable {
    let id: String
    let name: String
    let index: Int?
    let nodeId: String?
    let color: Color

    init(name: String, index: Int? = nil, nodeId: String? = nil) {
        self.id = "\(name)-\(index ?? -1)-\(nodeId ?? "none")"
        self.name = name
        self.index = index
        self.nodeId = nodeId
        self.color = PointerPalette.color(for: name)
    }
}

enum PointerPalette {
    static func color(for name: String) -> Color {
        let palette: [Color] = [
            Color.appCyan,
            Color.appPurple,
            Color.appGreen,
            Color.appAmber,
            Color.appRed
        ]
        let index = abs(name.lowercased().hashValue) % palette.count
        return palette[index].opacity(0.9)
    }
}

struct PointerBadge: View {
    let text: String
    let color: Color
    let fontSize: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat

    init(
        text: String,
        color: Color,
        fontSize: CGFloat = 8,
        horizontalPadding: CGFloat = 6,
        verticalPadding: CGFloat = 2
    ) {
        self.text = text
        self.color = color
        self.fontSize = fontSize
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}
