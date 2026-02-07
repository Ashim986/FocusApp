import SwiftData
import SwiftUI

#if DEBUG
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if let container = try? ModelContainer(for: AppDataRecord.self) {
                let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
                let presenter = StatsPresenter(interactor: StatsInteractor(appStore: appStore))
                StatsView(presenter: presenter)
                    .frame(width: 600, height: 800)
            } else {
                DSText("Preview unavailable")
            }
        }
    }
}
#endif
