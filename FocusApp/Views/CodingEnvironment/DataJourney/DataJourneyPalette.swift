import FocusDesignSystem
import SwiftUI

struct DataJourneyPalette {
    let theme: DSTheme

    var cyan: Color { theme.colors.accent }
    var purple: Color { theme.colors.primary }
    var green: Color { theme.colors.success }
    var amber: Color { theme.colors.warning }
    var red: Color { theme.colors.danger }

    var gray50: Color { theme.colors.background }
    var gray100: Color { theme.colors.surface }
    var gray200: Color { theme.colors.border }
    var gray300: Color { theme.colors.border.opacity(theme.kind == .dark ? 0.85 : 0.7) }
    var gray400: Color { theme.colors.textSecondary.opacity(theme.kind == .dark ? 0.85 : 0.9) }
    var gray500: Color { theme.colors.textSecondary }
    var gray600: Color { theme.colors.textSecondary.opacity(theme.kind == .dark ? 0.95 : 0.85) }
    var gray700: Color { theme.colors.surfaceElevated }
    var gray800: Color { theme.colors.surfaceElevated.opacity(theme.kind == .dark ? 0.85 : 0.95) }
    var gray900: Color { theme.colors.background.opacity(theme.kind == .dark ? 0.9 : 0.8) }
}
