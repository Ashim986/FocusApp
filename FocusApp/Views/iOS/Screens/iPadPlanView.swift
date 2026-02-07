// iPadPlanView.swift
// FocusApp — iPad Plan screen (two-column layout)
// Spec: FIGMA_SETUP_GUIDE.md §5.2

import SwiftUI

struct iPadPlanView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.space16) {
            Text("Study Plan")
                .font(DSTypography.headline)
                .foregroundColor(DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.space24)
                .padding(.top, DSSpacing.space24)

            // Two-column layout
            HStack(alignment: .top, spacing: DSSpacing.space12) {
                // Left column: Calendar
                DSCalendarGrid()

                // Right column: Schedule
                VStack(alignment: .leading, spacing: DSSpacing.space12) {
                    Text("Schedule for February 7th")
                        .font(DSTypography.section)
                        .foregroundColor(DSColor.textPrimary)

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

                    Spacer()
                }
            }
            .padding(.horizontal, DSSpacing.space24)

            Spacer()
        }
    }
}

#Preview {
    iPadPlanView()
        .frame(width: 574, height: 1194)
}
