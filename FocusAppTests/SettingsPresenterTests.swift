@testable import FocusApp
import XCTest

final class SettingsPresenterTests: XCTestCase {
    @MainActor
    func testInitLoadsSettingsFromInteractor() {
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
        let presenter = SettingsPresenter(interactor: interactor)

        XCTAssertTrue(presenter.settings.studyReminderEnabled)
        XCTAssertFalse(presenter.settings.habitReminderEnabled)
    }

    @MainActor
    func testOnAppearChecksAuthorizationStatus() async {
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
        let presenter = SettingsPresenter(interactor: interactor)

        presenter.onAppear()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(notificationManager.checkAuthorizationCalled)
        XCTAssertTrue(presenter.notificationsAuthorized)
    }

    @MainActor
    func testOnAppearUpdatesReminders() async {
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
        let presenter = SettingsPresenter(interactor: interactor)

        presenter.onAppear()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(notificationManager.updateAllRemindersCalled)
    }

    @MainActor
    func testRequestAuthorizationUpdatesState() async {
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
        let presenter = SettingsPresenter(interactor: interactor)

        XCTAssertFalse(presenter.notificationsAuthorized)

        presenter.requestAuthorization()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(notificationManager.requestAuthorizationCalled)
        XCTAssertTrue(presenter.notificationsAuthorized)
    }

    @MainActor
    func testUpdateSettingsSavesAndUpdatesReminders() async {
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
        let presenter = SettingsPresenter(interactor: interactor)

        presenter.updateSettings { settings in
            settings.studyReminderEnabled = true
        }

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(presenter.settings.studyReminderEnabled)
        XCTAssertTrue(notificationManager.storedSettings.studyReminderEnabled)
    }

    @MainActor
    func testValidateAndSaveUsernameUpdatesState() async {
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
        let presenter = SettingsPresenter(interactor: interactor)

        presenter.leetCodeUsername = "testuser"
        presenter.validateAndSaveUsername()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.usernameValidationState, .valid)
        XCTAssertEqual(store.data.leetCodeUsername, "testuser")
    }

    @MainActor
    func testValidateAndSaveUsernameShowsInvalidOnFailure() async {
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
        let presenter = SettingsPresenter(interactor: interactor)

        presenter.leetCodeUsername = "invaliduser"
        presenter.validateAndSaveUsername()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.usernameValidationState, .invalid)
    }

    @MainActor
    func testResetValidationStateClearsState() {
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
        let presenter = SettingsPresenter(interactor: interactor)

        presenter.resetValidationState()

        XCTAssertEqual(presenter.usernameValidationState, .none)
    }
}
