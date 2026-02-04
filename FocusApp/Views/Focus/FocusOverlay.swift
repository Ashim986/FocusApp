import SwiftUI

struct FocusOverlay: View {
    @ObservedObject var presenter: FocusPresenter
    @Binding var isPresented: Bool

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.appIndigo
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
