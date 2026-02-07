import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter
    @ObservedObject var debugLogStore: DebugLogStore
    @State private var isShowingLogs = false
    @State private var isShowingLeetCodeLogin = false
    @State private var isShowingAITestCases = false
    @State private var aiTestCaseJSON: String = ""
    @State private var isExportingAITestCases = false
    @State private var aiTestCaseExportDocument = AITestCaseJSONDocument(text: "")

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

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(L10n.Settings.leetcodeLoginTitle)
                            .font(.subheadline)
                        Spacer()
                        leetCodeLoginStatusView
                    }

                    Text(L10n.Settings.leetcodeLoginBody)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Button(L10n.Settings.leetcodeLoginButton) {
                            isShowingLeetCodeLogin = true
                        }
                        .buttonStyle(.borderedProminent)

                        if presenter.leetCodeAuth != nil {
                            Button(L10n.Settings.leetcodeLogoutButton) {
                                presenter.clearLeetCodeAuth()
                            }
                            .buttonStyle(.bordered)
                        }
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

            AITestCasesSectionView(
                summary: presenter.aiTestCaseSummary,
                updatedText: presenter.aiTestCaseUpdatedText(),
                onView: {
                    aiTestCaseJSON = presenter.aiTestCaseRawJSON() ?? ""
                    isShowingAITestCases = true
                },
                onExport: {
                    let json = presenter.aiTestCaseRawJSON() ?? ""
                    aiTestCaseExportDocument = AITestCaseJSONDocument(text: json)
                    isExportingAITestCases = true
                }
            )

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
        .sheet(isPresented: $isShowingLeetCodeLogin) {
            LeetCodeLoginSheet(
                onAuthCaptured: { auth in
                    presenter.updateLeetCodeAuth(auth)
                    isShowingLeetCodeLogin = false
                },
                onClose: { isShowingLeetCodeLogin = false }
            )
        }
        .sheet(isPresented: $isShowingLogs) {
            DebugLogView(
                store: debugLogStore,
                onClose: { isShowingLogs = false }
            )
        }
        .sheet(isPresented: $isShowingAITestCases) {
            AITestCaseViewerSheet(
                jsonText: aiTestCaseJSON,
                fileURL: presenter.aiTestCaseSummary.fileURL,
                onClose: { isShowingAITestCases = false }
            )
        }
        .fileExporter(
            isPresented: $isExportingAITestCases,
            document: aiTestCaseExportDocument,
            contentType: .json,
            defaultFilename: "focusapp-ai-testcases"
        ) { _ in }
    }

    private var leetCodeLoginStatusView: some View {
        let isLoggedIn = presenter.leetCodeAuth != nil
        return Text(isLoggedIn ? L10n.Settings.leetcodeLoginStatusConnected
                               : L10n.Settings.leetcodeLoginStatusDisconnected)
            .font(.caption)
            .foregroundColor(isLoggedIn ? Color.appGreen : Color.appGray500)
    }
}

private struct AITestCaseJSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let text = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

private struct AITestCasesSectionView: View {
    let summary: AITestCaseStoreSummary
    let updatedText: String?
    let onView: () -> Void
    let onExport: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                if summary.exists {
                    Text(L10n.Settings.aiTestCasesSummary(summary.entryCount, summary.testCaseCount))
                        .font(.subheadline)

                    if let updatedText {
                        Text(L10n.Settings.aiTestCasesUpdated(updatedText))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(L10n.Settings.aiTestCasesPath(summary.fileURL.path))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text(L10n.Settings.aiTestCasesEmpty)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)

            HStack(spacing: 8) {
                Button(L10n.Settings.aiTestCasesView) {
                    onView()
                }
                .buttonStyle(.bordered)
                .disabled(!summary.exists)

                Button(L10n.Settings.aiTestCasesExport) {
                    onExport()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!summary.exists)
            }
        } header: {
            Text(L10n.Settings.aiTestCasesHeader)
        } footer: {
            Text(L10n.Settings.aiTestCasesFooter)
        }
    }
}

private struct AITestCaseViewerSheet: View {
    let jsonText: String
    let fileURL: URL
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Settings.aiTestCasesTitle)
                    .font(.headline)
                Spacer()
                Button(L10n.Settings.close) {
                    onClose()
                }
                .buttonStyle(.bordered)
            }

            Text(L10n.Settings.aiTestCasesPath(fileURL.path))
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Divider()

            ScrollView {
                Text(jsonText.isEmpty ? L10n.Settings.aiTestCasesEmpty : jsonText)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 420)
        #endif
    }
}
