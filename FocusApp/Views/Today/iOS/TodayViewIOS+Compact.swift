#if os(iOS)
// TodayViewIOS+Compact.swift
// FocusApp -- iPhone (compact) layout.

import FocusDesignSystem
import SwiftUI

extension TodayViewIOS {

    // MARK: - Compact Layout (iPhone)

    var compactLayout: some View {
        VStack(spacing: 0) {
            compactHeaderBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    // Date label
                    Text(formattedDateUppercased)
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    // Title
                    Text("Today")
                        .font(theme.typography.title)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Streak badge
                    compactStreakBadge
                        .padding(.horizontal, theme.spacing.lg)

                    // Daily Goal Card
                    compactDailyGoalCard
                        .padding(.horizontal, theme.spacing.lg)

                    // Habits section
                    compactHabitsSection
                        .padding(.horizontal, theme.spacing.lg)

                    // Start Focus CTA
                    compactStartFocusCTA
                        .padding(.horizontal, theme.spacing.lg)

                    // Today's Plan header with sync
                    HStack {
                        Text("Today's Plan")
                            .font(theme.typography.subtitle)
                            .foregroundColor(theme.colors.textPrimary)

                        Spacer()

                        if presenter.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Button {
                                presenter.syncNow()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14))
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.sm)

                    // Sync status
                    if !presenter.lastSyncResult.isEmpty {
                        Text(presenter.lastSyncResult)
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))
                            .padding(.horizontal, theme.spacing.lg)
                    }

                    // Problem rows for today
                    if let today = todayDay {
                        VStack(spacing: 0) {
                            ForEach(
                                Array(today.problems.enumerated()),
                                id: \.element.id
                            ) { index, problemVM in
                                if index > 0 {
                                    Divider().padding(.leading, 52)
                                }
                                TaskRow(
                                    title: problemVM.problem.name,
                                    subtitle: problemVM.problem.leetcodeNumber.map { "LeetCode #\($0)" },
                                    isCompleted: problemVM.isCompleted,
                                    difficulty: problemVM.problem.difficulty,
                                    theme: theme,
                                    onTap: {
                                        if let url = URL(string: problemVM.problem.url) {
                                            openURL(url)
                                        }
                                    }
                                )
                            }
                        }
                        .background(theme.colors.surface)
                        .cornerRadius(theme.radii.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.md)
                                .stroke(theme.colors.border, lineWidth: 1)
                        )
                        .padding(.horizontal, theme.spacing.lg)
                    }

                    // Carryover days
                    ForEach(carryoverDays) { day in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Text("Day \(day.id): \(day.topic)")
                                .font(theme.typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: 0xEA580C))
                                .padding(.horizontal, theme.spacing.lg)

                            VStack(spacing: 0) {
                                ForEach(
                                    Array(day.problems.enumerated()),
                                    id: \.element.id
                                ) { index, problemVM in
                                    if index > 0 {
                                        Divider().padding(.leading, 52)
                                    }
                                    TaskRow(
                                        title: problemVM.problem.name,
                                        subtitle: problemVM.problem.leetcodeNumber.map { "LeetCode #\($0)" },
                                        isCompleted: problemVM.isCompleted,
                                        difficulty: problemVM.problem.difficulty,
                                        theme: theme,
                                        onTap: {
                                            if let url = URL(string: problemVM.problem.url) {
                                                openURL(url)
                                            }
                                        }
                                    )
                                }
                            }
                            .background(theme.colors.surface)
                            .cornerRadius(theme.radii.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radii.md)
                                    .stroke(theme.colors.border, lineWidth: 1)
                            )
                            .padding(.horizontal, theme.spacing.lg)
                        }
                    }
                }
                .padding(.top, theme.spacing.lg)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Compact Header Bar

    private var compactHeaderBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button {
                onSettingsTap()
            } label: {
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

    // MARK: - Compact Streak Badge

    private var compactStreakBadge: some View {
        let habitsCount = presenter.habitsCompletedCount
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xEA580C))

            Text("\(habitsCount)/3 Habits Today")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: 0xEA580C))
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(Color(hex: 0xFFF7ED))
        .cornerRadius(theme.radii.pill)
        .overlay(
            Capsule()
                .stroke(Color(hex: 0xFDBA74), lineWidth: 1)
        )
    }

    // MARK: - Compact Daily Goal Card

    private var compactDailyGoalCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "target")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                Text("Daily Goal")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(completedCount)/\(totalCount)")
                    .font(theme.typography.title)
                    .foregroundColor(.white)

                Text("Problems completed")
                    .font(theme.typography.body)
                    .foregroundColor(.white.opacity(0.8))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: totalCount > 0
                                ? geo.size.width * CGFloat(completedCount) / CGFloat(totalCount)
                                : 0,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(theme.radii.lg)
    }

    // MARK: - Compact Habits Section

    private var compactHabitsSection: some View {
        HStack(spacing: theme.spacing.md) {
            ForEach(presenter.habits) { habit in
                Button {
                    presenter.toggleHabit(habit.id)
                } label: {
                    VStack(spacing: theme.spacing.xs) {
                        ZStack {
                            Circle()
                                .fill(habit.isCompleted ? Color(hex: 0xD1FAE5) : Color(hex: 0xF3F4F6))
                                .frame(width: 40, height: 40)
                            Image(systemName: habit.icon)
                                .font(.system(size: 18))
                                .foregroundColor(habit.isCompleted ? theme.colors.success : Color(hex: 0x6B7280))
                        }

                        Text(habit.title)
                            .font(theme.typography.caption)
                            .foregroundColor(habit.isCompleted ? theme.colors.success : Color(hex: 0x6B7280))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacing.md)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(
                                habit.isCompleted
                                    ? theme.colors.success.opacity(0.3)
                                    : theme.colors.border,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Compact Start Focus CTA

    private var compactStartFocusCTA: some View {
        Button {
            onStartFocus()
        } label: {
            VStack(spacing: theme.spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x6366F1).opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: 0x6366F1))
                }

                Text("Start Focus Session")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Ready to get in the zone?")
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
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
        .buttonStyle(.plain)
    }
}

#endif
