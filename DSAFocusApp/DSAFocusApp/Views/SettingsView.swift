import SwiftUI

struct SettingsView: View {
    @ObservedObject var notificationManager: NotificationManager

    var body: some View {
        Form {
            Section {
                if !notificationManager.notificationsAuthorized {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications are not enabled")
                            .font(.headline)
                        Text("Enable notifications to receive study reminders and celebration alerts.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Enable Notifications") {
                            notificationManager.requestAuthorization()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text("Notification Status")
            }

            Section {
                Toggle("Daily Study Reminder", isOn: $notificationManager.studyReminderEnabled)
                    .disabled(!notificationManager.notificationsAuthorized)

                if notificationManager.studyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $notificationManager.studyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!notificationManager.notificationsAuthorized)
                }
            } header: {
                Text("Study Reminders")
            } footer: {
                Text("Get a daily reminder to work on your DSA problems.")
            }

            Section {
                Toggle("Daily Habit Reminder", isOn: $notificationManager.habitReminderEnabled)
                    .disabled(!notificationManager.notificationsAuthorized)

                if notificationManager.habitReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $notificationManager.habitReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!notificationManager.notificationsAuthorized)
                }
            } header: {
                Text("Habit Reminders")
            } footer: {
                Text("Get a daily reminder to complete your habits.")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Topic Completion", systemImage: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("You'll receive a notification when you complete all problems for a topic.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Label("All Habits Done", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("You'll receive a notification when you complete all daily habits.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Celebration Notifications")
            } footer: {
                Text("These are sent automatically when you achieve milestones.")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DSA Focus App")
                        .font(.headline)
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            notificationManager.checkAuthorizationStatus()
        }
    }
}

#Preview {
    SettingsView(notificationManager: NotificationManager.shared)
}
