// LegacyDSLineChart.swift
// FocusApp — Line chart (361x240)
// Spec: FIGMA_SETUP_GUIDE.md §3.19

import SwiftUI

struct LegacyDSLineChart: View {
    var data: [CGFloat] = [3, 5, 4, 8, 6, 9, 7]
    var labels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var maxValue: CGFloat = 12
    var title: String = "Problems Solved"
    var lineColor: Color = LegacyDSColor.green

    var body: some View {
        LegacyDSSurfaceCard {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
                Text(title)
                    .font(LegacyDSTypography.bodyStrong)
                    .foregroundColor(LegacyDSColor.textPrimary)

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
                            .stroke(LegacyDSColor.gray200, style: StrokeStyle(lineWidth: 0.5, dash: [4]))
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
                                    .font(LegacyDSTypography.caption)
                                    .foregroundColor(LegacyDSColor.gray400)
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
    LegacyDSLineChart()
        .padding()
}
