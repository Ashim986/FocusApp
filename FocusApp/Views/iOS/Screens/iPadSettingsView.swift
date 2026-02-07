// iPadSettingsView.swift
// FocusApp — iPad Settings screen
// Spec: FIGMA_SETUP_GUIDE.md §5.6

import FocusDesignSystem
import SwiftUI

struct iPadSettingsView: View {
    @Environment(\.dsTheme) var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                // Title
                Text("Settings")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.top, theme.spacing.xl)

                // ACCOUNT section
                Text("ACCOUNT")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6B7280))
                    .textCase(.uppercase)

                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        iPadSettingsRowView(
                            iconName: "person",
                            title: "Profile",
                            subtitle: "John Doe",
                            theme: theme
                        )
                        Divider().padding(.leading, 64)
                        iPadSettingsRowView(
                            iconName: "shield",
                            title: "Security",
                            subtitle: "Password, 2FA",
                            theme: theme
                        )
                    }
                }

                // PREFERENCES section
                Text("PREFERENCES")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6B7280))
                    .textCase(.uppercase)

                DSCard(config: DSCardConfig(style: .outlined, padding: 0)) {
                    VStack(spacing: 0) {
                        iPadSettingsRowView(
                            iconName: "bell",
                            title: "Notifications",
                            statusText: "On",
                            theme: theme
                        )
                        Divider().padding(.leading, 64)
                        iPadSettingsRowView(
                            iconName: "moon",
                            title: "Appearance",
                            statusText: "Light",
                            theme: theme
                        )
                    }
                }

                // Sign Out
                signOutButton
                    .padding(.top, theme.spacing.sm)
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, theme.spacing.xl)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button { } label: {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text("Sign Out")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(theme.colors.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(theme.colors.danger.opacity(0.1))
            .cornerRadius(theme.radii.md)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings Row

private struct iPadSettingsRowView: View {
    var iconName: String
    var title: String
    var subtitle: String?
    var statusText: String?
    var theme: DSTheme

    var body: some View {
        HStack(spacing: theme.spacing.md) {
            // Icon in circle
            ZStack {
                Circle()
                    .fill(Color(hex: 0xF3F4F6))
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0x4B5563))
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }
            }

            Spacer()

            if let statusText {
                Text(statusText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x9CA3AF))
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }
}

#Preview {
    iPadSettingsView()
        .frame(width: 574, height: 1194)
}
