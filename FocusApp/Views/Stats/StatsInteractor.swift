import Combine
import Foundation

@MainActor
final class StatsInteractor {
    private let appStore: AppStateStore

    init(appStore: AppStateStore) {
        self.appStore = appStore
    }

    var dataPublisher: Published<AppData>.Publisher {
        appStore.$data
    }

    func dataSnapshot() -> AppData {
        appStore.data
    }
}
