// iPadStatsView.swift
// FocusApp — iPad Stats screen (charts + metrics)
// Spec: FIGMA_SETUP_GUIDE.md §5.3

import FocusDesignSystem
import SwiftUI

struct iPadStatsView: View {
    @Environment(\.dsTheme) var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Text("Your Statistics")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.xl)
                    .padding(.top, theme.spacing.xl)

                // Two charts side by side
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    iPadBarChartView(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        title: "Weekly Focus Time",
                        theme: theme
                    )

                    iPadLineChartView(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        title: "Problems Solved",
                        theme: theme
                    )
                }
                .padding(.horizontal, theme.spacing.xl)

                // 4 metric cards in a row
                HStack(spacing: theme.spacing.sm) {
                    DSMetricCard(title: "Total Focus", value: "34h 12m")
                    DSMetricCard(title: "Current Streak", value: "12 Days")
                    DSMetricCard(title: "Problems Solved", value: "45")
                    DSMetricCard(title: "Avg. Difficulty", value: "Medium")
                }
                .padding(.horizontal, theme.spacing.xl)
            }
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Bar Chart

private struct iPadBarChartView: View {
    var data: [CGFloat] = [4, 6, 3, 7, 5, 2, 8]
    var labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var maxValue: CGFloat = 8
    var title: String = "Weekly Focus Time"
    var theme: DSTheme

    var body: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                GeometryReader { geo in
                    let chartWidth = geo.size.width
                    let chartHeight = geo.size.height - 24
                    let barWidth: CGFloat = 32
                    let totalBars = CGFloat(data.count)
                    let spacing = (chartWidth - barWidth * totalBars) / (totalBars + 1)

                    ZStack(alignment: .bottomLeading) {
                        // Grid lines (dashed)
                        ForEach(0..<5, id: \.self) { i in
                            let gridY = chartHeight * CGFloat(i) / 4
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: gridY))
                                path.addLine(to: CGPoint(x: chartWidth, y: gridY))
                            }
                            .stroke(
                                theme.colors.border,
                                style: StrokeStyle(lineWidth: 0.5, dash: [4])
                            )
                        }

                        // Bars
                        HStack(alignment: .bottom, spacing: spacing) {
                            ForEach(0..<data.count, id: \.self) { index in
                                VStack(spacing: theme.spacing.xs) {
                                    RoundedRectangle(cornerRadius: theme.radii.sm)
                                        .fill(Color(hex: 0x6366F1))
                                        .frame(
                                            width: barWidth,
                                            height: maxValue > 0
                                                ? chartHeight * data[index] / maxValue
                                                : 0
                                        )

                                    Text(labels[index])
                                        .font(theme.typography.caption)
                                        .foregroundColor(Color(hex: 0x9CA3AF))
                                        .frame(width: barWidth)
                                }
                            }
                        }
                        .padding(.leading, spacing)
                    }
                }
                .frame(height: 200)
            }
        }
    }
}

// MARK: - Line Chart

private struct iPadLineChartView: View {
    var data: [CGFloat] = [3, 5, 4, 8, 6, 9, 7]
    var labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var maxValue: CGFloat = 12
    var title: String = "Problems Solved"
    var theme: DSTheme

    var body: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                GeometryReader { geo in
                    let chartWidth = geo.size.width
                    let chartHeight = geo.size.height - 24

                    ZStack(alignment: .bottomLeading) {
                        // Grid lines
                        ForEach(0..<5, id: \.self) { i in
                            let gridY = chartHeight - chartHeight * CGFloat(i) / 4
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: gridY))
                                path.addLine(to: CGPoint(x: chartWidth, y: gridY))
                            }
                            .stroke(
                                theme.colors.border,
                                style: StrokeStyle(lineWidth: 0.5, dash: [4])
                            )
                        }

                        // Line path
                        let points = data.enumerated().map { index, value -> CGPoint in
                            let x = chartWidth * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                            let y = chartHeight - (maxValue > 0 ? chartHeight * value / maxValue : 0)
                            return CGPoint(x: x, y: y)
                        }

                        Path { path in
                            guard let first = points.first else { return }
                            path.move(to: first)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(theme.colors.success, lineWidth: 2)

                        // Dot markers
                        ForEach(0..<points.count, id: \.self) { i in
                            Circle()
                                .fill(theme.colors.success)
                                .frame(width: 8, height: 8)
                                .position(points[i])
                        }

                        // X-axis labels
                        HStack(spacing: 0) {
                            ForEach(0..<labels.count, id: \.self) { i in
                                Text(labels[i])
                                    .font(theme.typography.caption)
                                    .foregroundColor(Color(hex: 0x9CA3AF))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .offset(y: chartHeight + 8)
                    }
                }
                .frame(height: 200)
            }
        }
    }
}

#Preview {
    iPadStatsView()
        .frame(width: 574, height: 1194)
}
