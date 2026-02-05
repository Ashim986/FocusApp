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

    var body: some View {
        Text(text)
            .font(.system(size: 8, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}
