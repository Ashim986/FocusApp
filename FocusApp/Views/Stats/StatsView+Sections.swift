import FocusDesignSystem
import SwiftUI

extension StatsView {
    var statCardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            statCard(
                title: L10n.Stats.cardProblemsSolved,
                value: "\(presenter.viewModel.solvedProblems)/\(presenter.viewModel.totalProblems)",
                icon: "checkmark.circle.fill",
                color: theme.colors.success,
                progress: Double(presenter.viewModel.solvedProblems) / Double(max(presenter.viewModel.totalProblems, 1))
            )

            statCard(
                title: L10n.Stats.cardTopicsDone,
                value: "\(presenter.viewModel.completedTopics)/\(presenter.viewModel.totalTopics)",
                icon: "book.closed.fill",
                color: theme.colors.primary,
                progress: Double(presenter.viewModel.completedTopics) / Double(max(presenter.viewModel.totalTopics, 1))
            )

            statCard(
                title: L10n.Stats.cardHabitsToday,
                value: "\(presenter.viewModel.habitsToday)/\(AppConstants.totalHabits)",
                icon: "star.fill",
                color: theme.colors.warning,
                progress: Double(presenter.viewModel.habitsToday) / Double(AppConstants.totalHabits)
            )

            statCard(
                title: L10n.Stats.cardDaysLeft,
                value: "\(presenter.viewModel.daysLeft)",
                icon: "calendar",
                color: theme.colors.danger,
                progress: nil
            )
        }
    }

    func statCard(title: String, value: String, icon: String, color: Color, progress: Double?) -> some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 40, height: 40)

                        DSImage(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                    }

                    Spacer()
                }

                DSText(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                DSText(title)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)

                if let progress = progress {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.colors.border)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(color)
                                .frame(width: geo.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
    }

    var preCompletedSection: some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    DSImage(systemName: "trophy.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.warning)

                    DSText(L10n.Stats.precompletedTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    DSText(L10n.Stats.precompletedBonusFormat( preCompletedTopics.count))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.colors.success)
                }

                FlowLayout(spacing: 8) {
                    ForEach(preCompletedTopics, id: \.self) { topic in
                        HStack(spacing: 4) {
                            DSImage(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))

                            DSText(topic)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(theme.colors.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.colors.success.opacity(0.15))
                        )
                    }
                }
            }
        }
    }

    var topicBreakdownSection: some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: 16) {
                DSText(L10n.Stats.topicBreakdownTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                ForEach(presenter.viewModel.topicBreakdown) { day in
                    topicRow(day: day)
                }
            }
        }
    }

    func topicRow(day: TopicBreakdownViewModel) -> some View {
        VStack(spacing: 8) {
            HStack {
                DSText(day.topic)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(day.isComplete ? theme.colors.success : theme.colors.textPrimary)

                Spacer()

                DSText("\(day.completed)/\(day.total)")
                    .font(.system(size: 13))
                    .foregroundColor(day.isComplete ? theme.colors.success : theme.colors.textSecondary)

                if day.isComplete {
                    DSImage(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.success)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.colors.border)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(day.isComplete ? theme.colors.success : theme.colors.primary)
                        .frame(width: geo.size.width * day.progress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}
