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
            DebugLogView(
                store: debugLogStore,
                onClose: { isShowingLogs = false }
            )
        }
    }
}

struct DebugLogView: View {
    @ObservedObject var store: DebugLogStore
    var isEmbedded: Bool = false
    var onClose: (() -> Void)? = nil
    @State private var selectedLevel: DebugLogLevelFilter = .all
    @State private var selectedCategory: DebugLogCategoryFilter = .all
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            summary
            filters
            Divider()
            content
        }
        .frame(minWidth: isEmbedded ? 0 : 640, minHeight: isEmbedded ? 0 : 480)
        .background(debugBackground)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Debug.logsTitle)
                    .font(.title3.weight(.semibold))

                HStack(spacing: 8) {
                    statusChip(title: "Live", color: Color.appGreen)
                    Text("Last \(lastEntryTimestamp)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.appGray400)
                }
            }
            Spacer()
            Text("\(store.entries.count)")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appGray800.opacity(0.8))
                )
            if let onClose {
                Button(action: onClose, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.appGray300)
                        .frame(width: 28, height: 28)
                        .background(Color.appGray800)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                })
                .buttonStyle(.plain)
                .help("Close")
            }
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
        .background(headerBackground)
    }

    private var filters: some View {
        VStack(spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    levelSegmentedPicker
                    categorySegmentedPicker
                }

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        levelMenuPicker
                        categoryMenuPicker
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.appGray400)
                TextField(L10n.Debug.searchPlaceholder, text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appGray900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appGray700, lineWidth: 1)
                    )
            )
        }
        .padding(16)
        .background(Color.appGray800)
    }

    private var summary: some View {
        let counts = entryCounts
        return HStack(spacing: 10) {
            summaryPill(
                title: L10n.Debug.levelAll,
                count: counts.total,
                color: Color.appGray500,
                isSelected: selectedLevel == .all
            ) {
                selectedLevel = .all
            }
            summaryPill(
                title: DebugLogLevel.error.rawValue,
                count: counts.error,
                color: Color.appRed,
                isSelected: selectedLevel == .error
            ) {
                selectedLevel = .error
            }
            summaryPill(
                title: DebugLogLevel.warning.rawValue,
                count: counts.warning,
                color: Color.appAmber,
                isSelected: selectedLevel == .warning
            ) {
                selectedLevel = .warning
            }
            summaryPill(
                title: DebugLogLevel.info.rawValue,
                count: counts.info,
                color: Color.appCyan,
                isSelected: selectedLevel == .info
            ) {
                selectedLevel = .info
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color.appGray800)
    }

    private func summaryPill(
        title: String,
        count: Int,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action, label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.appGray700 : Color.appGray900)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color.opacity(0.7) : Color.appGray700, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
    }

    private var content: some View {
        let filtered = filteredEntries
        return Group {
            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(Color.appGray500)
                    if store.entries.isEmpty {
                        Text(L10n.Debug.emptyTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text(L10n.Debug.emptyBody)
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray500)
                    } else {
                        Text("No logs match your filters")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Try clearing the filters to view recent entries.")
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray500)

                        Button("Reset filters") {
                            resetFilters()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appGray900)
            } else {
                List {
                    ForEach(filtered) { entry in
                        DebugLogRow(entry: entry)
                            .listRowBackground(Color.clear)
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

    private var entryCounts: DebugLogCounts {
        var infoCount = 0
        var warningCount = 0
        var errorCount = 0
        for entry in store.entries {
            switch entry.level {
            case .info:
                infoCount += 1
            case .warning:
                warningCount += 1
            case .error:
                errorCount += 1
            }
        }
        return DebugLogCounts(
            total: store.entries.count,
            info: infoCount,
            warning: warningCount,
            error: errorCount
        )
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

    private var lastEntryTimestamp: String {
        guard let entry = store.entries.first else {
            return "—"
        }
        return Self.timestampFormatter.string(from: entry.timestamp)
    }

    private func resetFilters() {
        selectedLevel = .all
        selectedCategory = .all
        searchText = ""
    }

    private var levelSegmentedPicker: some View {
        Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
            ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    private var categorySegmentedPicker: some View {
        Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
            ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    private var levelMenuPicker: some View {
        Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
            ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }

    private var categoryMenuPicker: some View {
        Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
            ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }

    private var headerBackground: some View {
        LinearGradient(
            colors: [
                Color.appGray900,
                Color.appGray800.opacity(0.9),
                Color.appGreen.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var debugBackground: some View {
        LinearGradient(
            colors: [
                Color.appGray900,
                Color.appGray800,
                Color.appGray900
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func statusChip(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
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
                .fill(levelBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(levelBorder, lineWidth: 1)
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

    private var levelBackground: Color {
        switch entry.level {
        case .info:
            return Color.appGreenLight.opacity(0.12)
        case .warning:
            return Color.appAmberLight.opacity(0.18)
        case .error:
            return Color.appRedLight.opacity(0.2)
        }
    }

    private var levelBorder: Color {
        switch entry.level {
        case .info:
            return Color.appGreen.opacity(0.5)
        case .warning:
            return Color.appAmber.opacity(0.6)
        case .error:
            return Color.appRed.opacity(0.6)
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

private struct DebugLogCounts {
    let total: Int
    let info: Int
    let warning: Int
    let error: Int
}
