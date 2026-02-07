// iPadStatsView.swift
// FocusApp — iPad Stats screen (charts + metrics)
// Spec: FIGMA_SETUP_GUIDE.md §5.3

import SwiftUI

struct iPadStatsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.space16) {
                Text("Your Statistics")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColor.textPrimary)
                    .padding(.horizontal, DSSpacing.space24)
                    .padding(.top, DSSpacing.space24)

                // Two charts side by side
                HStack(alignment: .top, spacing: DSSpacing.space12) {
                    DSBarChart(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        title: "Weekly Focus Time"
                    )

                    DSLineChart(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        title: "Problems Solved"
                    )
                }
                .padding(.horizontal, DSSpacing.space24)

                // 4 metric cards in a row
                HStack(spacing: DSSpacing.space8) {
                    DSMetricCardView(label: "Total Focus", value: "34h 12m")
                    DSMetricCardView(label: "Current Streak", value: "12 Days")
                    DSMetricCardView(label: "Problems Solved", value: "45")
                    DSMetricCardView(label: "Avg. Difficulty", value: "Medium")
                }
                .padding(.horizontal, DSSpacing.space24)
            }
            .padding(.bottom, DSSpacing.space48)
        }
    }
}

#Preview {
    iPadStatsView()
        .frame(width: 574, height: 1194)
}
