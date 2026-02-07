// iPhoneStatsView.swift
// FocusApp -- iPhone Stats screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneStatsView: View {
    @Environment(\.dsTheme) var theme

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

                    // Weekly Focus Time bar chart
                    barChart(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        title: "Weekly Focus Time",
                        barColor: Color(hex: 0x6366F1)
                    )
                    .padding(.horizontal, theme.spacing.lg)

                    // Problems Solved line chart
                    lineChart(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        title: "Problems Solved",
                        lineColor: Color(hex: 0x10B981)
                    )
                    .padding(.horizontal, theme.spacing.lg)

                    // Metric cards 2x2 grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: theme.spacing.sm),
                            GridItem(.flexible(), spacing: theme.spacing.sm),
                        ],
                        spacing: theme.spacing.sm
                    ) {
                        metricCard(label: "Total Focus", value: "34h 12m")
                        metricCard(label: "Current Streak", value: "12 Days")
                        metricCard(label: "Problems Solved", value: "45")
                        metricCard(label: "Avg. Difficulty", value: "Medium")
                    }
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
        .overlay(alignment: .trailing) {
            Button { } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.trailing, theme.spacing.lg)
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Bar Chart

    private func barChart(
        data: [CGFloat],
        title: String,
        barColor: Color,
        labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
        maxValue: CGFloat = 8
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(title)
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height - 24
                let barWidth: CGFloat = 32
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
                                    .fill(barColor)
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

    private func lineChart(
        data: [CGFloat],
        title: String,
        lineColor: Color,
        labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
        maxValue: CGFloat = 12
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(title)
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height - 24

                ZStack(alignment: .bottomLeading) {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { i in
                        let y = chartHeight - chartHeight * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: chartWidth, y: y))
                        }
                        .stroke(
                            Color(hex: 0xE5E7EB),
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
                    .stroke(lineColor, lineWidth: 2)

                    // Dot markers
                    ForEach(0..<points.count, id: \.self) { i in
                        Circle()
                            .fill(lineColor)
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
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
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

#Preview {
    iPhoneStatsView()
}
