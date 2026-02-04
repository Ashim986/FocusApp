import SwiftUI

extension TodayView {
    var syncCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("LeetCode Sync")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Text(presenter.lastSyncResult.isEmpty ? "Keep your progress up to date." : presenter.lastSyncResult)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }

            Spacer()

            if presenter.isSyncing {
                ProgressView()
                    .scaleEffect(0.9)
            } else {
                Button(action: { presenter.syncNow() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Now")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appPurple)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    var habitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Habits")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Spacer()

                Text("\(presenter.habitsCompletedCount)/\(presenter.habits.count) completed")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }

            VStack(spacing: 12) {
                ForEach(presenter.habits) { habit in
                    habitRow(habit)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    func habitRow(_ habit: HabitViewModel) -> some View {
        Button(action: {
            presenter.toggleHabit(habit.id)
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(habit.isCompleted ? Color.appGreen.opacity(0.1) : Color.appGray100)
                        .frame(width: 36, height: 36)

                    Image(systemName: habit.icon)
                        .font(.system(size: 14))
                        .foregroundColor(habit.isCompleted ? Color.appGreen : Color.appGray500)
                }

                Text(habit.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(habit.isCompleted ? Color.appGray500 : Color.appGray700)
                    .strikethrough(habit.isCompleted, color: Color.appGray400)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(habit.isCompleted ? Color.appGreen : Color.appGray300, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(habit.isCompleted ? Color.appGreen : Color.clear)
                        )

                    if habit.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(habit.isCompleted ? Color.appGreenLight.opacity(0.5) : Color.appGray50)
            )
        }
        .buttonStyle(.plain)
    }

    func dayCard(day: TodayDayViewModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    if day.isToday {
                        Circle()
                            .fill(Color.appPurple)
                            .frame(width: 32, height: 32)

                        Text("\(day.id)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appGray200)
                            .frame(width: 32, height: 32)

                        Text("D\(day.id)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.appGray600)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(day.isToday ? "Today's Focus: \(day.topic)" : "Backlog: \(day.topic)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.appGray800)

                    Text("\(day.completedCount)/\(day.totalCount) problems completed")
                        .font(.system(size: 13))
                        .foregroundColor(Color.appGray500)
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
                        }
                    )

                    if problem.index < day.problems.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
