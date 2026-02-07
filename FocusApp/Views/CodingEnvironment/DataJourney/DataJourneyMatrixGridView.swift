import FocusDesignSystem
import SwiftUI

struct MatrixPointerCell: Equatable {
    let row: Int
    let col: Int
}

struct MatrixGridView: View {
    let grid: [[TraceValue]]
    let pointers: MatrixPointerCell?
    let highlightedCells: Set<MatrixCell>
    let bubbleSize: CGFloat
    @Environment(\.dsTheme) var theme

    private var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    private let headerSize: CGFloat = 20
    private let cellSpacing: CGFloat = 2

    init(
        grid: [[TraceValue]],
        pointers: MatrixPointerCell? = nil,
        highlightedCells: Set<MatrixCell> = [],
        bubbleSize: CGFloat = 30
    ) {
        self.grid = grid
        self.pointers = pointers
        self.highlightedCells = highlightedCells
        self.bubbleSize = max(bubbleSize, 30)
    }

    var body: some View {
        let rows = grid.count
        let cols = grid.first?.count ?? 0

        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack(alignment: .leading, spacing: cellSpacing) {
                columnHeaders(cols: cols)

                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        rowHeader(row)

                        ForEach(0..<cols, id: \.self) { col in
                            let value = grid[row][col]
                            let isPointed = pointers?.row == row && pointers?.col == col
                            let isChanged = highlightedCells.contains(MatrixCell(row: row, col: col))
                            cellView(value: value, highlighted: isPointed, changed: isChanged)
                        }
                    }
                }
            }
            .padding(4)
        }
        .frame(
            maxHeight: CGFloat(min(rows, 12)) * (bubbleSize + cellSpacing) + headerSize + 16
        )
    }

    private func columnHeaders(cols: Int) -> some View {
        HStack(spacing: cellSpacing) {
            Color.clear
                .frame(width: headerSize, height: headerSize)

            ForEach(0..<cols, id: \.self) { col in
                DSText("\(col)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(palette.gray400)
                    .frame(width: bubbleSize, height: headerSize)
            }
        }
    }

    private func rowHeader(_ row: Int) -> some View {
        DSText("\(row)")
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundColor(palette.gray400)
            .frame(width: headerSize, height: bubbleSize)
    }

    private func cellView(
        value: TraceValue,
        highlighted: Bool,
        changed: Bool = false
    ) -> some View {
        let model = TraceBubbleModel.from(value, palette: palette, compact: true)
        let borderColor: Color = highlighted
            ? palette.cyan
            : changed ? palette.cyan.opacity(0.6) : Color.clear
        let borderWidth: CGFloat = highlighted ? 2 : changed ? 1.5 : 0
        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(cellFill(for: model, highlighted: highlighted))
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(borderColor, lineWidth: borderWidth)
            DSText(model.text)
                .font(.system(
                    size: max(8, bubbleSize * 0.3),
                    weight: .semibold,
                    design: .monospaced
                ))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 2)
        }
        .frame(width: bubbleSize, height: bubbleSize)
        .shadow(
            color: changed ? palette.cyan.opacity(0.4) : Color.clear,
            radius: changed ? 3 : 0
        )
    }

    private func cellFill(for model: TraceBubbleModel, highlighted: Bool) -> Color {
        if highlighted {
            return palette.cyan.opacity(0.35)
        }
        return model.fill.opacity(0.6)
    }
}
