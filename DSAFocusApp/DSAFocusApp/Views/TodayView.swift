import SwiftUI

struct TodayView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var showFocusMode: Bool

    private let blockedSites = [
        "YouTube", "Twitter/X", "Reddit", "Instagram",
        "TikTok", "Facebook", "Netflix", "Twitch"
    ]

    private let habits = [
        ("dsa", "DSA Study", "book.fill"),
        ("exercise", "Exercise", "figure.run"),
        ("other", "Other Study", "graduationcap.fill")
    ]

    // Find today's day in the plan (simplified - just use day 1 for now)
    private var activeDay: Day? {
        // In a real app, you'd calculate which day based on current date
        // For now, return the first incomplete day
        for day in dsaPlan {
            let completed = dataStore.data.completedProblemsCount(day: day.id, totalProblems: day.problems.count)
            if completed < day.problems.count {
                return day
            }
        }
        return dsaPlan.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Focus CTA
                focusCTACard

                // Daily habits
                habitsCard

                // Active day's problems
                if let day = activeDay {
                    activeDayCard(day: day)
                }
            }
            .padding(20)
        }
        .background(Color.appGray50)
    }

    private var focusCTACard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to Focus?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("Block distractions and start your study session")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button(action: {
                    showFocusMode = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Start Focus")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appPurple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                    )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Blocked sites
            VStack(alignment: .leading, spacing: 8) {
                Text("Sites blocked during focus:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                FlowLayout(spacing: 6) {
                    ForEach(blockedSites, id: \.self) { site in
                        Text(site)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.appIndigo, Color.appIndigoLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var habitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Habits")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Spacer()

                Text("\(dataStore.data.todayHabitsCount())/\(habits.count) completed")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }

            VStack(spacing: 12) {
                ForEach(habits, id: \.0) { habit in
                    habitRow(id: habit.0, title: habit.1, icon: habit.2)
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

    private func habitRow(id: String, title: String, icon: String) -> some View {
        let isChecked = dataStore.isHabitDone(id)

        return Button(action: {
            dataStore.toggleHabit(id)
        }) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isChecked ? Color.appGreen.opacity(0.1) : Color.appGray100)
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(isChecked ? Color.appGreen : Color.appGray500)
                }

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isChecked ? Color.appGray500 : Color.appGray700)
                    .strikethrough(isChecked, color: Color.appGray400)

                Spacer()

                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(isChecked ? Color.appGreen : Color.appGray300, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isChecked ? Color.appGreen : Color.clear)
                        )

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isChecked ? Color.appGreenLight.opacity(0.5) : Color.appGray50)
            )
        }
        .buttonStyle(.plain)
    }

    private func activeDayCard(day: Day) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.appPurple)
                        .frame(width: 32, height: 32)

                    Text("\(day.id)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Focus: \(day.topic)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.appGray800)

                    let completed = dataStore.data.completedProblemsCount(day: day.id, totalProblems: day.problems.count)
                    Text("\(completed)/\(day.problems.count) problems completed")
                        .font(.system(size: 13))
                        .foregroundColor(Color.appGray500)
                }

                Spacer()
            }

            Divider()

            VStack(spacing: 0) {
                ForEach(Array(day.problems.enumerated()), id: \.offset) { index, problem in
                    ProblemRow(
                        problem: problem,
                        isCompleted: dataStore.isProblemCompleted(day: day.id, problemIndex: index),
                        onToggle: {
                            dataStore.toggleProblem(day: day.id, problemIndex: index)
                        }
                    )

                    if index < day.problems.count - 1 {
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

#Preview {
    TodayView(showFocusMode: .constant(false))
        .environmentObject(DataStore())
        .frame(width: 600, height: 800)
}
