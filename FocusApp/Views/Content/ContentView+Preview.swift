import SwiftUI

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let coordinator = AppCoordinator()
            ContentView(
                presenter: coordinator.container.contentPresenter,
                coordinator: coordinator.contentCoordinator
            )
            .frame(width: 800, height: 600)
        }
    }
}
#endif
