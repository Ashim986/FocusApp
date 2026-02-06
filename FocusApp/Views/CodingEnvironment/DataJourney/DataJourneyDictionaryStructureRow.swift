import SwiftUI

struct DictionaryEntry: Identifiable {
    let id = UUID()
    let key: String
    let value: TraceValue
}

struct DictionaryStructureRow: View {
    let entries: [DictionaryEntry]
    let pointers: [PointerMarker]
    let bubbleStyle: TraceBubble.Style

    let bubbleSize: CGFloat
    let pointerFontSize: CGFloat
    let pointerHorizontalPadding: CGFloat
    let pointerVerticalPadding: CGFloat
    private let pointerSpacing: CGFloat = 2

    private var pointerHeight: CGFloat { pointerFontSize + pointerVerticalPadding * 2 + 4 }
    private var arrowSize: CGFloat { max(10, bubbleSize * 0.33) }

    init(
        entries: [DictionaryEntry],
        pointers: [PointerMarker],
        bubbleStyle: TraceBubble.Style = .solid,
        bubbleSize: CGFloat = 30,
        pointerFontSize: CGFloat = 8,
        pointerHorizontalPadding: CGFloat = 6,
        pointerVerticalPadding: CGFloat = 2
    ) {
        self.entries = entries
        self.pointers = pointers
        self.bubbleStyle = bubbleStyle
        self.bubbleSize = bubbleSize
        self.pointerFontSize = pointerFontSize
        self.pointerHorizontalPadding = pointerHorizontalPadding
        self.pointerVerticalPadding = pointerVerticalPadding
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    let model = dictionaryValueModel(for: entry.value)
                    let keyFill = Color.appGray700
                    let valueFill = model.fill
                    let pointerStack = pointersByIndex[index] ?? []
                    VStack(spacing: 4) {
                        ZStack(alignment: .top) {
                            HStack(spacing: 6) {
                                TraceBubble(
                                    text: entry.key,
                                    fill: keyFill,
                                    size: bubbleSize,
                                    style: bubbleStyle
                                )
                                Image(systemName: "arrow.right")
                                    .font(.system(size: arrowSize, weight: .semibold))
                                    .foregroundColor(Color.appPurple.opacity(0.8))
                                TraceBubble(
                                    text: model.text,
                                    fill: valueFill,
                                    size: bubbleSize,
                                    style: bubbleStyle
                                )
                            }
                            if !pointerStack.isEmpty {
                                let stackHeight = CGFloat(pointerStack.count) * pointerHeight +
                                    CGFloat(max(pointerStack.count - 1, 0)) * pointerSpacing
                                VStack(spacing: pointerSpacing) {
                                    ForEach(pointerStack) { pointer in
                                        PointerBadge(
                                            text: pointer.name,
                                            color: pointer.color,
                                            fontSize: pointerFontSize,
                                            horizontalPadding: pointerHorizontalPadding,
                                            verticalPadding: pointerVerticalPadding
                                        )
                                            .frame(height: pointerHeight)
                                    }
                                }
                                .offset(y: -(stackHeight + bubbleSize * 0.2))
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var pointersByIndex: [Int: [PointerMarker]] {
        var grouped: [Int: [PointerMarker]] = [:]
        for pointer in pointers {
            guard let index = pointer.index else { continue }
            grouped[index, default: []].append(pointer)
        }
        return grouped
    }

    private func dictionaryValueModel(for value: TraceValue) -> TraceBubbleModel {
        switch value {
        case .array(let items):
            if let last = items.last {
                return TraceBubbleModel.from(last)
            }
            return TraceBubbleModel(text: "empty", fill: Color.appGray700)
        case .list(let list):
            if let last = list.nodes.last?.value {
                return TraceBubbleModel.from(last)
            }
            return TraceBubbleModel(text: "empty", fill: Color.appGray700)
        case .typed(_, let inner):
            return dictionaryValueModel(for: inner)
        default:
            return TraceBubbleModel.from(value, compact: true)
        }
    }
}
