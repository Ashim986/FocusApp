#if os(iOS)
// iPadPlanView.swift
// FocusApp -- iPad Plan screen (two-column layout)
// Wired to PlanPresenter for live data

import FocusDesignSystem
import SwiftUI

struct iPadPlanView: View {
    @ObservedObject var presenter: PlanPresenter
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    @State private var selectedDayId: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            // Title + Sync
            HStack {
                Text("Study Plan")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                if !presenter.lastSyncResult.isEmpty {
                    Text(presenter.lastSyncResult)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.colors.textSecondary)
                }

                DSButton(
                    "Sync",
                    config: DSButtonConfig(
                        style: .secondary,
                        size: .small,
                        icon: Image(systemName: "arrow.clockwise")
                    )
                ) {
                    presenter.syncNow()
                }
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, theme.spacing.xl)

            // Two-column layout
            HStack(alignment: .top, spacing: theme.spacing.md) {
                // Left column: Day list
                dayListColumn

                // Right column: Day detail
                dayDetailColumn
            }
            .padding(.horizontal, theme.spacing.xl)

            Spacer()
        }
    }

    // MARK: - Day List Column

    private var dayListColumn: some View {
        ScrollView {
            VStack(spacing: theme.spacing.sm) {
                ForEach(presenter.days) { day in
                    iPadPlanDayRow(
                        day: day,
                        isSelected: selectedDayId == day.id,
                        theme: theme,
                        onTap: { selectedDayId = day.id }
                    )
                }
            }
            .padding(theme.spacing.sm)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .frame(maxWidth: 280)
    }

    // MARK: - Day Detail Column

    private var dayDetailColumn: some View {
        Group {
            if let dayId = selectedDayId,
               let day = presenter.days.first(where: { $0.id == dayId }) {
                dayDetail(for: day)
            } else if let firstDay = presenter.days.first {
                dayDetail(for: firstDay)
                    .onAppear { selectedDayId = firstDay.id }
            } else {
                emptyDetail
            }
        }
    }

    private func dayDetail(for day: PlanDayViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                // Day header
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Day \(day.id) - \(day.topic)")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)

                        Text(day.date)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    // Progress badge
                    DSBadge(
                        "\(day.completedCount)/\(day.problems.count)",
                        style: day.isFullyCompleted ? .success : .neutral
                    )
                }

                // Progress bar
                GeometryReader { geo in
                    let progress = day.problems.isEmpty
                        ? 0.0
                        : CGFloat(day.completedCount) / CGFloat(day.problems.count)
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.colors.border)
                            .frame(height: 6)
                        Capsule()
                            .fill(day.isFullyCompleted ? theme.colors.success : theme.colors.primary)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)

                // Problem list
                VStack(spacing: 0) {
                    ForEach(Array(day.problems.enumerated()), id: \.element.id) { offset, problem in
                        iPadPlanProblemRow(
                            problem: problem,
                            theme: theme,
                            onTap: {
                                if let url = URL(string: problem.problem.url) {
                                    openURL(url)
                                }
                            }
                        )

                        if offset < day.problems.count - 1 {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .background(theme.colors.surface)
                .cornerRadius(theme.radii.md)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.md)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    private var emptyDetail: some View {
        VStack {
            Spacer()
            Text("No plan data available")
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Plan Day Row

private struct iPadPlanDayRow: View {
    let day: PlanDayViewModel
    let isSelected: Bool
    let theme: DSTheme
    let onTap: () -> Void

    var body: some View {
        DSActionButton(action: onTap) {
            HStack(spacing: theme.spacing.md) {
                // Day number circle
                ZStack {
                    Circle()
                        .fill(
                            day.isFullyCompleted
                                ? theme.colors.success
                                : isSelected
                                    ? theme.colors.primary
                                    : theme.colors.border
                        )
                        .frame(width: 32, height: 32)

                    if day.isFullyCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(day.id)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(
                                isSelected ? .white : theme.colors.textPrimary
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(day.topic)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    Text("\(day.completedCount)/\(day.problems.count) problems")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                Text(day.date)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(
                isSelected
                    ? theme.colors.primary.opacity(0.08)
                    : Color.clear
            )
            .cornerRadius(theme.radii.sm)
        }
    }
}

// MARK: - Plan Problem Row

private struct iPadPlanProblemRow: View {
    let problem: PlanProblemViewModel
    let theme: DSTheme
    let onTap: () -> Void

    var body: some View {
        DSActionButton(action: onTap) {
            HStack(spacing: 12) {
                // Status icon
                if problem.isCompleted {
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
                        .strokeBorder(theme.colors.border, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }

                // Problem name
                Text(problem.problem.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(
                        problem.isCompleted
                            ? theme.colors.textSecondary
                            : theme.colors.textPrimary
                    )
                    .strikethrough(problem.isCompleted)

                Spacer()

                // Difficulty
                DSBadge(
                    problem.problem.difficulty.rawValue,
                    style: badgeStyle(for: problem.problem.difficulty)
                )

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 52)
        }
    }

    private func badgeStyle(for difficulty: Difficulty) -> DSBadgeStyle {
        switch difficulty {
        case .easy: return .success
        case .medium: return .warning
        case .hard: return .danger
        }
    }
}
#endif
