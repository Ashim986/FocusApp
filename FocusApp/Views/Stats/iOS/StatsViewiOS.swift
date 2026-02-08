#if os(iOS)
// StatsViewiOS.swift
// FocusApp -- Unified Stats screen for iPhone and iPad
// Uses horizontalSizeClass to switch between compact (iPhone) and regular (iPad) layouts

import FocusDesignSystem
import SwiftUI

// swiftlint:disable:next type_body_length
struct StatsViewiOS: View {
    @ObservedObject var presenter: StatsPresenter
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme

    private var vm: StatsViewModel { presenter.viewModel }

    var body: some View {
        if sizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            compactHeaderBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    // Title
                    Text("Your Statistics")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Overall progress bar chart
                    compactTopicProgressChart
                        .padding(.horizontal, theme.spacing.lg)

                    // Metric cards 2x2 grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: theme.spacing.sm),
                            GridItem(.flexible(), spacing: theme.spacing.sm)
                        ],
                        spacing: theme.spacing.sm
                    ) {
                        compactMetricCard(
                            label: "Problems Solved",
                            value: "\(vm.solvedProblems)/\(vm.totalProblems)"
                        )
                        compactMetricCard(
                            label: "Topics Done",
                            value: "\(vm.completedTopics)/\(vm.totalTopics)"
                        )
                        compactMetricCard(
                            label: "Habits Today",
                            value: "\(vm.habitsToday)/3"
                        )
                        compactMetricCard(
                            label: "Days Left",
                            value: "\(vm.daysLeft)"
                        )
                    }
                    .padding(.horizontal, theme.spacing.lg)

                    // Topic breakdown
                    Text("Topic Breakdown")
                        .font(theme.typography.subtitle)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    VStack(spacing: 0) {
                        ForEach(
                            Array(vm.topicBreakdown.enumerated()),
                            id: \.element.id
                        ) { index, topic in
                            if index > 0 {
                                Divider().padding(.leading, theme.spacing.lg)
                            }
                            compactTopicRow(topic)
                        }
                    }
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, theme.spacing.lg)
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Text("Your Statistics")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.xl)
                    .padding(.top, theme.spacing.xl)

                // Metric cards row
                HStack(spacing: theme.spacing.sm) {
                    regularMetricCard(
                        title: "Problems Solved",
                        value: "\(vm.solvedProblems)/\(vm.totalProblems)",
                        icon: "checkmark.circle.fill",
                        iconColor: theme.colors.success
                    )
                    regularMetricCard(
                        title: "Topics Complete",
                        value: "\(vm.completedTopics)/\(vm.totalTopics)",
                        icon: "book.closed.fill",
                        iconColor: theme.colors.primary
                    )
                    regularMetricCard(
                        title: "Days Left",
                        value: "\(vm.daysLeft)",
                        icon: "calendar",
                        iconColor: theme.colors.warning
                    )
                    regularMetricCard(
                        title: "Habits Today",
                        value: "\(vm.habitsToday)/3",
                        icon: "flame.fill",
                        iconColor: Color(hex: 0xEA580C)
                    )
                }
                .padding(.horizontal, theme.spacing.xl)

                // Overall progress ring + topic breakdown side by side
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    regularOverallProgressCard
                    regularTopicBreakdownCard
                }
                .padding(.horizontal, theme.spacing.xl)

                // Topic progress bars
                regularTopicProgressSection
            }
            .padding(.bottom, 48)
        }
    }

    // MARK: - Compact: Header Bar

    private var compactHeaderBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Compact: Topic Progress Chart

    private var compactTopicProgressChart: some View {
        let data = vm.topicBreakdown.map { topic -> CGFloat in
            topic.total > 0 ? CGFloat(topic.completed) / CGFloat(topic.total) : 0
        }
        let labels = vm.topicBreakdown.map { "D\($0.id)" }
        let maxValue: CGFloat = 1.0

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Progress by Day")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height - 24
                let barWidth: CGFloat = max(
                    12,
                    min(32, (chartWidth - 40) / CGFloat(data.count))
                )
                let totalBars = CGFloat(data.count)
                let spacing = (chartWidth - barWidth * totalBars) / (totalBars + 1)

                ZStack(alignment: .bottomLeading) {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { gridIndex in
                        let yPos = chartHeight * CGFloat(gridIndex) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: yPos))
                            path.addLine(to: CGPoint(x: chartWidth, y: yPos))
                        }
                        .stroke(
                            Color(hex: 0xE5E7EB),
                            style: StrokeStyle(lineWidth: 0.5, dash: [4])
                        )
                    }

                    // Bars
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(0..<data.count, id: \.self) { index in
                            VStack(spacing: theme.spacing.xs) {
                                RoundedRectangle(cornerRadius: theme.radii.sm)
                                    .fill(
                                        data[index] >= 1.0
                                            ? Color(hex: 0x059669)
                                            : Color(hex: 0x6366F1)
                                    )
                                    .frame(
                                        width: barWidth,
                                        height: maxValue > 0
                                            ? chartHeight * data[index] / maxValue
                                            : 0
                                    )

                                if index < labels.count {
                                    Text(labels[index])
                                        .font(theme.typography.caption)
                                        .foregroundColor(Color(hex: 0x9CA3AF))
                                        .frame(width: barWidth)
                                }
                            }
                        }
                    }
                    .padding(.leading, spacing)
                }
            }
            .frame(height: 200)
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Compact: Topic Row

    private func compactTopicRow(_ topic: TopicBreakdownViewModel) -> some View {
        HStack(spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(topic.id): \(topic.topic)")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("\(topic.completed)/\(topic.total) problems")
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            Spacer()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color(hex: 0xE5E7EB), lineWidth: 4)
                    .frame(width: 36, height: 36)

                Circle()
                    .trim(from: 0, to: topic.progress)
                    .stroke(
                        topic.isComplete
                            ? Color(hex: 0x059669)
                            : Color(hex: 0x6366F1),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))

                if topic.isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: 0x059669))
                } else {
                    Text("\(Int(topic.progress * 100))%")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(Color(hex: 0x6B7280))
                }
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 64)
    }

    // MARK: - Compact: Metric Card

    private func compactMetricCard(label: String, value: String) -> some View {
        VStack(spacing: theme.spacing.xs) {
            Text(label)
                .font(theme.typography.caption)
                .foregroundColor(Color(hex: 0x6B7280))

            Text(value)
                .font(theme.typography.subtitle)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Regular: Metric Card

    private func regularMetricCard(
        title: String,
        value: String,
        icon: String,
        iconColor: Color
    ) -> some View {
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

    // MARK: - Regular: Overall Progress Card

    private var regularOverallProgressCard: some View {
        let progress = vm.totalProblems > 0
            ? Double(vm.solvedProblems) / Double(vm.totalProblems)
            : 0.0

        return DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(spacing: theme.spacing.md) {
                Text("Overall Progress")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                DSProgressRing(
                    config: DSProgressRingConfig(
                        size: 160,
                        lineWidth: 12,
                        style: .primary
                    ),
                    state: DSProgressRingState(progress: progress)
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

    // MARK: - Regular: Topic Breakdown Card

    private var regularTopicBreakdownCard: some View {
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

    // MARK: - Regular: Topic Progress Section

    private var regularTopicProgressSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Progress by Topic")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.xl)

            VStack(spacing: theme.spacing.sm) {
                ForEach(vm.topicBreakdown) { topic in
                    StatsTopicProgressRowiOS(topic: topic, theme: theme)
                }
            }
            .padding(.horizontal, theme.spacing.xl)
        }
    }
}

// MARK: - Topic Progress Row (iPad regular layout)

private struct StatsTopicProgressRowiOS: View {
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
