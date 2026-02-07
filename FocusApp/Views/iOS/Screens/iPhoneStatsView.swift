// iPhoneStatsView.swift
// FocusApp — iPhone Stats screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.4

import SwiftUI

struct iPhoneStatsView: View {
    var body: some View {
        VStack(spacing: 0) {
            LegacyDSHeaderBar()

            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                    // Title
                    Text("Your Statistics")
                        .font(LegacyDSTypography.headline)
                        .foregroundColor(LegacyDSColor.textPrimary)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Weekly Focus Time bar chart
                    LegacyDSBarChart(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        title: "Weekly Focus Time"
                    )
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    // Problems Solved line chart
                    LegacyDSLineChart(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        title: "Problems Solved"
                    )
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    // Metric cards 2x2 grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: DSLayout.spacing(.space8)),
                            GridItem(.flexible(), spacing: DSLayout.spacing(.space8)),
                        ],
                        spacing: DSLayout.spacing(.space8)
                    ) {
                        LegacyDSMetricCardView(label: "Total Focus", value: "34h 12m")
                        LegacyDSMetricCardView(label: "Current Streak", value: "12 Days")
                        LegacyDSMetricCardView(label: "Problems Solved", value: "45")
                        LegacyDSMetricCardView(label: "Avg. Difficulty", value: "Medium")
                    }
                    .padding(.horizontal, DSLayout.spacing(.space16))
                }
                .padding(.top, DSLayout.spacing(.space8))
                .padding(.bottom, DSLayout.spacing(.space32))
            }
        }
        .background(LegacyDSColor.background)
    }
}

#Preview {
    iPhoneStatsView()
}
