import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataStore: DataStore

    private let blockedSites = [
        "YouTube", "Twitter/X", "Reddit", "Instagram",
        "TikTok", "Facebook", "Netflix", "Twitch"
    ]

    private var totalProblems: Int {
        dsaPlan.reduce(0) { $0 + $1.problems.count }
    }

    private var solvedProblems: Int {
        dataStore.data.totalCompletedProblems()
    }

    private var completedTopics: Int {
        dataStore.data.completedTopicsCount()
    }

    private var totalTopics: Int {
        dsaPlan.count
    }

    private var habitsToday: Int {
        dataStore.data.todayHabitsCount()
    }

    // Days until Feb 17 (end of plan + buffer)
    private var daysLeft: Int {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let endDate = formatter.date(from: "2026-02-17") else { return 0 }
        let today = Date()
        let components = calendar.dateComponents([.day], from: today, to: endDate)
        return max(0, components.day ?? 0)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stat cards grid
                statCardsGrid

                // Pre-completed topics
                preCompletedSection

                // Topic breakdown
                topicBreakdownSection

                // Blocked sites reminder
                blockedSitesReminder
            }
            .padding(20)
        }
        .background(Color.appGray50)
    }

    private var statCardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            statCard(
                title: "Problems Solved",
                value: "\(solvedProblems)/\(totalProblems)",
                icon: "checkmark.circle.fill",
                color: Color.appGreen,
                progress: Double(solvedProblems) / Double(totalProblems)
            )

            statCard(
                title: "Topics Done",
                value: "\(completedTopics)/\(totalTopics)",
                icon: "book.closed.fill",
                color: Color.appPurple,
                progress: Double(completedTopics) / Double(totalTopics)
            )

            statCard(
                title: "Habits Today",
                value: "\(habitsToday)/3",
                icon: "star.fill",
                color: Color.appAmber,
                progress: Double(habitsToday) / 3.0
            )

            statCard(
                title: "Days Left",
                value: "\(daysLeft)",
                icon: "calendar",
                color: Color.appRed,
                progress: nil
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color, progress: Double?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }

                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.appGray800)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(Color.appGray500)

            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.appGray200)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var preCompletedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.appAmber)

                Text("Pre-Completed Topics")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Spacer()

                Text("+\(preCompletedTopics.count) bonus")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.appGreen)
            }

            FlowLayout(spacing: 8) {
                ForEach(preCompletedTopics, id: \.self) { topic in
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))

                        Text(topic)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.appGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appGreenLight)
                    )
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

    private var topicBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Topic Breakdown")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.appGray800)

            ForEach(dsaPlan) { day in
                topicRow(day: day)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private func topicRow(day: Day) -> some View {
        let completed = dataStore.data.completedProblemsCount(day: day.id, totalProblems: day.problems.count)
        let total = day.problems.count
        let progress = Double(completed) / Double(total)
        let isComplete = completed == total

        return VStack(spacing: 8) {
            HStack {
                Text(day.topic)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isComplete ? Color.appGreen : Color.appGray700)

                Spacer()

                Text("\(completed)/\(total)")
                    .font(.system(size: 13))
                    .foregroundColor(isComplete ? Color.appGreen : Color.appGray500)

                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.appGreen)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appGray200)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(isComplete ? Color.appGreen : Color.appPurple)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    private var blockedSitesReminder: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.appRed)

                Text("Stay Focused")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Spacer()
            }

            Text("Use Focus Mode to block these distracting sites during study:")
                .font(.system(size: 13))
                .foregroundColor(Color.appGray600)

            FlowLayout(spacing: 6) {
                ForEach(blockedSites, id: \.self) { site in
                    Text(site)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.appRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appRedLight)
                        )
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
    StatsView()
        .environmentObject(DataStore())
        .frame(width: 600, height: 800)
}
