#if os(iOS)
// iPadTodayView.swift
// FocusApp -- iPad Today screen
// Wired to TodayPresenter for live data

import FocusDesignSystem
import SwiftUI

struct iPadTodayView: View {
    @ObservedObject var presenter: TodayPresenter
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                headerSection
                cardStrip
                planHeader

                if let todayDay = presenter.visibleDays.first(where: { $0.isToday }) {
                    taskList(for: todayDay)
                }

                // Carryover days (past days with unsolved problems)
                ForEach(presenter.visibleDays.filter({ !$0.isToday })) { day in
                    carryoverSection(for: day)
                }
            }
            .padding(.bottom, 48)
        }
        .onAppear {
            presenter.syncNow()
        }
    }

    // MARK: - Current Day Info

    private var currentDay: TodayDayViewModel? {
        presenter.visibleDays.first(where: { $0.isToday })
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(formattedDate)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)

                Text(currentDay?.topic ?? "Study Plan")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
            }

            Spacer()

            // Sync status
            if !presenter.lastSyncResult.isEmpty {
                Text(presenter.lastSyncResult)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.pill)
            }
        }
        .padding(.horizontal, theme.spacing.xl)
        .padding(.top, theme.spacing.xl)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date()).uppercased()
    }

    // MARK: - Card Strip

    private var cardStrip: some View {
        HStack(spacing: theme.spacing.md) {
            dailyGoalCard
            habitsCard
            syncCard
        }
        .frame(height: 120)
        .padding(.horizontal, theme.spacing.xl)
    }

    private var dailyGoalCard: some View {
        let completed = currentDay?.completedCount ?? 0
        let total = currentDay?.totalCount ?? 0
        let progress: CGFloat = total > 0 ? CGFloat(completed) / CGFloat(total) : 0

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.white)
                Text("Daily Goal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text("\(completed)/\(total)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text("Tasks done")
                .font(theme.typography.caption)
                .foregroundColor(.white.opacity(0.8))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(theme.spacing.lg)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(theme.radii.md)
    }

    private var habitsCard: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(theme.colors.success)
                    Text("Habits")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
                Text("\(presenter.habitsCompletedCount)/\(presenter.habits.count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("Completed today")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
    }

    private var syncCard: some View {
        DSActionButton(
            isEnabled: !presenter.isSyncing,
            action: { presenter.syncNow() }
        ) {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: presenter.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.colors.primary)
                    .rotationEffect(presenter.isSyncing ? .degrees(360) : .zero)
                    .animation(
                        presenter.isSyncing
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: presenter.isSyncing
                    )
                Text("Sync LeetCode")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("Fetch progress")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.surface)
            .cornerRadius(theme.radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.md)
                    .strokeBorder(
                        theme.colors.border,
                        style: StrokeStyle(lineWidth: 1, dash: [4])
                    )
            )
        }
    }

    // MARK: - Plan Header

    private var planHeader: some View {
        HStack {
            Text("Today's Plan")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)

            if let day = currentDay {
                Text("Day \(day.id)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.xl)
    }

    // MARK: - Task List

    private func taskList(for day: TodayDayViewModel) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(day.problems.enumerated()), id: \.element.id) { offset, problem in
                iPadTaskRow(
                    title: problem.problem.name,
                    subtitle: day.topic,
                    isCompleted: problem.isCompleted,
                    difficulty: problem.problem.difficulty,
                    theme: theme,
                    onTap: {
                        if let url = URL(string: problem.problem.url) {
                            openURL(url)
                        }
                    }
                )
                if offset < day.problems.count - 1 {
                    Divider().padding(.leading, 52)
                }
            }

            // Habits section
            if !presenter.habits.isEmpty {
                Divider().padding(.leading, 52)
                ForEach(presenter.habits) { habit in
                    iPadHabitRow(
                        habit: habit,
                        theme: theme,
                        onToggle: { presenter.toggleHabit(habit.id) }
                    )
                }
            }
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .padding(.horizontal, theme.spacing.xl)
    }

    // MARK: - Carryover Section

    private func carryoverSection(for day: TodayDayViewModel) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Text("Day \(day.id) - \(day.topic)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.warning)
                Text("(\(day.problems.count) carryover)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.warning)
            }
            .padding(.horizontal, theme.spacing.xl)

            VStack(spacing: 0) {
                ForEach(Array(day.problems.enumerated()), id: \.element.id) { offset, problem in
                    iPadTaskRow(
                        title: problem.problem.name,
                        subtitle: day.topic,
                        isCompleted: problem.isCompleted,
                        difficulty: problem.problem.difficulty,
                        isCarryover: true,
                        theme: theme,
                        onTap: {
                            if let url = URL(string: problem.problem.url) {
                                openURL(url)
                            }
                        }
                    )
                    if offset < day.problems.count - 1 {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(theme.colors.surface)
            .cornerRadius(theme.radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.md)
                    .stroke(theme.colors.warning.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, theme.spacing.xl)
        }
    }
}

// MARK: - Task Row

private struct iPadTaskRow: View {
    var title: String
    var subtitle: String?
    var isCompleted: Bool = false
    var difficulty: Difficulty?
    var isCarryover: Bool = false
    var theme: DSTheme
    var onTap: (() -> Void)?

    var body: some View {
        DSActionButton(action: { onTap?() }) {
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
                        .foregroundColor(
                            isCompleted
                                ? theme.colors.textSecondary
                                : theme.colors.textPrimary
                        )
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
                        style: badgeStyle(for: difficulty)
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
    }

    private func badgeStyle(for difficulty: Difficulty) -> DSBadgeStyle {
        switch difficulty {
        case .easy: return .success
        case .medium: return .warning
        case .hard: return .danger
        }
    }
}

// MARK: - Habit Row

private struct iPadHabitRow: View {
    let habit: HabitViewModel
    let theme: DSTheme
    let onToggle: () -> Void

    var body: some View {
        DSActionButton(action: onToggle) {
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
                    .foregroundColor(
                        habit.isCompleted ? theme.colors.success : theme.colors.textSecondary
                    )

                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        habit.isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary
                    )
                    .strikethrough(habit.isCompleted)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
    }
}
#endif
