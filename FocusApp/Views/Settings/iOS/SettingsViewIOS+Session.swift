#if os(iOS)
// SettingsViewIOS+Session.swift
// FocusApp -- LeetCode session section.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - LeetCode Session Row (Regular)

    var leetCodeSessionRow: some View {
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

    var compactSessionCard: some View {
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
}

#endif
