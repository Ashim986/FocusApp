#if os(macOS)
import FocusDesignSystem
import SwiftUI

struct WidgetCard<Content: View>: View {
    let fill: Color?
    let content: Content
    @Environment(\.dsTheme) var theme

    init(fill: Color? = nil, @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.content = content()
    }

    var body: some View {
        let fillColor = fill ?? theme.colors.surfaceElevated.opacity(theme.kind == .dark ? 0.5 : 0.9)
        let borderColor = theme.colors.border.opacity(theme.kind == .dark ? 0.35 : 0.7)
        content
            .padding(DSLayout.spacing(12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(fillColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

#endif
