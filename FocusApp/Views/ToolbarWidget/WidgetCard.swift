import SwiftUI

struct WidgetCard<Content: View>: View {
    let fill: Color
    let content: Content

    init(fill: Color = Color.white.opacity(0.05), @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}
