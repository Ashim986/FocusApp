#if os(macOS)
import FocusDesignSystem
import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter
    @ObservedObject var debugLogStore: DebugLogStore
    @Environment(\.dsTheme) var theme
    @State private var isShowingLogs = false
    @State private var isShowingLeetCodeLogin = false
    @State private var isShowingAITestCases = false
    @State private var aiTestCaseJSON: String = ""
    @State private var isExportingAITestCases = false
    @State private var aiTestCaseExportDocument = AITestCaseJSONDocument(text: "")

    var body: some View {
        Form {
            SettingsNotificationStatusSection(presenter: presenter)

            SettingsStudyRemindersSection(
                presenter: presenter,
                studyReminderEnabled: studyReminderEnabled,
                studyReminderTime: studyReminderTime
            )

            SettingsHabitRemindersSection(
                presenter: presenter,
                habitReminderEnabled: habitReminderEnabled,
                habitReminderTime: habitReminderTime
            )

            SettingsPlanStartSection(presenter: presenter, planStartDate: planStartDate)

            SettingsCelebrationSection()

            SettingsLeetCodeSection(
                presenter: presenter,
                isShowingLeetCodeLogin: $isShowingLeetCodeLogin
            )

            SettingsAISection(
                presenter: presenter,
                aiProviderKind: aiProviderKind,
                aiProviderModel: aiProviderModel
            )

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
                VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                    Text(L10n.Settings.appName)
                        .font(.headline)
                    Text(L10n.Settings.versionLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, DSLayout.spacing(.space4))
            } header: {
                Text(L10n.Settings.aboutHeader)
            }

            Section {
                HStack {
                    VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                        Text(L10n.Debug.logsTitle)
                            .font(.subheadline)
                        Text(L10n.Debug.logsSubtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    DSButton(
                        L10n.Debug.openLogs,
                        config: .init(style: .secondary, size: .small)
                    ) {
                        isShowingLogs = true
                    }
                }
                .padding(.vertical, DSLayout.spacing(.space4))
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
}

private struct SettingsNotificationStatusSection: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        Section {
            if !presenter.notificationsAuthorized {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                    Text(L10n.Settings.notificationsDisabledTitle)
                        .font(.headline)
                    Text(L10n.Settings.notificationsDisabledBody)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DSButton(
                        L10n.Settings.enableNotifications,
                        config: .init(style: .primary, size: .small)
                    ) {
                        presenter.requestAuthorization()
                    }
                    .padding(.top, DSLayout.spacing(.space4))
                }
                .padding(.vertical, DSLayout.spacing(.space8))
            }
        } header: {
            Text(L10n.Settings.notificationStatus)
        }
    }
}

private struct SettingsLeetCodeSection: View {
    @ObservedObject var presenter: SettingsPresenter
    @Binding var isShowingLeetCodeLogin: Bool
    @Environment(\.dsTheme) var theme

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                HStack {
                    Text(L10n.Settings.leetcodeUsername)
                        .font(.subheadline)
                    Spacer()
                    validationStatusView
                }

                HStack(spacing: DSLayout.spacing(.space8)) {
                    let validation: DSTextFieldValidation = {
                        switch presenter.usernameValidationState {
                        case .valid:
                            return .valid
                        case .invalid:
                            return .invalid(nil)
                        case .none:
                            return .none
                        }
                    }()

                    DSTextField(
                        placeholder: L10n.Settings.usernamePlaceholder,
                        text: $presenter.leetCodeUsername,
                        config: DSTextFieldConfig(style: .outlined, size: .medium),
                        state: DSTextFieldState(validation: validation)
                    )
                    .onChange(of: presenter.leetCodeUsername) { _, _ in
                        presenter.resetValidationState()
                    }

                    DSButton(
                        L10n.Settings.validateSync,
                        config: .init(style: .primary, size: .small),
                        state: .init(
                            isEnabled: !presenter.isValidatingUsername,
                            isLoading: presenter.isValidatingUsername
                        )
                    ) {
                        presenter.validateAndSaveUsername()
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
                HStack {
                    Text(L10n.Settings.leetcodeLoginTitle)
                        .font(.subheadline)
                    Spacer()
                    leetCodeLoginStatusView
                }

                Text(L10n.Settings.leetcodeLoginBody)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: DSLayout.spacing(.space8)) {
                    DSButton(
                        L10n.Settings.leetcodeLoginButton,
                        config: .init(style: .primary, size: .small)
                    ) {
                        isShowingLeetCodeLogin = true
                    }

                    if presenter.leetCodeAuth != nil {
                        DSButton(
                            L10n.Settings.leetcodeLogoutButton,
                            config: .init(style: .secondary, size: .small)
                        ) {
                            presenter.clearLeetCodeAuth()
                        }
                    }
                }
            }
        } header: {
            Text(L10n.Settings.leetcodeHeader)
        } footer: {
            Text(L10n.Settings.leetcodeFooter)
        }
    }

    private var leetCodeLoginStatusView: some View {
        let isLoggedIn = presenter.leetCodeAuth != nil
        return Text(isLoggedIn ? L10n.Settings.leetcodeLoginStatusConnected
                               : L10n.Settings.leetcodeLoginStatusDisconnected)
            .font(.caption)
            .foregroundColor(isLoggedIn ? theme.colors.success : theme.colors.textSecondary)
    }

    @ViewBuilder
    private var validationStatusView: some View {
        switch presenter.usernameValidationState {
        case .valid:
            HStack(spacing: DSLayout.spacing(6)) {
                Image(systemName: "checkmark.circle.fill")
                Text(L10n.Settings.validationValid)
            }
            .foregroundColor(.green)
            .font(.caption)
        case .invalid:
            HStack(spacing: DSLayout.spacing(6)) {
                Image(systemName: "xmark.circle.fill")
                Text(L10n.Settings.validationNotFound)
            }
            .foregroundColor(.red)
            .font(.caption)
        case .none:
            EmptyView()
        }
    }
}

