import SwiftUI

extension DataJourneyStructureCanvasView {
    @ViewBuilder
    func listLabel(_ title: String, color: Color, background: Color) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(background)
            )
    }
}
