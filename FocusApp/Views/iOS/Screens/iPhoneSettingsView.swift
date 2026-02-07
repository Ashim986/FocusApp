// iPhoneSettingsView.swift
// FocusApp -- iPhone Settings screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneSettingsView: View {
    @Environment(\.dsTheme) var theme

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

                    // ACCOUNT section
                    Text("ACCOUNT")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    VStack(spacing: 0) {
                        settingsRow(
                            iconName: "person",
                            title: "Profile",
                            subtitle: "John Doe"
                        )

                        Divider()
                            .padding(.leading, 64)

                        settingsRow(
                            iconName: "shield",
                            title: "Security",
                            subtitle: "Password, 2FA"
                        )
                    }
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, theme.spacing.lg)

                    // PREFERENCES section
                    Text("PREFERENCES")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    VStack(spacing: 0) {
                        settingsRow(
                            iconName: "bell",
                            title: "Notifications",
                            statusText: "On"
                        )

                        Divider()
                            .padding(.leading, 64)

                        settingsRow(
                            iconName: "moon",
                            title: "Appearance",
                            statusText: "Light"
                        )
                    }
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, theme.spacing.lg)

                    // Sign Out
                    signOutButton
                        .padding(.horizontal, theme.spacing.lg)
                        .padding(.top, theme.spacing.sm)
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
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
        .overlay(alignment: .trailing) {
            Button { } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.trailing, theme.spacing.lg)
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Settings Row

    private func settingsRow(
        iconName: String,
        title: String,
        subtitle: String? = nil,
        statusText: String? = nil
    ) -> some View {
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
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
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
                    .font(theme.typography.body)
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

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button { } label: {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text("Sign Out")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(theme.colors.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color(hex: 0xFEE2E2))
            .cornerRadius(theme.radii.md)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    iPhoneSettingsView()
}
