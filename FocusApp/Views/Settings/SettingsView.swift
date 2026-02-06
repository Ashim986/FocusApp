import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter
    @ObservedObject var debugLogStore: DebugLogStore
    @State private var isShowingLogs = false

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
                DatePicker(
                    L10n.Settings.planStartDateTitle,
                    selection: planStartDate,
                    displayedComponents: .date
                )

                Button(action: {
                    presenter.resetPlanStartDateToToday()
                }, label: {
                    Text(L10n.Settings.planStartReset)
                })
                .buttonStyle(.bordered)
            } header: {
                Text(L10n.Settings.planStartHeader)
            } footer: {
                Text(L10n.Settings.planStartFooter)
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
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Settings.aiProviderLabel)
                        .font(.subheadline)

                    Picker(L10n.Settings.aiProviderLabel, selection: aiProviderKind) {
                        ForEach(AIProviderKind.allCases, id: \.self) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Settings.aiApiKeyLabel)
                        .font(.subheadline)

                    SecureField(
                        L10n.Settings.aiApiKeyPlaceholder,
                        text: $presenter.aiProviderApiKey
                    )
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: presenter.aiProviderApiKey) { _, _ in
                        presenter.saveAIProviderSettings()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Settings.aiModelLabel)
                        .font(.subheadline)

                    Picker(L10n.Settings.aiModelLabel, selection: aiProviderModel) {
                        ForEach(presenter.aiProviderKind.modelOptions, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .labelsHidden()
                }
            } header: {
                Text(L10n.Settings.aiHeader)
            } footer: {
                Text(L10n.Settings.aiFooter)
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

            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Debug.logsTitle)
                            .font(.subheadline)
                        Text(L10n.Debug.logsSubtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(L10n.Debug.openLogs) {
                        isShowingLogs = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            } header: {
                Text(L10n.Debug.header)
            } footer: {
                Text(L10n.Debug.footer)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            presenter.onAppear()
        }
        .sheet(isPresented: $isShowingLogs) {
            DebugLogView(
                store: debugLogStore,
                onClose: { isShowingLogs = false }
            )
        }
    }
}
