#if os(iOS)
// iPadStatsView.swift
// FocusApp -- iPad Stats screen (charts + metrics)
// Wired to StatsPresenter for live data

import FocusDesignSystem
import SwiftUI

struct iPadStatsView: View {
    @ObservedObject var presenter: StatsPresenter
    @Environment(\.dsTheme) var theme

    private var vm: StatsViewModel { presenter.viewModel }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Text("Your Statistics")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.xl)
                    .padding(.top, theme.spacing.xl)

                // Metric cards row
                HStack(spacing: theme.spacing.sm) {
                    iPadMetricCard(
                        title: "Problems Solved",
                        value: "\(vm.solvedProblems)/\(vm.totalProblems)",
                        icon: "checkmark.circle.fill",
                        iconColor: theme.colors.success,
                        theme: theme
                    )
                    iPadMetricCard(
                        title: "Topics Complete",
                        value: "\(vm.completedTopics)/\(vm.totalTopics)",
                        icon: "book.closed.fill",
                        iconColor: theme.colors.primary,
                        theme: theme
                    )
                    iPadMetricCard(
                        title: "Days Left",
                        value: "\(vm.daysLeft)",
                        icon: "calendar",
                        iconColor: theme.colors.warning,
                        theme: theme
                    )
                    iPadMetricCard(
                        title: "Habits Today",
                        value: "\(vm.habitsToday)/3",
                        icon: "flame.fill",
                        iconColor: Color(hex: 0xEA580C),
                        theme: theme
                    )
                }
                .padding(.horizontal, theme.spacing.xl)

                // Overall progress ring + topic breakdown side by side
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    overallProgressCard
                    topicBreakdownCard
                }
                .padding(.horizontal, theme.spacing.xl)

                // Topic progress bars
                topicProgressSection
            }
            .padding(.bottom, 48)
        }
    }

    // MARK: - Overall Progress Card

    private var overallProgressCard: some View {
        let progress = vm.totalProblems > 0
            ? Double(vm.solvedProblems) / Double(vm.totalProblems)
            : 0.0

        return DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(spacing: theme.spacing.md) {
                Text("Overall Progress")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                DSProgressRing(
                    progress: progress,
                    size: 160,
                    lineWidth: 12,
                    color: theme.colors.primary
                )

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text("\(vm.solvedProblems) of \(vm.totalProblems) problems")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Topic Breakdown Card

    private var topicBreakdownCard: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text("Topic Breakdown")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                ForEach(vm.topicBreakdown) { topic in
                    HStack(spacing: theme.spacing.sm) {
                        // Completion indicator
                        if topic.isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(theme.colors.success)
                                .font(.system(size: 14))
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(theme.colors.border)
                                .font(.system(size: 14))
                        }

                        Text(topic.topic)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.colors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        Text("\(topic.completed)/\(topic.total)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Topic Progress Section

    private var topicProgressSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Progress by Topic")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.xl)

            VStack(spacing: theme.spacing.sm) {
                ForEach(vm.topicBreakdown) { topic in
                    iPadTopicProgressRow(topic: topic, theme: theme)
                }
            }
            .padding(.horizontal, theme.spacing.xl)
        }
    }
}

// MARK: - Metric Card

private struct iPadMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let theme: DSTheme

    var body: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 14))
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
            }
        }
    }
}

// MARK: - Topic Progress Row

private struct iPadTopicProgressRow: View {
    let topic: TopicBreakdownViewModel
    let theme: DSTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack {
                Text("Day \(topic.id): \(topic.topic)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Text("\(topic.completed)/\(topic.total)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(
                        topic.isComplete ? theme.colors.success : theme.colors.textSecondary
                    )
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.colors.border)
                        .frame(height: 6)
                    Capsule()
                        .fill(topic.isComplete ? theme.colors.success : theme.colors.primary)
                        .frame(width: geo.size.width * topic.progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.sm)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.sm)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }
}
#endif
