import SwiftUI

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let appStore = AppStateStore(storage: FileAppStorage())
        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: URLSessionRequestExecutor()
        )
        let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
        let presenter = SettingsPresenter(
            interactor: SettingsInteractor(
                notificationManager: NotificationManager(
                    scheduler: SystemNotificationScheduler(),
                    store: UserDefaultsNotificationSettingsStore()
                ),
                appStore: appStore,
                leetCodeSync: leetCodeSync
            )
        )
        return SettingsView(presenter: presenter)
    }
}
#endif
