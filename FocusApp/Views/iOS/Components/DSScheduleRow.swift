// LegacyDSScheduleRow.swift
// FocusApp — Schedule row (72px height)
// Spec: FIGMA_SETUP_GUIDE.md §3.17

import SwiftUI

enum LegacyScheduleRowState {
    case active
    case normal
    case faded
}

struct LegacyDSScheduleRow: View {
    var time: String
    var title: String
    var subtitle: String
    var state: LegacyScheduleRowState = .normal

    var body: some View {
        HStack(spacing: DSLayout.spacing(.space16)) {
            Text(time)
                .font(LegacyDSTypography.subbodyStrong)
                .foregroundColor(timeColor)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                Text(title)
                    .font(LegacyDSTypography.bodyStrong)
                    .foregroundColor(LegacyDSColor.gray900)

                Text(subtitle)
                    .font(LegacyDSTypography.caption)
                    .foregroundColor(LegacyDSColor.gray500)
            }

            Spacer()
        }
        .padding(DSLayout.spacing(.space16))
        .frame(height: 72)
        .background(backgroundColor)
        .cornerRadius(LegacyDSRadius.medium)
        .opacity(state == .faded ? 0.5 : 1.0)
    }

    private var timeColor: Color {
        switch state {
        case .active: return LegacyDSColor.purple
        case .normal: return LegacyDSColor.gray500
        case .faded: return LegacyDSColor.gray400
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .active: return LegacyDSColor.purple.opacity(0.08)
        case .normal, .faded: return Color.clear
        }
    }
}

#Preview {
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
    .padding()
}
