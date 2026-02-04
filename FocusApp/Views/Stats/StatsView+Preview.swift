import SwiftUI

#if DEBUG
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let presenter = StatsPresenter(interactor: StatsInteractor(appStore: AppStateStore(storage: FileAppStorage())))
        return StatsView(presenter: presenter)
            .frame(width: 600, height: 800)
    }
}
#endif
