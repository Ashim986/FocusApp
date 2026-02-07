import FocusDesignSystem
import SwiftUI

extension TodayView {
    var syncCard: some View {
        DSCard(config: .init(style: .elevated)) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    DSText(L10n.Today.syncTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    DSText(presenter.lastSyncResult.isEmpty
                         ? L10n.Today.syncDefaultStatus
                         : presenter.lastSyncResult)
                        .font(.system(size: 12))
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                if presenter.isSyncing {
                    ProgressView()
                        .scaleEffect(0.9)
                        .tint(theme.colors.primary)
                } else {
                    DSButton(
                        L10n.Today.syncNow,
                        config: .init(style: .primary, size: .small, icon: DSImage(systemName: "arrow.triangle.2.circlepath"))
                    ) {
                        presenter.syncNow()
                    }
                }
            }
        }
    }

    var habitsCard: some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    DSText(L10n.Today.habitsTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    DSText(
                        L10n.Today.habitsCompletedFormat(
                            presenter.habitsCompletedCount,
                            presenter.habits.count
                        )
                    )
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.textSecondary)
                }

                VStack(spacing: 12) {
                    ForEach(presenter.habits) { habit in
                        habitRow(habit)
                    }
                }
            }
        }
    }

    func habitRow(_ habit: HabitViewModel) -> some View {
        DSButton(action: {
            presenter.toggleHabit(habit.id)
        }, label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(habit.isCompleted ? theme.colors.success.opacity(0.12) : theme.colors.surfaceElevated)
                        .frame(width: 36, height: 36)

                    DSImage(systemName: habit.icon)
                        .font(.system(size: 14))
                        .foregroundColor(habit.isCompleted ? theme.colors.success : theme.colors.textSecondary)
                }

                DSText(habit.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(habit.isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary)
                    .strikethrough(habit.isCompleted, color: theme.colors.textSecondary)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(habit.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(habit.isCompleted ? theme.colors.success : Color.clear)
                        )

                    if habit.isCompleted {
                        DSImage(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(habit.isCompleted ? theme.colors.success.opacity(0.15) : theme.colors.surface)
            )
        })
        .buttonStyle(.plain)
    }

    func dayCard(day: TodayDayViewModel) -> some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        if day.isToday {
                            Circle()
                                .fill(theme.colors.primary)
                                .frame(width: 32, height: 32)

                            DSText("\(day.id)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(theme.colors.surfaceElevated)
                                .frame(width: 32, height: 32)

                            DSText(L10n.Today.dayBadge( day.id))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.colors.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        DSText(day.isToday
                             ? L10n.Today.dayTitleToday( day.topic)
                             : L10n.Today.dayTitleBacklog( day.topic))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)

                        DSText(L10n.Today.dayCompletedFormat( day.completedCount, day.totalCount))
                            .font(.system(size: 13))
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()
                }

                Divider()

                VStack(spacing: 0) {
                    ForEach(day.problems) { problem in
                        ProblemRow(
                            problem: problem.problem,
                            isCompleted: problem.isCompleted,
                            onToggle: {
                                presenter.toggleProblem(day: day.id, problemIndex: problem.index)
                            },
                            onSelect: {
                                onSelectProblem(problem.problem, day.id, problem.index)
                            }
                        )

                        if problem.index < day.problems.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }
}
