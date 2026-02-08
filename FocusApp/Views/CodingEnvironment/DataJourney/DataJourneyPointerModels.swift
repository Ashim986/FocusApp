import FocusDesignSystem
import SwiftUI

struct PointerMarker: Identifiable, Hashable {
    let id: String
    let name: String
    let index: Int?
    let nodeId: String?
    let color: Color

    init(name: String, index: Int? = nil, nodeId: String? = nil, palette: DataJourneyPalette) {
        self.id = "\(name)-\(index ?? -1)-\(nodeId ?? "none")"
        self.name = name
        self.index = index
        self.nodeId = nodeId
        self.color = PointerPalette.color(for: name, palette: palette)
    }
}

struct PointerMotion: Identifiable {
    let id: String
    let name: String
    let fromIndex: Int
    let toIndex: Int
    let color: Color

    init(name: String, fromIndex: Int, toIndex: Int, palette: DataJourneyPalette) {
        self.id = "\(name)-\(fromIndex)-\(toIndex)"
        self.name = name
        self.fromIndex = fromIndex
        self.toIndex = toIndex
        self.color = PointerPalette.color(for: name, palette: palette)
    }
}

struct TreePointerMotion: Identifiable {
    let id: String
    let name: String
    let fromId: String
    let toId: String
    let color: Color

    init(name: String, fromId: String, toId: String, palette: DataJourneyPalette) {
        self.id = "\(name)-\(fromId)-\(toId)"
        self.name = name
        self.fromId = fromId
        self.toId = toId
        self.color = PointerPalette.color(for: name, palette: palette)
    }
}

struct SequenceLink: Identifiable {
    let id: String
    let fromIndex: Int
    let toIndex: Int
    let color: Color

    init(fromIndex: Int, toIndex: Int, color: Color) {
        self.id = "\(fromIndex)-\(toIndex)-\(color)"
        self.fromIndex = fromIndex
        self.toIndex = toIndex
        self.color = color
    }
}

enum PointerPalette {
    static func color(for name: String, palette: DataJourneyPalette) -> Color {
        let palette: [Color] = [
            palette.cyan,
            palette.purple,
            palette.green,
            palette.amber,
            palette.red
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
