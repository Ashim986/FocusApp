import SwiftUI

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        Form {
            Section {
                if !presenter.notificationsAuthorized {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.Settings.notificationsDisabledTitle)
                            .font(.headline)
                        Text(L10n.Settings.notificationsDisabledBody)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button(L10n.Settings.enableNotifications) {
                            presenter.requestAuthorization()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text(L10n.Settings.notificationStatus)
            }

            Section {
                Toggle(L10n.Settings.dailyStudyReminderToggle, isOn: studyReminderEnabled)
                    .disabled(!presenter.notificationsAuthorized)

                if presenter.settings.studyReminderEnabled {
                    DatePicker(
                        L10n.Settings.reminderTime,
                        selection: studyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!presenter.notificationsAuthorized)
                }
            } header: {
                Text(L10n.Settings.studyRemindersHeader)
            } footer: {
                Text(L10n.Settings.studyRemindersFooter)
            }

            Section {
                Toggle(L10n.Settings.dailyHabitReminderToggle, isOn: habitReminderEnabled)
                    .disabled(!presenter.notificationsAuthorized)

                if presenter.settings.habitReminderEnabled {
                    DatePicker(
                        L10n.Settings.reminderTime,
                        selection: habitReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!presenter.notificationsAuthorized)
                }
            } header: {
                Text(L10n.Settings.habitRemindersHeader)
            } footer: {
                Text(L10n.Settings.habitRemindersFooter)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label(L10n.Settings.topicCompletion, systemImage: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text(L10n.Settings.topicCompletionBody)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Label(L10n.Settings.allHabitsDone, systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(L10n.Settings.allHabitsDoneBody)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text(L10n.Settings.celebrationHeader)
            } footer: {
                Text(L10n.Settings.celebrationFooter)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.Settings.leetcodeUsername)
                            .font(.subheadline)
                        Spacer()
                        validationStatusView
                    }

                    HStack(spacing: 8) {
                        TextField(L10n.Settings.usernamePlaceholder, text: $presenter.leetCodeUsername)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(validationBorderColor, lineWidth: 1)
                            )
                            .onChange(of: presenter.leetCodeUsername) { _, _ in
                                presenter.resetValidationState()
                            }

                        Button(action: {
                            presenter.validateAndSaveUsername()
                        }, label: {
                            if presenter.isValidatingUsername {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text(L10n.Settings.validateSync)
                            }
                        })
                        .buttonStyle(.borderedProminent)
                        .disabled(presenter.isValidatingUsername)
                    }
                }
            } header: {
                Text(L10n.Settings.leetcodeHeader)
            } footer: {
                Text(L10n.Settings.leetcodeFooter)
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Settings.appName)
                        .font(.headline)
                    Text(L10n.Settings.versionLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text(L10n.Settings.aboutHeader)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            presenter.onAppear()
        }
    }
}
