// swiftlint:disable file_length
#if os(iOS)
// SettingsViewIOS.swift
// FocusApp -- Unified Settings view for iPhone and iPad
// Uses horizontalSizeClass to adapt layout

import FocusDesignSystem
import SwiftUI

// swiftlint:disable:next type_body_length
struct SettingsViewIOS: View {
    @ObservedObject var presenter: SettingsPresenter
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        if sizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
        NavigationView {
            ScrollView {
                settingsContent
                    .frame(maxWidth: 500)
                    .padding(.horizontal, theme.spacing.xl)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 48)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            presenter.onAppear()
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    Text("Settings")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    settingsContent
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
        .onAppear {
            presenter.onAppear()
        }
    }

    // MARK: - Header Bar (Compact only)

    private var headerBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Settings Content (Shared)

    @ViewBuilder
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            // LEETCODE ACCOUNT section
            sectionHeader("LeetCode Account")

            if sizeClass == .regular {
                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        usernameRow
                    }
                }
            } else {
                compactUsernameCard
            }

            // NOTIFICATIONS section
            sectionHeader("Notifications")

            if sizeClass == .regular {
                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        notificationRow

                        if !presenter.notificationsAuthorized {
                            Divider().padding(.leading, 64)
                            authorizeNotificationsRow
                        }
                    }
                }
            } else {
                compactNotificationCard
            }

            // STUDY PLAN section
            sectionHeader("Study Plan")

            if sizeClass == .regular {
                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        planStartDateRow
                        Divider().padding(.leading, 64)
                        resetStartDateRow
                    }
                }
            } else {
                compactPlanCard
            }

            // AI PROVIDER section
            sectionHeader("AI Provider")

            if sizeClass == .regular {
                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        aiProviderRow
                        Divider().padding(.leading, 64)
                        aiApiKeyRow
                        Divider().padding(.leading, 64)
                        aiModelRow
                    }
                }
            } else {
                compactAIProviderCard
            }

            // LEETCODE SESSION section
            sectionHeader("LeetCode Session")

            if sizeClass == .regular {
                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        leetCodeSessionRow
                    }
                }
            } else {
                compactSessionCard
            }
        }
        .padding(.horizontal, sizeClass == .regular ? 0 : theme.spacing.lg)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(theme.colors.textSecondary)
    }

    // MARK: - Username Row (Regular)

    private var usernameRow: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(theme.colors.primary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetCode Username")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Used to sync your solved problems")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, theme.spacing.md)

            HStack(spacing: theme.spacing.sm) {
                TextField("Enter username", text: $presenter.leetCodeUsername)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14))
                    .onChange(of: presenter.leetCodeUsername) { _, _ in
                        presenter.resetValidationState()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(usernameBorderColor, lineWidth: 1)
                    )

                DSButton(
                    presenter.isValidatingUsername ? "Validating..." : "Save & Sync",
                    config: DSButtonConfig(
                        style: .primary,
                        size: .small
                    )
                ) {
                    presenter.validateAndSaveUsername()
                }
                .disabled(presenter.isValidatingUsername || presenter.leetCodeUsername.isEmpty)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.bottom, theme.spacing.md)

            if presenter.usernameValidationState != .none {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: validationIcon)
                        .foregroundColor(validationColor)
                        .font(.system(size: 12))
                    Text(validationMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(validationColor)
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.sm)
            }
        }
    }

    // MARK: - Username Card (Compact)

    private var compactUsernameCard: some View {
        VStack(spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xF3F4F6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x4B5563))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetCode Username")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    TextField("Enter username", text: $presenter.leetCodeUsername)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: presenter.leetCodeUsername) { _, _ in
                            presenter.resetValidationState()
                        }
                }

                Spacer()

                compactValidationIndicator
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)

            Button {
                presenter.validateAndSaveUsername()
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    if presenter.isValidatingUsername {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14))
                    }
                    Text(presenter.isValidatingUsername ? "Validating..." : "Save & Sync")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(hex: 0x6366F1))
                .cornerRadius(theme.radii.md)
            }
            .buttonStyle(.plain)
            .disabled(presenter.isValidatingUsername || presenter.leetCodeUsername.isEmpty)
            .padding(.horizontal, theme.spacing.lg)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(compactUsernameBorderColor, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Notification Row (Regular)

    private var notificationRow: some View {
        HStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.warning.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "bell")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.warning)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(presenter.notificationsAuthorized ? "Authorized" : "Not authorized")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { presenter.settings.studyReminderEnabled },
                set: { newValue in
                    presenter.updateSettings { $0.studyReminderEnabled = newValue }
                }
            ))
            .labelsHidden()
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    private var authorizeNotificationsRow: some View {
        HStack(spacing: theme.spacing.md) {
            Spacer().frame(width: 36)

            DSButton(
                "Request Notification Permission",
                config: DSButtonConfig(style: .secondary, size: .small)
            ) {
                presenter.requestAuthorization()
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 48)
    }

    // MARK: - Notification Card (Compact)

    private var compactNotificationCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xF3F4F6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "bell")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x4B5563))
                }

                Text("Notifications")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { presenter.settings.studyReminderEnabled },
                    set: { newValue in
                        presenter.updateSettings { $0.studyReminderEnabled = newValue }
                    }
                ))
                .labelsHidden()
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)

            if !presenter.notificationsAuthorized {
                Divider().padding(.leading, 64)

                HStack(spacing: theme.spacing.md) {
                    Spacer().frame(width: 36)

                    Button {
                        presenter.requestAuthorization()
                    } label: {
                        Text("Request Permission")
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x6366F1))
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, theme.spacing.lg)
                .frame(height: 44)
            }
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Plan Start Date Row (Regular)

    private var planStartDateRow: some View {
        HStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.success.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.success)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Plan Start Date")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(formattedDate(presenter.planStartDate))
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()

            DatePicker(
                "",
                selection: Binding(
                    get: { presenter.planStartDate },
                    set: { presenter.updatePlanStartDate($0) }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    private var resetStartDateRow: some View {
        HStack(spacing: theme.spacing.md) {
            Spacer().frame(width: 36)

            DSButton(
                "Reset to Today",
                config: DSButtonConfig(style: .ghost, size: .small)
            ) {
                presenter.resetPlanStartDateToToday()
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 44)
    }

    // MARK: - Plan Card (Compact)

    private var compactPlanCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xF3F4F6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x4B5563))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan Start Date")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    Text(formattedDate(presenter.planStartDate))
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }

                Spacer()

                Button {
                    presenter.resetPlanStartDateToToday()
                } label: {
                    Text("Reset to Today")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6366F1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - AI Provider Row (Regular)

    private var aiProviderRow: some View {
        HStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.accent.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "brain")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Provider")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(presenter.aiProviderKind.rawValue)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()

            Picker("", selection: Binding(
                get: { presenter.aiProviderKind },
                set: { presenter.updateAIProvider(kind: $0) }
            )) {
                ForEach(AIProviderKind.allCases, id: \.self) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    private var aiApiKeyRow: some View {
        HStack(spacing: theme.spacing.md) {
            Spacer().frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("API Key")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary)

                SecureField("Enter API key", text: $presenter.aiProviderApiKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .onChange(of: presenter.aiProviderApiKey) { _, _ in
                        presenter.saveAIProviderSettings()
                    }
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.sm)
    }

    private var aiModelRow: some View {
        HStack(spacing: theme.spacing.md) {
            Spacer().frame(width: 36)

            Text("Model")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.colors.textPrimary)

            Spacer()

            Picker("", selection: $presenter.aiProviderModel) {
                ForEach(presenter.aiProviderKind.modelOptions, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: presenter.aiProviderModel) { _, _ in
                presenter.saveAIProviderSettings()
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 48)
    }

    // MARK: - AI Provider Card (Compact)

    private var compactAIProviderCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xF3F4F6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "cpu")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x4B5563))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Provider")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    Text(presenter.aiProviderKind.displayName)
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x9CA3AF))
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)

            Divider()
                .padding(.leading, 64)

            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xF3F4F6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "key")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x4B5563))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("API Key")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    Text(
                        presenter.aiProviderApiKey.isEmpty
                            ? "Not set"
                            : String(repeating: "*", count: min(presenter.aiProviderApiKey.count, 12))
                    )
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x9CA3AF))
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - LeetCode Session Row (Regular)

    private var leetCodeSessionRow: some View {
        HStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.primary.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "key")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("LeetCode Session")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                if presenter.leetCodeAuth != nil {
                    Text("Session active")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.success)
                } else {
                    Text("No session")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Spacer()

            if presenter.leetCodeAuth != nil {
                DSButton(
                    "Clear",
                    config: DSButtonConfig(style: .destructive, size: .small)
                ) {
                    presenter.clearLeetCodeAuth()
                }
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    // MARK: - Session Card (Compact)

    private var compactSessionCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xF3F4F6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "key")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x4B5563))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetCode Session")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    if presenter.leetCodeAuth != nil {
                        Text("Session active")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.success)
                    } else {
                        Text("No session")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }

                Spacer()

                if presenter.leetCodeAuth != nil {
                    Button {
                        presenter.clearLeetCodeAuth()
                    } label: {
                        Text("Clear")
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.colors.danger)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Validation Helpers

    private var compactValidationIndicator: some View {
        Group {
            switch presenter.usernameValidationState {
            case .none:
                EmptyView()
            case .valid:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: 0x059669))
            case .invalid:
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.danger)
            }
        }
    }

    private var compactUsernameBorderColor: Color {
        switch presenter.usernameValidationState {
        case .none: return theme.colors.border
        case .valid: return Color(hex: 0x059669)
        case .invalid: return theme.colors.danger
        }
    }

    private var usernameBorderColor: Color {
        switch presenter.usernameValidationState {
        case .none: return Color.clear
        case .valid: return theme.colors.success
        case .invalid: return theme.colors.danger
        }
    }

    private var validationIcon: String {
        switch presenter.usernameValidationState {
        case .valid: return "checkmark.circle.fill"
        case .invalid: return "xmark.circle.fill"
        case .none: return ""
        }
    }

    private var validationMessage: String {
        switch presenter.usernameValidationState {
        case .valid: return "Username verified and saved"
        case .invalid: return "User not found on LeetCode"
        case .none: return ""
        }
    }

    private var validationColor: Color {
        switch presenter.usernameValidationState {
        case .valid: return theme.colors.success
        case .invalid: return theme.colors.danger
        case .none: return theme.colors.textSecondary
        }
    }

    // MARK: - Date Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
#endif
