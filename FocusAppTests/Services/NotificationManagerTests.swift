@testable import FocusApp
import XCTest

final class NotificationManagerTests: XCTestCase {
    func testUpdateAllRemindersSchedulesWhenEnabled() async {
        let scheduler = SpyNotificationScheduler()
        let settings = NotificationSettings(
            studyReminderEnabled: true,
            studyReminderTime: Date(),
            habitReminderEnabled: true,
            habitReminderTime: Date()
        )
        let store = InMemoryNotificationSettingsStore(settings: settings)
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.updateAllReminders(settings: settings, authorized: true)

        let identifiers = scheduler.addedRequests.map { $0.identifier }
        XCTAssertTrue(identifiers.contains("com.dsafocus.studyReminder"))
        XCTAssertTrue(identifiers.contains("com.dsafocus.habitReminder"))
    }

    func testUpdateAllRemindersSkipsWhenUnauthorized() async {
        let scheduler = SpyNotificationScheduler()
        let settings = NotificationSettings(
            studyReminderEnabled: true,
            studyReminderTime: Date(),
            habitReminderEnabled: true,
            habitReminderTime: Date()
        )
        let store = InMemoryNotificationSettingsStore(settings: settings)
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.updateAllReminders(settings: settings, authorized: false)

        XCTAssertTrue(scheduler.addedRequests.isEmpty)
        XCTAssertTrue(scheduler.removedIdentifiers.isEmpty)
    }

    func testUpdateAllRemindersCancelsWhenDisabled() async {
        let scheduler = SpyNotificationScheduler()
        let settings = NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        )
        let store = InMemoryNotificationSettingsStore(settings: settings)
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.updateAllReminders(settings: settings, authorized: true)

        let identifiers = scheduler.removedIdentifiers.flatMap { $0 }
        XCTAssertTrue(identifiers.contains("com.dsafocus.studyReminder"))
        XCTAssertTrue(identifiers.contains("com.dsafocus.habitReminder"))
    }

    func testCancelRemindersRemovesPendingRequests() {
        let scheduler = SpyNotificationScheduler()
        let settings = NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        )
        let store = InMemoryNotificationSettingsStore(settings: settings)
        let manager = NotificationManager(scheduler: scheduler, store: store)

        manager.cancelStudyReminder()
        manager.cancelHabitReminder()

        let flattened = scheduler.removedIdentifiers.flatMap { $0 }
        XCTAssertTrue(flattened.contains("com.dsafocus.studyReminder"))
        XCTAssertTrue(flattened.contains("com.dsafocus.habitReminder"))
    }

    func testRequestAuthorizationReturnsFalseOnError() async {
        let scheduler = SpyNotificationScheduler()
        scheduler.authorizationError = TestError()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        let result = await manager.requestAuthorization()

        XCTAssertFalse(result)
    }

    func testSendTopicCompleteCelebrationAddsRequest() async {
        let scheduler = SpyNotificationScheduler()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.sendTopicCompleteCelebration(topic: "Graphs", authorized: true)

        XCTAssertEqual(scheduler.addedRequests.count, 1)
        XCTAssertTrue(scheduler.addedRequests.first?.identifier.hasPrefix("topicComplete-") == true)
    }

    func testSendTopicCompleteCelebrationSkipsWhenUnauthorized() async {
        let scheduler = SpyNotificationScheduler()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.sendTopicCompleteCelebration(topic: "Graphs", authorized: false)

        XCTAssertTrue(scheduler.addedRequests.isEmpty)
    }

    func testSendAllHabitsCelebrationAddsRequest() async {
        let scheduler = SpyNotificationScheduler()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.sendAllHabitsCelebration(authorized: true)

        XCTAssertEqual(scheduler.addedRequests.count, 1)
        XCTAssertTrue(scheduler.addedRequests.first?.identifier.hasPrefix("habitsComplete-") == true)
    }

    func testSendAllHabitsCelebrationSkipsWhenUnauthorized() async {
        let scheduler = SpyNotificationScheduler()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.sendAllHabitsCelebration(authorized: false)

        XCTAssertTrue(scheduler.addedRequests.isEmpty)
    }

    func testScheduleStudyReminderHandlesAddError() async {
        let scheduler = SpyNotificationScheduler()
        scheduler.addError = TestError()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: true,
            studyReminderTime: Date(),
            habitReminderEnabled: false,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.scheduleStudyReminder(time: Date())

        XCTAssertTrue(scheduler.addedRequests.isEmpty)
        XCTAssertTrue(scheduler.removedIdentifiers.flatMap { $0 }.contains("com.dsafocus.studyReminder"))
    }

    func testScheduleHabitReminderHandlesAddError() async {
        let scheduler = SpyNotificationScheduler()
        scheduler.addError = TestError()
        let store = InMemoryNotificationSettingsStore(settings: NotificationSettings(
            studyReminderEnabled: false,
            studyReminderTime: Date(),
            habitReminderEnabled: true,
            habitReminderTime: Date()
        ))
        let manager = NotificationManager(scheduler: scheduler, store: store)

        await manager.scheduleHabitReminder(time: Date())

        XCTAssertTrue(scheduler.addedRequests.isEmpty)
        XCTAssertTrue(scheduler.removedIdentifiers.flatMap { $0 }.contains("com.dsafocus.habitReminder"))
    }
}
