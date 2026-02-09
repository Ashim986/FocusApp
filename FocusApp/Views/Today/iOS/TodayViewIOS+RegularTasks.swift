#if os(iOS)
// TodayViewIOS+RegularTasks.swift
// FocusApp -- iPad (regular) plan lists and carryover sections.

import FocusDesignSystem
import SwiftUI

extension TodayViewIOS {

    // MARK: - Regular Task List

    func regularTaskList(for day: TodayDayViewModel) -> some View {
        VStack(spacing: 0) {
            ForEach(
                Array(day.problems.enumerated()),
                id: \.element.id
            ) { offset, problemVM in
                TaskRow(
                    title: problemVM.problem.name,
                    subtitle: day.topic,
                    isCompleted: problemVM.isCompleted,
                    difficulty: problemVM.problem.difficulty,
                    isCarryover: false,
                    theme: theme,
                    onTap: {
                        if let url = URL(string: problemVM.problem.url) {
                            openURL(url)
                        }
                    }
                )
                if offset < day.problems.count - 1 {
                    Divider().padding(.leading, 52)
                }
            }

            // Habits section in task list (iPad style)
            if !presenter.habits.isEmpty {
                Divider().padding(.leading, 52)
                ForEach(presenter.habits) { habit in
                    RegularHabitRow(
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

    // MARK: - Regular Carryover Section

    func regularCarryoverSection(for day: TodayDayViewModel) -> some View {
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
                ForEach(
                    Array(day.problems.enumerated()),
                    id: \.element.id
                ) { offset, problemVM in
                    TaskRow(
                        title: problemVM.problem.name,
                        subtitle: day.topic,
                        isCompleted: problemVM.isCompleted,
                        difficulty: problemVM.problem.difficulty,
                        isCarryover: true,
                        theme: theme,
                        onTap: {
                            if let url = URL(string: problemVM.problem.url) {
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

#endif
