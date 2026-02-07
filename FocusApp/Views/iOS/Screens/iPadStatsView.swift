// iPadStatsView.swift
// FocusApp — iPad Stats screen (charts + metrics)
// Spec: FIGMA_SETUP_GUIDE.md §5.3

import SwiftUI

struct iPadStatsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                Text("Your Statistics")
                    .font(LegacyDSTypography.headline)
                    .foregroundColor(LegacyDSColor.textPrimary)
                    .padding(.horizontal, DSLayout.spacing(.space24))
                    .padding(.top, DSLayout.spacing(.space24))

                // Two charts side by side
                HStack(alignment: .top, spacing: DSLayout.spacing(.space12)) {
                    LegacyDSBarChart(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        title: "Weekly Focus Time"
                    )

                    LegacyDSLineChart(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        title: "Problems Solved"
                    )
                }
                .padding(.horizontal, DSLayout.spacing(.space24))

                // 4 metric cards in a row
                HStack(spacing: DSLayout.spacing(.space8)) {
                    LegacyDSMetricCardView(label: "Total Focus", value: "34h 12m")
                    LegacyDSMetricCardView(label: "Current Streak", value: "12 Days")
                    LegacyDSMetricCardView(label: "Problems Solved", value: "45")
                    LegacyDSMetricCardView(label: "Avg. Difficulty", value: "Medium")
                }
                .padding(.horizontal, DSLayout.spacing(.space24))
            }
            .padding(.bottom, DSLayout.spacing(.space48))
        }
    }
}

#Preview {
    iPadStatsView()
        .frame(width: 574, height: 1194)
}
