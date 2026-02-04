import SwiftUI

extension StatsView {
    var statCardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            statCard(
                title: "Problems Solved",
                value: "\(presenter.viewModel.solvedProblems)/\(presenter.viewModel.totalProblems)",
                icon: "checkmark.circle.fill",
                color: Color.appGreen,
                progress: Double(presenter.viewModel.solvedProblems) / Double(max(presenter.viewModel.totalProblems, 1))
            )

            statCard(
                title: "Topics Done",
                value: "\(presenter.viewModel.completedTopics)/\(presenter.viewModel.totalTopics)",
                icon: "book.closed.fill",
                color: Color.appPurple,
                progress: Double(presenter.viewModel.completedTopics) / Double(max(presenter.viewModel.totalTopics, 1))
            )

            statCard(
                title: "Habits Today",
                value: "\(presenter.viewModel.habitsToday)/\(AppConstants.totalHabits)",
                icon: "star.fill",
                color: Color.appAmber,
                progress: Double(presenter.viewModel.habitsToday) / Double(AppConstants.totalHabits)
            )

            statCard(
                title: "Days Left",
                value: "\(presenter.viewModel.daysLeft)",
                icon: "calendar",
                color: Color.appRed,
                progress: nil
            )
        }
    }

    func statCard(title: String, value: String, icon: String, color: Color, progress: Double?) -> some View {
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

    var preCompletedSection: some View {
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

    var topicBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Topic Breakdown")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.appGray800)

            ForEach(presenter.viewModel.topicBreakdown) { day in
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

    func topicRow(day: TopicBreakdownViewModel) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(day.topic)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(day.isComplete ? Color.appGreen : Color.appGray700)

                Spacer()

                Text("\(day.completed)/\(day.total)")
                    .font(.system(size: 13))
                    .foregroundColor(day.isComplete ? Color.appGreen : Color.appGray500)

                if day.isComplete {
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
                        .fill(day.isComplete ? Color.appGreen : Color.appPurple)
                        .frame(width: geo.size.width * day.progress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}
