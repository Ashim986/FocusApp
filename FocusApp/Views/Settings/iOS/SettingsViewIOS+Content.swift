#if os(iOS)
// SettingsViewIOS+Content.swift
// FocusApp -- Shared settings content for iPhone and iPad.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - Settings Content (Shared)

    @ViewBuilder
    var settingsContent: some View {
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
}

#endif
