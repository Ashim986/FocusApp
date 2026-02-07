// iPhoneStatsView.swift
// FocusApp — iPhone Stats screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.4

import SwiftUI

struct iPhoneStatsView: View {
    var body: some View {
        VStack(spacing: 0) {
            DSHeaderBar()

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.space16) {
                    // Title
                    Text("Your Statistics")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColor.textPrimary)
                        .padding(.horizontal, DSSpacing.space16)

                    // Weekly Focus Time bar chart
                    DSBarChart(
                        data: [4, 6, 3, 7, 5, 2, 8],
                        title: "Weekly Focus Time"
                    )
                    .padding(.horizontal, DSSpacing.space16)

                    // Problems Solved line chart
                    DSLineChart(
                        data: [3, 5, 4, 8, 6, 9, 7],
                        title: "Problems Solved"
                    )
                    .padding(.horizontal, DSSpacing.space16)

                    // Metric cards 2x2 grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: DSSpacing.space8),
                            GridItem(.flexible(), spacing: DSSpacing.space8),
                        ],
                        spacing: DSSpacing.space8
                    ) {
                        DSMetricCardView(label: "Total Focus", value: "34h 12m")
                        DSMetricCardView(label: "Current Streak", value: "12 Days")
                        DSMetricCardView(label: "Problems Solved", value: "45")
                        DSMetricCardView(label: "Avg. Difficulty", value: "Medium")
                    }
                    .padding(.horizontal, DSSpacing.space16)
                }
                .padding(.top, DSSpacing.space8)
                .padding(.bottom, DSSpacing.space32)
            }
        }
        .background(DSColor.background)
    }
}

#Preview {
    iPhoneStatsView()
}
