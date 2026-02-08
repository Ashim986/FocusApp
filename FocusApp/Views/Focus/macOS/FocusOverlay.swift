#if os(macOS)
import FocusDesignSystem
import SwiftUI

struct FocusOverlay: View {
    @ObservedObject var presenter: FocusPresenter
    @Binding var isPresented: Bool
    @Environment(\.dsTheme) var theme

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            if !presenter.hasStarted {
                durationSelector
            } else if presenter.isCompleted {
                completionView
            } else {
                timerView
            }
        }
        .onReceive(timer) { _ in
            presenter.handleTick()
        }
    }
}

// Preview requires a mock CodingEnvironmentPresenter which needs AppContainer setup

#endif
