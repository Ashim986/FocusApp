import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    // UserDefaults keys
    private let studyReminderEnabledKey = "studyReminderEnabled"
    private let studyReminderTimeKey = "studyReminderTime"
    private let habitReminderEnabledKey = "habitReminderEnabled"
    private let habitReminderTimeKey = "habitReminderTime"

    // Notification identifiers
    private let studyReminderIdentifier = "com.dsafocus.studyReminder"
    private let habitReminderIdentifier = "com.dsafocus.habitReminder"

    // Published properties for settings UI
    @Published var studyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(studyReminderEnabled, forKey: studyReminderEnabledKey)
            updateStudyReminder()
        }
    }

    @Published var studyReminderTime: Date {
        didSet {
            UserDefaults.standard.set(studyReminderTime, forKey: studyReminderTimeKey)
            if studyReminderEnabled {
                scheduleStudyReminder()
            }
        }
    }

    @Published var habitReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(habitReminderEnabled, forKey: habitReminderEnabledKey)
            updateHabitReminder()
        }
    }

    @Published var habitReminderTime: Date {
        didSet {
            UserDefaults.standard.set(habitReminderTime, forKey: habitReminderTimeKey)
            if habitReminderEnabled {
                scheduleHabitReminder()
            }
        }
    }

    @Published var notificationsAuthorized: Bool = false

    init() {
        // Load saved settings
        self.studyReminderEnabled = UserDefaults.standard.bool(forKey: studyReminderEnabledKey)
        self.habitReminderEnabled = UserDefaults.standard.bool(forKey: habitReminderEnabledKey)

        // Default times: 9 AM for study, 8 PM for habits
        if let savedStudyTime = UserDefaults.standard.object(forKey: studyReminderTimeKey) as? Date {
            self.studyReminderTime = savedStudyTime
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            self.studyReminderTime = Calendar.current.date(from: components) ?? Date()
        }

        if let savedHabitTime = UserDefaults.standard.object(forKey: habitReminderTimeKey) as? Date {
            self.habitReminderTime = savedHabitTime
        } else {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            self.habitReminderTime = Calendar.current.date(from: components) ?? Date()
        }

        // Check current authorization status
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationsAuthorized = granted
                if granted {
                    self?.updateAllReminders()
                }
            }
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationsAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Study Reminders

    private func updateStudyReminder() {
        if studyReminderEnabled {
            scheduleStudyReminder()
        } else {
            cancelStudyReminder()
        }
    }

    func scheduleStudyReminder() {
        guard notificationsAuthorized else { return }

        // Cancel existing reminder first
        cancelStudyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to Study DSA!"
        content.body = "Keep your streak going - tackle today's problems!"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: studyReminderTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: studyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule study reminder: \(error)")
            }
        }
    }

    func cancelStudyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [studyReminderIdentifier]
        )
    }

    // MARK: - Habit Reminders

    private func updateHabitReminder() {
        if habitReminderEnabled {
            scheduleHabitReminder()
        } else {
            cancelHabitReminder()
        }
    }

    func scheduleHabitReminder() {
        guard notificationsAuthorized else { return }

        // Cancel existing reminder first
        cancelHabitReminder()

        let content = UNMutableNotificationContent()
        content.title = "Don't Forget Your Habits!"
        content.body = "Have you completed your daily habits today?"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: habitReminderTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: habitReminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule habit reminder: \(error)")
            }
        }
    }

    func cancelHabitReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [habitReminderIdentifier]
        )
    }

    // MARK: - Celebration Notifications

    func sendTopicCompleteCelebration(topic: String) {
        guard notificationsAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Congratulations!"
        content.body = "You've mastered \(topic)! Keep up the great work!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "topicComplete-\(UUID().uuidString)",
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send topic completion notification: \(error)")
            }
        }
    }

    func sendAllHabitsCelebration() {
        guard notificationsAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "All Habits Complete!"
        content.body = "You've completed all your habits for today. Great discipline!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "habitsComplete-\(UUID().uuidString)",
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send habits completion notification: \(error)")
            }
        }
    }

    // MARK: - Helpers

    private func updateAllReminders() {
        if studyReminderEnabled {
            scheduleStudyReminder()
        }
        if habitReminderEnabled {
            scheduleHabitReminder()
        }
    }
}
