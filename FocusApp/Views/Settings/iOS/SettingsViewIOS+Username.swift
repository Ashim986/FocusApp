#if os(iOS)
// SettingsViewIOS+Username.swift
// FocusApp -- LeetCode username section.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - Username Row (Regular)

    var usernameRow: some View {
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

    var compactUsernameCard: some View {
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
}

#endif
