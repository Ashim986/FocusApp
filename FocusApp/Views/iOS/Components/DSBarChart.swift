// LegacyDSBarChart.swift
// FocusApp — Bar chart (361x240)
// Spec: FIGMA_SETUP_GUIDE.md §3.18

import SwiftUI

struct LegacyDSBarChart: View {
    var data: [CGFloat] = [4, 6, 3, 7, 5, 2, 8]
    var labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var maxValue: CGFloat = 8
    var title: String = "Weekly Focus Time"
    var barColor: Color = LegacyDSColor.purple

    var body: some View {
        LegacyDSSurfaceCard {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
                Text(title)
                    .font(LegacyDSTypography.bodyStrong)
                    .foregroundColor(LegacyDSColor.textPrimary)

                GeometryReader { geo in
                    let chartWidth = geo.size.width
                    let chartHeight = geo.size.height - 24 // Space for labels
                    let barWidth: CGFloat = 32
                    let totalBars = CGFloat(data.count)
                    let spacing = (chartWidth - barWidth * totalBars) / (totalBars + 1)

                    ZStack(alignment: .bottomLeading) {
                        // Grid lines (dashed)
                        ForEach(0..<5, id: \.self) { i in
                            let y = chartHeight * CGFloat(i) / 4
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: chartWidth, y: y))
                            }
                            .stroke(LegacyDSColor.gray200, style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        }

                        // Bars
                        HStack(alignment: .bottom, spacing: spacing) {
                            ForEach(0..<data.count, id: \.self) { index in
                                VStack(spacing: DSLayout.spacing(.space4)) {
                                    RoundedRectangle(cornerRadius: LegacyDSRadius.small)
                                        .fill(barColor)
                                        .frame(
                                            width: barWidth,
                                            height: maxValue > 0
                                                ? chartHeight * data[index] / maxValue
                                                : 0
                                        )

                                    Text(labels[index])
                                        .font(LegacyDSTypography.caption)
                                        .foregroundColor(LegacyDSColor.gray400)
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

#Preview {
    LegacyDSBarChart()
        .padding()
}
