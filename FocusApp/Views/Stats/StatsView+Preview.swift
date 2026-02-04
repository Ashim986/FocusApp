import SwiftData
import SwiftUI

#if DEBUG
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        guard let container = try? ModelContainer(
            for: AppDataRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) else {
            return Text("Preview unavailable")
        }
        let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
        let presenter = StatsPresenter(interactor: StatsInteractor(appStore: appStore))
        return StatsView(presenter: presenter)
            .frame(width: 600, height: 800)
    }
}
#endif
