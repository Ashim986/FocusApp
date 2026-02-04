import SwiftUI

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        Form {
            Section {
                if !presenter.notificationsAuthorized {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications are not enabled")
                            .font(.headline)
                        Text("Enable notifications to receive study reminders and celebration alerts.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Enable Notifications") {
                            presenter.requestAuthorization()
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
                Toggle("Daily Study Reminder", isOn: studyReminderEnabled)
                    .disabled(!presenter.notificationsAuthorized)

                if presenter.settings.studyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: studyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!presenter.notificationsAuthorized)
                }
            } header: {
                Text("Study Reminders")
            } footer: {
                Text("Get a daily reminder to work on your DSA problems.")
            }

            Section {
                Toggle("Daily Habit Reminder", isOn: habitReminderEnabled)
                    .disabled(!presenter.notificationsAuthorized)

                if presenter.settings.habitReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: habitReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!presenter.notificationsAuthorized)
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
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("LeetCode Username")
                            .font(.subheadline)
                        Spacer()
                        validationStatusView
                    }

                    HStack(spacing: 8) {
                        TextField("username", text: $presenter.leetCodeUsername)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(validationBorderColor, lineWidth: 1)
                            )
                            .onChange(of: presenter.leetCodeUsername) { _ in
                                presenter.resetValidationState()
                            }

                        Button(action: {
                            presenter.validateAndSaveUsername()
                        }) {
                            if presenter.isValidatingUsername {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text("Validate & Sync")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(presenter.isValidatingUsername)
                    }
                }
            } header: {
                Text("LeetCode")
            } footer: {
                Text("Your LeetCode profile must be public for syncing.")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FocusApp")
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
            presenter.onAppear()
        }
    }
}
