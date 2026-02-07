// MacSettingsView.swift
// FocusApp -- Mac Settings screen (centered form, max 600px)

import FocusDesignSystem
import SwiftUI

struct MacSettingsView: View {
    @Environment(\.dsTheme) var theme

    @State private var leetCodeUsername = "ashim986"
    @State private var selectedProvider = "Groq"
    @State private var apiKey = ""
    @State private var selectedModel = "llama-3.3-70b"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                Text("Settings")
                    .font(theme.typography.title)
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.top, theme.spacing.xl)

                // ACCOUNT section
                macSettingsSection(title: "ACCOUNT") {
                    VStack(spacing: 0) {
                        macSettingsRow(
                            iconName: "person",
                            title: "Profile",
                            subtitle: "John Doe"
                        )
                        Divider().padding(.leading, 64)
                        macSettingsRow(
                            iconName: "shield",
                            title: "Security",
                            subtitle: "Password, 2FA"
                        )
                    }
                }

                // PREFERENCES section
                macSettingsSection(title: "PREFERENCES") {
                    VStack(spacing: 0) {
                        macSettingsRow(
                            iconName: "bell",
                            title: "Notifications",
                            statusText: "On"
                        )
                        Divider().padding(.leading, 64)
                        macSettingsRow(
                            iconName: "moon",
                            title: "Appearance",
                            statusText: "Light"
                        )
                    }
                }

                // LEETCODE section
                macSettingsSection(title: "LEETCODE") {
                    VStack(spacing: theme.spacing.md) {
                        // Username field
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Text("LeetCode Username")
                                .font(theme.typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.colors.textPrimary)

                            HStack(spacing: theme.spacing.sm) {
                                DSTextField(
                                    placeholder: "Enter username",
                                    text: $leetCodeUsername
                                )
                                .frame(maxWidth: .infinity)

                                DSButton(
                                    "Save & Sync",
                                    config: DSButtonConfig(style: .primary, size: .medium)
                                ) { }
                            }
                        }

                        // Sync status
                        HStack(spacing: theme.spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: 0x10B981))
                                .font(.system(size: 14))
                            Text("Last synced: 5 minutes ago")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)

                            Spacer()

                            Text("45 problems synced")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                    }
                    .padding(theme.spacing.lg)
                }

                // AI SETTINGS section
                macSettingsSection(title: "AI SETTINGS") {
                    VStack(spacing: theme.spacing.md) {
                        // Provider
                        HStack(spacing: theme.spacing.md) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text("Provider")
                                    .font(theme.typography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.colors.textPrimary)

                                macPickerButton(
                                    selected: selectedProvider,
                                    options: ["Groq", "Gemini", "OpenAI"]
                                ) { selectedProvider = $0 }
                            }

                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text("Model")
                                    .font(theme.typography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.colors.textPrimary)

                                macPickerButton(
                                    selected: selectedModel,
                                    options: ["llama-3.3-70b", "gemma-7b", "mixtral-8x7b"]
                                ) { selectedModel = $0 }
                            }
                        }

                        // API Key
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text("API Key")
                                .font(theme.typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.colors.textPrimary)

                            DSTextField(
                                placeholder: "Enter API key",
                                text: $apiKey,
                                config: DSTextFieldConfig(isSecure: true)
                            )
                        }
                    }
                    .padding(theme.spacing.lg)
                }

                // Sign Out
                macSignOutButton
                    .padding(.top, theme.spacing.sm)
            }
            .frame(maxWidth: 600)
            .padding(.horizontal, theme.spacing.xl)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 48)
        }
        .background(theme.colors.background)
    }

    // MARK: - Settings Section

    private func macSettingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textSecondary)
                .textCase(.uppercase)

            content()
                .background(theme.colors.surface)
                .cornerRadius(theme.radii.md)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.md)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }

    // MARK: - Settings Row

    private func macSettingsRow(
        iconName: String,
        title: String,
        subtitle: String? = nil,
        statusText: String? = nil
    ) -> some View {
        HStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.surfaceElevated)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Spacer()

            if let statusText {
                Text(statusText)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x9CA3AF))
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    // MARK: - Picker Button

    private func macPickerButton(
        selected: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        DSSelect(
            placeholder: "Select",
            items: options.map { DSSelectItem(id: $0, title: $0) },
            state: DSSelectState(selectedId: selected)
        ) { item in
            onSelect(item.id)
        }
    }

    // MARK: - Sign Out Button

    private var macSignOutButton: some View {
        DSButton(
            "Sign Out",
            config: DSButtonConfig(
                style: .destructive,
                size: .large,
                icon: Image(systemName: "rectangle.portrait.and.arrow.right")
            )
        ) { }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Mac Settings") {
    MacSettingsView()
        .frame(width: 1200, height: 760)
}
