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
            DebugLogView(store: debugLogStore)
        }
    }
}

private struct DebugLogView: View {
    @ObservedObject var store: DebugLogStore
    @State private var selectedLevel: DebugLogLevelFilter = .all
    @State private var selectedCategory: DebugLogCategoryFilter = .all
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            filters
            Divider()
            content
        }
        .frame(minWidth: 640, minHeight: 480)
    }

    private var header: some View {
        HStack {
            Text(L10n.Debug.logsTitle)
                .font(.title3.weight(.semibold))
            Spacer()
            Button(L10n.Debug.copyLogs) {
                copyLogs()
            }
            .buttonStyle(.bordered)
            Button(L10n.Debug.clearLogs) {
                store.clear()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(Color.appGray900)
    }

    private var filters: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
                    ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
                    ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }

            TextField(L10n.Debug.searchPlaceholder, text: $searchText)
                .textFieldStyle(.roundedBorder)
        }
        .padding(16)
        .background(Color.appGray800)
    }

    private var content: some View {
        let filtered = filteredEntries
        return Group {
            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(Color.appGray500)
                    Text(L10n.Debug.emptyTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(L10n.Debug.emptyBody)
                        .font(.system(size: 12))
                        .foregroundColor(Color.appGray500)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appGray900)
            } else {
                List {
                    ForEach(filtered) { entry in
                        DebugLogRow(entry: entry)
                            .listRowBackground(Color.appGray900)
                    }
                }
                .listStyle(.plain)
                .background(Color.appGray900)
            }
        }
    }

    private var filteredEntries: [DebugLogEntry] {
        store.entries.filter { entry in
            if selectedLevel != .all && entry.level != selectedLevel.level {
                return false
            }
            if selectedCategory != .all && entry.category != selectedCategory.category {
                return false
            }
            if !searchText.isEmpty {
                let haystack = "\(entry.title) \(entry.message) \(entry.metadata.values.joined(separator: " "))"
                if !haystack.lowercased().contains(searchText.lowercased()) {
                    return false
                }
            }
            return true
        }
    }

    private func copyLogs() {
        let lines = filteredEntries.map { entry in
            let time = Self.timestampFormatter.string(from: entry.timestamp)
            let meta = entry.metadata
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: " ")
            let metaSuffix = meta.isEmpty ? "" : " | \(meta)"
            return "[\(time)] [\(entry.level.rawValue)] [\(entry.category.rawValue)] \(entry.title) - \(entry.message)\(metaSuffix)"
        }
        let text = lines.joined(separator: "\n")
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

private struct DebugLogRow: View {
    let entry: DebugLogEntry
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(levelColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(Self.timestampFormatter.string(from: entry.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(Color.appGray500)
                    }

                    Text(entry.message)
                        .font(.system(size: 11))
                        .foregroundColor(Color.appGray300)
                        .lineLimit(isExpanded ? nil : 2)

                    if isExpanded, !entry.metadata.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(entry.metadata.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key): \(value)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(Color.appGray400)
                            }
                        }
                    }
                }
            }

            if !entry.metadata.isEmpty {
                Button(isExpanded ? L10n.Debug.hideDetails : L10n.Debug.showDetails) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.appPurple)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appGray800)
        )
        .listRowSeparator(.hidden)
    }

    private var levelColor: Color {
        switch entry.level {
        case .info:
            return Color.appCyan
        case .warning:
            return Color.appAmber
        case .error:
            return Color.appRed
        }
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

private enum DebugLogLevelFilter: CaseIterable {
    case all
    case info
    case warning
    case error

    var title: String {
        switch self {
        case .all: return L10n.Debug.levelAll
        case .info: return DebugLogLevel.info.rawValue
        case .warning: return DebugLogLevel.warning.rawValue
        case .error: return DebugLogLevel.error.rawValue
        }
    }

    var level: DebugLogLevel? {
        switch self {
        case .all: return nil
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}

private enum DebugLogCategoryFilter: CaseIterable {
    case all
    case network
    case sync
    case execution
    case app

    var title: String {
        switch self {
        case .all: return L10n.Debug.categoryAll
        case .network: return DebugLogCategory.network.rawValue
        case .sync: return DebugLogCategory.sync.rawValue
        case .execution: return DebugLogCategory.execution.rawValue
        case .app: return DebugLogCategory.app.rawValue
        }
    }

    var category: DebugLogCategory? {
        switch self {
        case .all: return nil
        case .network: return .network
        case .sync: return .sync
        case .execution: return .execution
        case .app: return .app
        }
    }
}
