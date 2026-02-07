// DSScheduleRow.swift
// FocusApp — Schedule row (72px height)
// Spec: FIGMA_SETUP_GUIDE.md §3.17

import SwiftUI

enum ScheduleRowState {
    case active
    case normal
    case faded
}

struct DSScheduleRow: View {
    var time: String
    var title: String
    var subtitle: String
    var state: ScheduleRowState = .normal

    var body: some View {
        HStack(spacing: DSSpacing.space16) {
            Text(time)
                .font(DSTypography.subbodyStrong)
                .foregroundColor(timeColor)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: DSSpacing.space2) {
                Text(title)
                    .font(DSTypography.bodyStrong)
                    .foregroundColor(DSColor.gray900)

                Text(subtitle)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColor.gray500)
            }

            Spacer()
        }
        .padding(DSSpacing.space16)
        .frame(height: 72)
        .background(backgroundColor)
        .cornerRadius(DSRadius.medium)
        .opacity(state == .faded ? 0.5 : 1.0)
    }

    private var timeColor: Color {
        switch state {
        case .active: return DSColor.purple
        case .normal: return DSColor.gray500
        case .faded: return DSColor.gray400
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .active: return DSColor.purple.opacity(0.08)
        case .normal, .faded: return Color.clear
        }
    }
}

#Preview {
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
    .padding()
}
