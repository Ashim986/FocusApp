import Foundation

protocol NotificationSettingsStoring {
    func loadSettings() -> NotificationSettings
    func saveSettings(_ settings: NotificationSettings)
}

struct UserDefaultsNotificationSettingsStore: NotificationSettingsStoring {
    private let userDefaults: UserDefaults

    private let studyReminderEnabledKey = "studyReminderEnabled"
    private let studyReminderTimeKey = "studyReminderTime"
    private let habitReminderEnabledKey = "habitReminderEnabled"
    private let habitReminderTimeKey = "habitReminderTime"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSettings() -> NotificationSettings {
        let studyEnabled = userDefaults.bool(forKey: studyReminderEnabledKey)
        let habitEnabled = userDefaults.bool(forKey: habitReminderEnabledKey)

        let studyTime: Date
        if let savedStudyTime = userDefaults.object(forKey: studyReminderTimeKey) as? Date {
            studyTime = savedStudyTime
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            studyTime = Calendar.current.date(from: components) ?? Date()
        }

        let habitTime: Date
        if let savedHabitTime = userDefaults.object(forKey: habitReminderTimeKey) as? Date {
            habitTime = savedHabitTime
        } else {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            habitTime = Calendar.current.date(from: components) ?? Date()
        }

        return NotificationSettings(
            studyReminderEnabled: studyEnabled,
            studyReminderTime: studyTime,
            habitReminderEnabled: habitEnabled,
            habitReminderTime: habitTime
        )
    }

    func saveSettings(_ settings: NotificationSettings) {
        userDefaults.set(settings.studyReminderEnabled, forKey: studyReminderEnabledKey)
        userDefaults.set(settings.studyReminderTime, forKey: studyReminderTimeKey)
        userDefaults.set(settings.habitReminderEnabled, forKey: habitReminderEnabledKey)
        userDefaults.set(settings.habitReminderTime, forKey: habitReminderTimeKey)
    }
}
