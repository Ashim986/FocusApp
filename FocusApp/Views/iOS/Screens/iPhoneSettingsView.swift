#if os(iOS)
// iPhoneSettingsView.swift
// FocusApp -- iPhone Settings screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneSettingsView: View {
    @Environment(\.dsTheme) var theme

    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    // Title
                    Text("Settings")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // LEETCODE section
                    Text("LEETCODE")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    VStack(spacing: theme.spacing.md) {
                        // Username field
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

                            // Validation status
                            validationIndicator
                        }
                        .padding(.horizontal, theme.spacing.lg)
                        .padding(.vertical, theme.spacing.md)

                        // Save button
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
                            .stroke(usernameFieldBorderColor, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, theme.spacing.lg)

                    // PLAN section
                    Text("PLAN")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    VStack(spacing: 0) {
                        // Plan start date
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

                        Divider()
                            .padding(.leading, 64)

                        // Notifications
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
                    }
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, theme.spacing.lg)

                    // AI PROVIDER section
                    Text("AI PROVIDER")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

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

                        // API Key (masked)
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
                    .padding(.horizontal, theme.spacing.lg)
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

    // MARK: - Header Bar

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

    // MARK: - Validation Indicator

    private var validationIndicator: some View {
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

    private var usernameFieldBorderColor: Color {
        switch presenter.usernameValidationState {
        case .none: return theme.colors.border
        case .valid: return Color(hex: 0x059669)
        case .invalid: return theme.colors.danger
        }
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
#endif
