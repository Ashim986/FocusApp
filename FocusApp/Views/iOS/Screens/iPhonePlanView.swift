// iPhonePlanView.swift
// FocusApp — iPhone Plan screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.3

import SwiftUI

struct iPhonePlanView: View {
    var body: some View {
        VStack(spacing: 0) {
            LegacyDSHeaderBar()

            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                    // Title
                    Text("Study Plan")
                        .font(LegacyDSTypography.headline)
                        .foregroundColor(LegacyDSColor.textPrimary)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Calendar
                    LegacyDSCalendarGrid()
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Schedule section
                    Text("Schedule for February 7th")
                        .font(LegacyDSTypography.section)
                        .foregroundColor(LegacyDSColor.textPrimary)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    VStack(spacing: DSLayout.spacing(.space8)) {
                        LegacyDSScheduleRow(
                            time: "09:00 AM",
                            title: "Morning Review",
                            subtitle: "Review yesterday's problems",
                            state: .active
                        )

                        LegacyDSScheduleRow(
                            time: "10:30 AM",
                            title: "Graph Theory",
                            subtitle: "BFS and DFS practice",
                            state: .normal
                        )

                        LegacyDSScheduleRow(
                            time: "02:00 PM",
                            title: "Mock Interview",
                            subtitle: "System Design with Peer",
                            state: .faded
                        )
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
    iPhonePlanView()
}
