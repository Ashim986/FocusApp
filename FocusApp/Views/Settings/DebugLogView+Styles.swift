import SwiftUI

extension DebugLogView {
    var headerBackground: some View {
        LinearGradient(
            colors: [
                Color.appGray900,
                Color.appGray800.opacity(0.9),
                Color.appGreen.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var debugBackground: some View {
        LinearGradient(
            colors: [
                Color.appGray900,
                Color.appGray800,
                Color.appGray900
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
