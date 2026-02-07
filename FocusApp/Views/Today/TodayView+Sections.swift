import FocusDesignSystem
import SwiftUI

extension TodayView {
    var syncCard: some View {
        DSCard(config: .init(style: .elevated)) {
            HStack(spacing: DSLayout.spacing(.space16)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                    Text(L10n.Today.syncTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Text(presenter.lastSyncResult.isEmpty
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
                        config: .init(style: .primary, size: .small, icon: Image(systemName: "arrow.triangle.2.circlepath"))
                    ) {
                        presenter.syncNow()
                    }
                }
            }
        }
    }

    var habitsCard: some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                HStack {
                    Text(L10n.Today.habitsTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Text(
                        L10n.Today.habitsCompletedFormat(
                            presenter.habitsCompletedCount,
                            presenter.habits.count
                        )
                    )
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.textSecondary)
                }

                VStack(spacing: DSLayout.spacing(.space12)) {
                    ForEach(presenter.habits) { habit in
                        habitRow(habit)
                    }
                }
            }
        }
    }

    func habitRow(_ habit: HabitViewModel) -> some View {
        DSActionButton(action: {
            presenter.toggleHabit(habit.id)
        }) {
            HStack(spacing: DSLayout.spacing(.space12)) {
                ZStack {
                    Circle()
                        .fill(habit.isCompleted ? theme.colors.success.opacity(0.12) : theme.colors.surfaceElevated)
                        .frame(width: 36, height: 36)

                    Image(systemName: habit.icon)
                        .font(.system(size: 14))
                        .foregroundColor(habit.isCompleted ? theme.colors.success : theme.colors.textSecondary)
                }

                Text(habit.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(habit.isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary)
                    .strikethrough(habit.isCompleted, color: theme.colors.textSecondary)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: DSLayout.spacing(.space4))
                        .strokeBorder(habit.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: DSLayout.spacing(.space4))
                                .fill(habit.isCompleted ? theme.colors.success : Color.clear)
                        )

                    if habit.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(DSLayout.spacing(.space12))
            .background(
                RoundedRectangle(cornerRadius: DSLayout.spacing(.space8))
                    .fill(habit.isCompleted ? theme.colors.success.opacity(0.15) : theme.colors.surface)
            )
        }
    }

    func dayCard(day: TodayDayViewModel) -> some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                HStack {
                    ZStack {
                        if day.isToday {
                            Circle()
                                .fill(theme.colors.primary)
                                .frame(width: 32, height: 32)

                            Text("\(day.id)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            RoundedRectangle(cornerRadius: DSLayout.spacing(6))
                                .fill(theme.colors.surfaceElevated)
                                .frame(width: 32, height: 32)

                            Text(L10n.Today.dayBadge( day.id))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.colors.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                        Text(day.isToday
                             ? L10n.Today.dayTitleToday( day.topic)
                             : L10n.Today.dayTitleBacklog( day.topic))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)

                        Text(L10n.Today.dayCompletedFormat( day.completedCount, day.totalCount))
                            .font(.system(size: 13))
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()
                }

                Divider()

                VStack(spacing: DSLayout.spacing(0)) {
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
                                .padding(.leading, DSLayout.spacing(44))
                        }
                    }
                }
            }
        }
    }
}
