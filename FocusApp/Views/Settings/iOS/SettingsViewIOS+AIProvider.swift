#if os(iOS)
// SettingsViewIOS+AIProvider.swift
// FocusApp -- AI provider settings section.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - AI Provider Row (Regular)

    var aiProviderRow: some View {
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

    var aiApiKeyRow: some View {
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

    var aiModelRow: some View {
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

    var compactAIProviderCard: some View {
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
}

#endif
