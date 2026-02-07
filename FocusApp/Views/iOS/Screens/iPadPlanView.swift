// iPadPlanView.swift
// FocusApp — iPad Plan screen (two-column layout)
// Spec: FIGMA_SETUP_GUIDE.md §5.2

import SwiftUI

struct iPadPlanView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
            Text("Study Plan")
                .font(LegacyDSTypography.headline)
                .foregroundColor(LegacyDSColor.textPrimary)
                .padding(.horizontal, DSLayout.spacing(.space24))
                .padding(.top, DSLayout.spacing(.space24))

            // Two-column layout
            HStack(alignment: .top, spacing: DSLayout.spacing(.space12)) {
                // Left column: Calendar
                LegacyDSCalendarGrid()

                // Right column: Schedule
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
                    Text("Schedule for February 7th")
                        .font(LegacyDSTypography.section)
                        .foregroundColor(LegacyDSColor.textPrimary)

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

                    Spacer()
                }
            }
            .padding(.horizontal, DSLayout.spacing(.space24))

            Spacer()
        }
    }
}

#Preview {
    iPadPlanView()
        .frame(width: 574, height: 1194)
}
