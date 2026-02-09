#if os(iOS)
// TodayViewIOS+Rows.swift
// FocusApp -- Shared row components used by TodayViewIOS layouts.

import FocusDesignSystem
import SwiftUI

struct TaskRow: View {
    var title: String
    var subtitle: String?
    var isCompleted: Bool = false
    var difficulty: Difficulty?
    var isCarryover: Bool = false
    var theme: DSTheme
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Check icon
                if isCompleted {
                    ZStack {
                        Circle()
                            .fill(theme.colors.primary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .strokeBorder(
                            isCarryover ? theme.colors.warning : theme.colors.border,
                            style: StrokeStyle(lineWidth: 1.5, dash: [3])
                        )
                        .frame(width: 24, height: 24)
                }

                // Title + Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary)
                        .strikethrough(isCompleted)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }

                Spacer()

                // Difficulty badge
                if let difficulty {
                    DSBadge(
                        difficulty.rawValue,
                        config: DSBadgeConfig(
                            style: DifficultyBadgeHelper.badgeStyle(for: difficulty)
                        )
                    )
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }
}

struct RegularHabitRow: View {
    let habit: HabitViewModel
    let theme: DSTheme
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                if habit.isCompleted {
                    ZStack {
                        Circle()
                            .fill(theme.colors.success)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .strokeBorder(
                            theme.colors.border,
                            style: StrokeStyle(lineWidth: 1.5)
                        )
                        .frame(width: 24, height: 24)
                }

                Image(systemName: habit.icon)
                    .font(.system(size: 14))
                    .foregroundColor(habit.isCompleted ? theme.colors.success : theme.colors.textSecondary)

                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(habit.isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary)
                    .strikethrough(habit.isCompleted)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }
}

#endif
