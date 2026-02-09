#if os(iOS)
// SettingsViewIOS+Notifications.swift
// FocusApp -- Notifications section.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - Notification Row (Regular)

    var notificationRow: some View {
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

    var authorizeNotificationsRow: some View {
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

    var compactNotificationCard: some View {
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
}

#endif
