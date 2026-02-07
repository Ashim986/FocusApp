#if os(iOS)
// iPhoneStatsView.swift
// FocusApp -- iPhone Stats screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneStatsView: View {
    @Environment(\.dsTheme) var theme

    @ObservedObject var presenter: StatsPresenter

    private var vm: StatsViewModel { presenter.viewModel }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    // Title
                    Text("Your Statistics")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Overall progress bar chart
                    topicProgressChart
                        .padding(.horizontal, theme.spacing.lg)

                    // Metric cards 2x2 grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: theme.spacing.sm),
                            GridItem(.flexible(), spacing: theme.spacing.sm),
                        ],
                        spacing: theme.spacing.sm
                    ) {
                        metricCard(
                            label: "Problems Solved",
                            value: "\(vm.solvedProblems)/\(vm.totalProblems)"
                        )
                        metricCard(
                            label: "Topics Done",
                            value: "\(vm.completedTopics)/\(vm.totalTopics)"
                        )
                        metricCard(
                            label: "Habits Today",
                            value: "\(vm.habitsToday)/3"
                        )
                        metricCard(
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
                        ForEach(Array(vm.topicBreakdown.enumerated()), id: \.element.id) { index, topic in
                            if index > 0 {
                                Divider().padding(.leading, theme.spacing.lg)
                            }
                            topicRow(topic)
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

    // MARK: - Header Bar

    private var headerBar: some View {
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

    // MARK: - Topic Progress Chart

    private var topicProgressChart: some View {
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
                let barWidth: CGFloat = max(12, min(32, (chartWidth - 40) / CGFloat(data.count)))
                let totalBars = CGFloat(data.count)
                let spacing = (chartWidth - barWidth * totalBars) / (totalBars + 1)

                ZStack(alignment: .bottomLeading) {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { i in
                        let y = chartHeight * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: chartWidth, y: y))
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

    // MARK: - Topic Row

    private func topicRow(_ topic: TopicBreakdownViewModel) -> some View {
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

    // MARK: - Metric Card

    private func metricCard(label: String, value: String) -> some View {
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
}
#endif
