import FocusDesignSystem
import SwiftUI

/// Wraps content with the design system theme provider.
/// Used by both macOS and iOS app entry points.
struct DesignSystemRoot<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        DSThemeProvider(theme: colorScheme == .dark ? .dark : .light) {
            content
        }
    }
}
