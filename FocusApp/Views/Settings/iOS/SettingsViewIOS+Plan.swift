#if os(iOS)
// SettingsViewIOS+Plan.swift
// FocusApp -- Study plan section.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - Plan Start Date Row (Regular)

    var planStartDateRow: some View {
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

    var resetStartDateRow: some View {
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

    var compactPlanCard: some View {
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

    // MARK: - Date Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#endif
