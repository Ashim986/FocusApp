@testable import FocusApp
import XCTest

// MARK: - Settings Notifications Tests
final class SettingsNotificationsTests: XCTestCase {
    @MainActor
    func testLoadSettingsReturnsFromNotificationManager() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        notificationManager.storedSettings = NotificationSettings(
            studyReminderEnabled: true,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = SettingsInteractor(
            notificationManager: notificationManager,
            appStore: store,
            leetCodeSync: syncInteractor
        )

        let settings = interactor.loadSettings()

        XCTAssertTrue(settings.studyReminderEnabled)
        XCTAssertFalse(settings.habitReminderEnabled)
    }

    @MainActor
    func testSaveSettingsPassesToNotificationManager() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = SettingsInteractor(
            notificationManager: notificationManager,
            appStore: store,
            leetCodeSync: syncInteractor
        )

        let newSettings = NotificationSettings(
            studyReminderEnabled: true,
            studyReminderTime: Date(),
            habitReminderEnabled: true,
            habitReminderTime: Date()
        )

        interactor.saveSettings(newSettings)

        XCTAssertTrue(notificationManager.storedSettings.studyReminderEnabled)
        XCTAssertTrue(notificationManager.storedSettings.habitReminderEnabled)
    }

    @MainActor
    func testRequestAuthorizationDelegatesToManager() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        notificationManager.authorizationStatus = true
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = SettingsInteractor(
            notificationManager: notificationManager,
            appStore: store,
            leetCodeSync: syncInteractor
        )

        let authorized = await interactor.requestAuthorization()

        XCTAssertTrue(notificationManager.requestAuthorizationCalled)
        XCTAssertTrue(authorized)
    }
}

// MARK: - Settings LeetCode Username Tests
final class SettingsLeetCodeUsernameTests: XCTestCase {
    @MainActor
    func testValidateAndSaveUsernameValidatesFirst() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let client = FakeLeetCodeClient()
        client.validateResult = .success(true)
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = SettingsInteractor(
            notificationManager: notificationManager,
            appStore: store,
            leetCodeSync: syncInteractor
        )

        let result = await interactor.validateAndSaveUsername("testuser")

        XCTAssertTrue(result)
    }

    @MainActor
    func testValidateAndSaveUsernameUpdatesStoreOnValid() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let client = FakeLeetCodeClient()
        client.validateResult = .success(true)
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = SettingsInteractor(
            notificationManager: notificationManager,
            appStore: store,
            leetCodeSync: syncInteractor
        )

        _ = await interactor.validateAndSaveUsername("testuser")

        XCTAssertEqual(store.data.leetCodeUsername, "testuser")
    }

    @MainActor
    func testValidateAndSaveUsernameReturnsFalseOnInvalid() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let client = FakeLeetCodeClient()
        client.validateResult = .success(false)
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = SettingsInteractor(
            notificationManager: notificationManager,
            appStore: store,
            leetCodeSync: syncInteractor
        )

        let result = await interactor.validateAndSaveUsername("invaliduser")

        XCTAssertFalse(result)
    }
}
