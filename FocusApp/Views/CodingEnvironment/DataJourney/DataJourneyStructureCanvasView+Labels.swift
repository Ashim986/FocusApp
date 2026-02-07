import SwiftUI

extension DataJourneyStructureCanvasView {
    @ViewBuilder
    func listLabel(_ title: String, color: Color, background: Color) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, DSLayout.spacing(8))
            .padding(.vertical, DSLayout.spacing(4))
            .background(
                Capsule()
                    .fill(background)
            )
    }
}
