import Foundation
import UserNotifications

protocol NotificationManaging {
    func loadSettings() -> NotificationSettings
    func saveSettings(_ settings: NotificationSettings)
    func requestAuthorization() async -> Bool
    func checkAuthorizationStatus() async -> Bool
    func updateAllReminders(settings: NotificationSettings, authorized: Bool) async
    func sendTopicCompleteCelebration(topic: String, authorized: Bool) async
    func sendAllHabitsCelebration(authorized: Bool) async
}

final class NotificationManager: NotificationManaging {
    private let scheduler: NotificationScheduling
    private let store: NotificationSettingsStoring

    // Notification identifiers
    private let studyReminderIdentifier = "com.dsafocus.studyReminder"
    private let habitReminderIdentifier = "com.dsafocus.habitReminder"

    init(
        scheduler: NotificationScheduling,
        store: NotificationSettingsStoring
    ) {
        self.scheduler = scheduler
        self.store = store
    }

    func loadSettings() -> NotificationSettings {
        store.loadSettings()
    }

    func saveSettings(_ settings: NotificationSettings) {
        store.saveSettings(settings)
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await scheduler.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async -> Bool {
        let settings = await scheduler.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func updateAllReminders(settings: NotificationSettings, authorized: Bool) async {
        guard authorized else { return }
        if settings.studyReminderEnabled {
            await scheduleStudyReminder(time: settings.studyReminderTime)
        } else {
            cancelStudyReminder()
        }

        if settings.habitReminderEnabled {
            await scheduleHabitReminder(time: settings.habitReminderTime)
        } else {
            cancelHabitReminder()
        }
    }

    func scheduleStudyReminder(time: Date) async {
        cancelStudyReminder()

        let content = UNMutableNotificationContent()
        let notice = AppNotices.studyReminder
        content.title = notice.title
        content.body = notice.body
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: studyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await scheduler.add(request)
        } catch {
            print("Failed to schedule study reminder: \(error)")
        }
    }

    func cancelStudyReminder() {
        scheduler.removePendingRequests(identifiers: [studyReminderIdentifier])
    }

    func scheduleHabitReminder(time: Date) async {
        cancelHabitReminder()

        let content = UNMutableNotificationContent()
        let notice = AppNotices.habitReminder
        content.title = notice.title
        content.body = notice.body
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: habitReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await scheduler.add(request)
        } catch {
            print("Failed to schedule habit reminder: \(error)")
        }
    }

    func cancelHabitReminder() {
        scheduler.removePendingRequests(identifiers: [habitReminderIdentifier])
    }

    func sendTopicCompleteCelebration(topic: String, authorized: Bool) async {
        guard authorized else { return }

        let content = UNMutableNotificationContent()
        let notice = AppNotices.topicComplete(topic)
        content.title = notice.title
        content.body = notice.body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "topicComplete-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await scheduler.add(request)
        } catch {
            print("Failed to send topic completion notification: \(error)")
        }
    }

    func sendAllHabitsCelebration(authorized: Bool) async {
        guard authorized else { return }

        let content = UNMutableNotificationContent()
        let notice = AppNotices.habitsComplete
        content.title = notice.title
        content.body = notice.body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "habitsComplete-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await scheduler.add(request)
        } catch {
            print("Failed to send habits completion notification: \(error)")
        }
    }
}
