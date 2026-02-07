// iPhonePlanView.swift
// FocusApp — iPhone Plan screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.3

import SwiftUI

struct iPhonePlanView: View {
    var body: some View {
        VStack(spacing: 0) {
            DSHeaderBar()

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.space16) {
                    // Title
                    Text("Study Plan")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColor.textPrimary)
                        .padding(.horizontal, DSSpacing.space16)

                    // Calendar
                    DSCalendarGrid()
                        .padding(.horizontal, DSSpacing.space16)

                    // Schedule section
                    Text("Schedule for February 7th")
                        .font(DSTypography.section)
                        .foregroundColor(DSColor.textPrimary)
                        .padding(.horizontal, DSSpacing.space16)

                    VStack(spacing: DSSpacing.space8) {
                        DSScheduleRow(
                            time: "09:00 AM",
                            title: "Morning Review",
                            subtitle: "Review yesterday's problems",
                            state: .active
                        )

                        DSScheduleRow(
                            time: "10:30 AM",
                            title: "Graph Theory",
                            subtitle: "BFS and DFS practice",
                            state: .normal
                        )

                        DSScheduleRow(
                            time: "02:00 PM",
                            title: "Mock Interview",
                            subtitle: "System Design with Peer",
                            state: .faded
                        )
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
    iPhonePlanView()
}
