import AppKit
@testable import FocusApp
import SwiftUI
import UserNotifications
import XCTest

final class SharedDataStoreTests: XCTestCase {
    func testFileAppStorageReturnsDefaultWhenMissing() {
        let url = URL(fileURLWithPath: "/tmp/focusapp-missing-\(UUID().uuidString).json")
        let storage = FileAppStorage(fileURL: url)
        let data = storage.load()

        XCTAssertEqual(data.dayOffset, 0)
        XCTAssertEqual(data.leetCodeUsername, "ashim986")
    }

    func testFileAppStorageSavesAndLoads() {
        let url = URL(fileURLWithPath: "/tmp/focusapp-save-\(UUID().uuidString).json")
        var data = AppData()
        data.dayOffset = 2
        data.leetCodeUsername = "tester"

        let storage = FileAppStorage(fileURL: url)
        storage.save(data)
        let loaded = storage.load()

        XCTAssertEqual(loaded.dayOffset, 2)
        XCTAssertEqual(loaded.leetCodeUsername, "tester")
    }

    func testFileAppStorageHandlesInvalidJSON() throws {
        let url = URL(fileURLWithPath: "/tmp/focusapp-bad-\(UUID().uuidString).json")
        try Data("not-json".utf8).write(to: url)

        let storage = FileAppStorage(fileURL: url)
        let loaded = storage.load()

        XCTAssertEqual(loaded.dayOffset, 0)
    }

    func testNotificationSettingsStoreDefaults() {
        let defaults = UserDefaults(suiteName: "FocusAppTests-\(UUID().uuidString)")!
        let store = UserDefaultsNotificationSettingsStore(userDefaults: defaults)
        let settings = store.loadSettings()

        XCTAssertFalse(settings.studyReminderEnabled)
        XCTAssertFalse(settings.habitReminderEnabled)
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.studyReminderTime), 9)
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.habitReminderTime), 20)
    }

    func testNotificationSettingsStoreSavesAndLoads() {
        let defaults = UserDefaults(suiteName: "FocusAppTests-\(UUID().uuidString)")!
        let store = UserDefaultsNotificationSettingsStore(userDefaults: defaults)
        let studyDate = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? Date()
        let habitDate = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
        let settings = NotificationSettings(
            studyReminderEnabled: true,
            studyReminderTime: studyDate,
            habitReminderEnabled: true,
            habitReminderTime: habitDate
        )

        store.saveSettings(settings)
        let loaded = store.loadSettings()

        XCTAssertTrue(loaded.studyReminderEnabled)
        XCTAssertTrue(loaded.habitReminderEnabled)
        XCTAssertEqual(Calendar.current.component(.hour, from: loaded.studyReminderTime), 7)
        XCTAssertEqual(Calendar.current.component(.hour, from: loaded.habitReminderTime), 19)
    }

    func testColorHexParsing() {
        let short = NSColor(Color(hex: "#fff")).usingColorSpace(.deviceRGB)!
        let full = NSColor(Color(hex: "#112233")).usingColorSpace(.deviceRGB)!
        let argb = NSColor(Color(hex: "#FF336699")).usingColorSpace(.deviceRGB)!
        let invalid = NSColor(Color(hex: "#zz")).usingColorSpace(.deviceRGB)!

        XCTAssertEqual(short.redComponent, 1.0, accuracy: 0.01)
        XCTAssertEqual(full.greenComponent, 0x22 / 255.0, accuracy: 0.01)
        XCTAssertEqual(argb.blueComponent, 0x99 / 255.0, accuracy: 0.01)
        XCTAssertEqual(invalid.alphaComponent, 1.0 / 255.0, accuracy: 0.01)
    }

    @MainActor
    func testAppContainerBootstrapsPresenters() {
        let container = AppContainer()
        XCTAssertNotNil(container.contentPresenter)
        XCTAssertNotNil(container.planPresenter)
        container.leetCodeScheduler.stop()
    }

    func testSystemNotificationSchedulerForwardsCalls() async throws {
        let center = StubNotificationCenter()
        let scheduler = SystemNotificationScheduler(center: center)

        let granted = try await scheduler.requestAuthorization(options: [.alert])
        XCTAssertTrue(granted)
        _ = await scheduler.notificationSettings()

        let content = UNMutableNotificationContent()
        content.title = "Test"
        let request = UNNotificationRequest(identifier: "id", content: content, trigger: nil)
        try await scheduler.add(request)
        scheduler.removePendingRequests(identifiers: ["id"])

        XCTAssertEqual(center.addedRequests.count, 1)
        XCTAssertEqual(center.removedIdentifiers.first, ["id"])
    }

    func testAppConstantsTotalHabits() {
        XCTAssertEqual(AppConstants.totalHabits, 3)
    }

    func testAppConstantsHabitsList() {
        XCTAssertEqual(AppConstants.habitsList.count, 3)
        XCTAssertTrue(AppConstants.habitsList.contains("dsa"))
        XCTAssertTrue(AppConstants.habitsList.contains("exercise"))
        XCTAssertTrue(AppConstants.habitsList.contains("other"))
    }

    func testPlanCalendarBaseDayNumberClampsTo1() {
        let calendar = PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 10))
        let pastDate = makeDate(year: 2026, month: 1, day: 1)

        XCTAssertEqual(calendar.baseDayNumber(today: pastDate), 1)
    }

    func testPlanCalendarBaseDayNumberClampsToPlanCount() {
        let calendar = PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 1))
        let futureDate = makeDate(year: 2026, month: 12, day: 31)

        XCTAssertEqual(calendar.baseDayNumber(today: futureDate), dsaPlan.count)
    }

    func testPlanCalendarCurrentDayNumberWithOffset() {
        let calendar = PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3))
        let today = makeDate(year: 2026, month: 2, day: 3)

        XCTAssertEqual(calendar.currentDayNumber(today: today, offset: 0), 1)
        XCTAssertEqual(calendar.currentDayNumber(today: today, offset: 5), 6)
        XCTAssertEqual(calendar.currentDayNumber(today: today, offset: 100), dsaPlan.count)
    }

    func testFileAppStorageDefaultFileURL() {
        let url = FileAppStorage.defaultFileURL

        XCTAssertTrue(url.path.contains(".dsa-focus-data.json"))
        XCTAssertTrue(url.isFileURL)
    }
}

private final class StubNotificationCenter: UserNotificationCentering {
    var requestedOptions: [UNAuthorizationOptions] = []
    var authorizationResult: Bool = true
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [[String]] = []

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestedOptions.append(options)
        return authorizationResult
    }

    func notificationSettings() async -> UNNotificationSettings {
        await UNUserNotificationCenter.current().notificationSettings()
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(identifiers)
    }
}
