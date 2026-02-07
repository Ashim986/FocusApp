// MacStatsView.swift
// FocusApp -- Mac Stats dashboard screen

import FocusDesignSystem
import SwiftUI

struct MacStatsView: View {
    @Environment(\.dsTheme) var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                Text("Your Statistics")
                    .font(theme.typography.title)
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.xl)
                    .padding(.top, theme.spacing.xl)

                // Two charts side by side
                HStack(alignment: .top, spacing: theme.spacing.lg) {
                    macBarChart(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                        title: "Weekly Focus Time",
                        barColor: Color(hex: 0x6366F1)
                    )

                    macLineChart(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                        title: "Problems Solved",
                        lineColor: Color(hex: 0x10B981)
                    )
                }
                .padding(.horizontal, theme.spacing.xl)

                // 4 metric cards in a row
                HStack(spacing: theme.spacing.md) {
                    DSMetricCard(
                        title: "Total Focus",
                        value: "34h 12m",
                        trend: .up,
                        trendText: "+2.5h"
                    )

                    DSMetricCard(
                        title: "Current Streak",
                        value: "12 Days",
                        trend: .up,
                        trendText: "+1"
                    )

                    DSMetricCard(
                        title: "Problems Solved",
                        value: "45",
                        trend: .up,
                        trendText: "+5"
                    )

                    DSMetricCard(
                        title: "Avg. Difficulty",
                        value: "Medium",
                        trend: .neutral,
                        trendText: "Steady"
                    )
                }
                .padding(.horizontal, theme.spacing.xl)
            }
            .padding(.bottom, 48)
        }
        .background(theme.colors.background)
    }

    // MARK: - Bar Chart

    private func macBarChart(
        data: [CGFloat],
        labels: [String],
        title: String,
        barColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(title)
                .font(theme.typography.subtitle)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height - 24
                let maxValue: CGFloat = data.max() ?? 1
                let barWidth: CGFloat = 32
                let totalBars = CGFloat(data.count)
                let spacing = (chartWidth - barWidth * totalBars) / (totalBars + 1)

                ZStack(alignment: .bottomLeading) {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { i in
                        let yPos = chartHeight * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: yPos))
                            path.addLine(to: CGPoint(x: chartWidth, y: yPos))
                        }
                        .stroke(
                            theme.colors.border.opacity(0.5),
                            style: StrokeStyle(lineWidth: 0.5, dash: [4])
                        )
                    }

                    // Bars
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(0..<data.count, id: \.self) { index in
                            VStack(spacing: theme.spacing.xs) {
                                RoundedRectangle(cornerRadius: theme.radii.sm)
                                    .fill(barColor)
                                    .frame(
                                        width: barWidth,
                                        height: maxValue > 0
                                            ? chartHeight * data[index] / maxValue
                                            : 0
                                    )

                                Text(labels[index])
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                                    .frame(width: barWidth)
                            }
                        }
                    }
                    .padding(.leading, spacing)
                }
            }
            .frame(height: 220)
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

    // MARK: - Line Chart

    private func macLineChart(
        data: [CGFloat],
        labels: [String],
        title: String,
        lineColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(title)
                .font(theme.typography.subtitle)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height - 24
                let maxValue: CGFloat = data.max() ?? 1
                let stepX = chartWidth / CGFloat(data.count - 1)

                ZStack(alignment: .bottomLeading) {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { i in
                        let yPos = chartHeight * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: yPos))
                            path.addLine(to: CGPoint(x: chartWidth, y: yPos))
                        }
                        .stroke(
                            theme.colors.border.opacity(0.5),
                            style: StrokeStyle(lineWidth: 0.5, dash: [4])
                        )
                    }

                    // Line path
                    Path { path in
                        for (index, value) in data.enumerated() {
                            let x = stepX * CGFloat(index)
                            let y = chartHeight - (chartHeight * value / maxValue)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    // Fill area under the line
                    Path { path in
                        for (index, value) in data.enumerated() {
                            let x = stepX * CGFloat(index)
                            let y = chartHeight - (chartHeight * value / maxValue)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: chartHeight))
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        path.addLine(to: CGPoint(x: stepX * CGFloat(data.count - 1), y: chartHeight))
                        path.closeSubpath()
                    }
                    .fill(lineColor.opacity(0.1))

                    // Data points
                    ForEach(0..<data.count, id: \.self) { index in
                        let x = stepX * CGFloat(index)
                        let y = chartHeight - (chartHeight * data[index] / maxValue)
                        Circle()
                            .fill(lineColor)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }

                    // Labels
                    HStack(spacing: 0) {
                        ForEach(0..<labels.count, id: \.self) { index in
                            Text(labels[index])
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .offset(y: chartHeight + 12)
                }
            }
            .frame(height: 220)
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
}

// MARK: - Metric Card

private struct DSMetricCard: View {
    @Environment(\.dsTheme) var theme

    let title: String
    let value: String
    let trend: TrendDirection
    let trendText: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textSecondary)
                .textCase(.uppercase)

            Text(value)
                .font(theme.typography.subtitle)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.textPrimary)

            HStack(spacing: theme.spacing.xs) {
                Image(systemName: trend.iconName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(trend.color)

                Text(trendText)
                    .font(theme.typography.caption)
                    .foregroundColor(trend.color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Trend Direction

private enum TrendDirection {
    case up
    case down
    case neutral

    var iconName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "minus"
        }
    }

    var color: Color {
        switch self {
        case .up: return Color(hex: 0x10B981)
        case .down: return Color(hex: 0xEF4444)
        case .neutral: return Color(hex: 0x6B7280)
        }
    }
}

#Preview("Mac Stats") {
    MacStatsView()
        .frame(width: 1200, height: 760)
}