private struct SettingsAISection: View {
    @ObservedObject var presenter: SettingsPresenter
    let aiProviderKind: Binding<AIProviderKind>
    let aiProviderModel: Binding<String>

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                Text(L10n.Settings.aiProviderLabel)
                    .font(.subheadline)

                Picker(L10n.Settings.aiProviderLabel, selection: aiProviderKind) {
                    ForEach(AIProviderKind.allCases, id: \.self) { kind in
                        Text(kind.displayName).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                Text(L10n.Settings.aiApiKeyLabel)
                    .font(.subheadline)

                DSTextField(
                    placeholder: L10n.Settings.aiApiKeyPlaceholder,
                    text: $presenter.aiProviderApiKey,
                    config: DSTextFieldConfig(style: .outlined, size: .medium, isSecure: true)
                )
                .onChange(of: presenter.aiProviderApiKey) { _, _ in
                    presenter.saveAIProviderSettings()
                }
            }

            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
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
    }
}

private struct SettingsStudyRemindersSection: View {
    @ObservedObject var presenter: SettingsPresenter
    let studyReminderEnabled: Binding<Bool>
    let studyReminderTime: Binding<Date>

    var body: some View {
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
    }
}

private struct SettingsHabitRemindersSection: View {
    @ObservedObject var presenter: SettingsPresenter
    let habitReminderEnabled: Binding<Bool>
    let habitReminderTime: Binding<Date>

    var body: some View {
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
    }
}

private struct SettingsPlanStartSection: View {
    @ObservedObject var presenter: SettingsPresenter
    let planStartDate: Binding<Date>

    var body: some View {
        Section {
            DatePicker(
                L10n.Settings.planStartDateTitle,
                selection: planStartDate,
                displayedComponents: .date
            )

            DSButton(
                L10n.Settings.planStartReset,
                config: .init(style: .secondary, size: .small)
            ) {
                presenter.resetPlanStartDateToToday()
            }
        } header: {
            Text(L10n.Settings.planStartHeader)
        } footer: {
            Text(L10n.Settings.planStartFooter)
        }
    }
}

private struct SettingsCelebrationSection: View {
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                HStack(spacing: DSLayout.spacing(6)) {
                    Image(systemName: "trophy.fill")
                    Text(L10n.Settings.topicCompletion)
                }
                .foregroundColor(.yellow)
                Text(L10n.Settings.topicCompletionBody)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, DSLayout.spacing(.space4))

            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                HStack(spacing: DSLayout.spacing(6)) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(L10n.Settings.allHabitsDone)
                }
                .foregroundColor(.green)
                Text(L10n.Settings.allHabitsDoneBody)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, DSLayout.spacing(.space4))
        } header: {
            Text(L10n.Settings.celebrationHeader)
        } footer: {
            Text(L10n.Settings.celebrationFooter)
        }
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
            VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
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
            .padding(.vertical, DSLayout.spacing(.space4))

            HStack(spacing: DSLayout.spacing(.space8)) {
                DSButton(
                    L10n.Settings.aiTestCasesView,
                    config: .init(style: .secondary, size: .small)
                ) {
                    onView()
                }
                .disabled(!summary.exists)

                DSButton(
                    L10n.Settings.aiTestCasesExport,
                    config: .init(style: .primary, size: .small)
                ) {
                    onExport()
                }
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
        VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
            HStack {
                Text(L10n.Settings.aiTestCasesTitle)
                    .font(.headline)
                Spacer()
                DSButton(
                    L10n.Settings.close,
                    config: .init(style: .secondary, size: .small)
                ) {
                    onClose()
                }
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

#endif
