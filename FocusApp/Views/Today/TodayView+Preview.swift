import SwiftUI

#if DEBUG
struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        let appStore = AppStateStore(storage: FileAppStorage())
        let presenter = TodayPresenter(
            interactor: TodayInteractor(
                appStore: appStore,
                notificationManager: NotificationManager(
                    scheduler: SystemNotificationScheduler(),
                    store: UserDefaultsNotificationSettingsStore()
                )
            )
        )
        return TodayView(
            presenter: presenter,
            showFocusMode: .constant(false),
            showCodeEnvironment: .constant(false)
        )
            .frame(width: 600, height: 800)
    }
}
#endif
