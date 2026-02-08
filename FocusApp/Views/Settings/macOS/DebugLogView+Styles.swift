#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension DebugLogView {
    var headerBackground: some View {
        LinearGradient(
            colors: [
                theme.colors.surface,
                theme.colors.surfaceElevated.opacity(0.9),
                theme.colors.success.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var debugBackground: some View {
        LinearGradient(
            colors: [
                theme.colors.surface,
                theme.colors.surfaceElevated,
                theme.colors.surface
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#endif
