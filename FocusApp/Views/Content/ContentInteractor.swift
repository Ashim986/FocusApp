import Combine
import Foundation

@MainActor
final class ContentInteractor {
    private let appStore: AppStateStore

    init(appStore: AppStateStore) {
        self.appStore = appStore
    }

    var dataPublisher: Published<AppData>.Publisher {
        appStore.$data
    }
}
