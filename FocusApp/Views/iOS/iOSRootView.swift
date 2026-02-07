#if os(iOS)
import FocusDesignSystem
import SwiftUI

/// Adaptive root view that switches between iPhone and iPad layouts
/// based on the device's horizontal size class.
struct iOSRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadRootView(coordinator: coordinator)
            } else {
                iPhoneRootView(coordinator: coordinator)
            }
        }
    }
}
#endif
