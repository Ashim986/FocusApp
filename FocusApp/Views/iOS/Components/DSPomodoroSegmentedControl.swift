// LegacyDSPomodoroSegmentedControl.swift
// FocusApp — Pomodoro segmented control (329x44)
// Spec: FIGMA_SETUP_GUIDE.md §3.12

import SwiftUI

enum LegacyPomodoroSegment: String, CaseIterable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var iconName: String {
        switch self {
        case .focus: return "scope"
        case .shortBreak: return "cup.and.saucer"
        case .longBreak: return "moon"
        }
    }
}

struct LegacyDSPomodoroSegmentedControl: View {
    @Binding var selected: LegacyPomodoroSegment

    var body: some View {
        HStack(spacing: 0) {
            ForEach(LegacyPomodoroSegment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = segment
                    }
                } label: {
                    HStack(spacing: DSLayout.spacing(.space4)) {
                        Image(systemName: segment.iconName)
                            .font(.system(size: 14))
                        Text(segment.rawValue)
                            .font(LegacyDSTypography.subbodyStrong)
                    }
                    .foregroundColor(
                        selected == segment ? LegacyDSColor.gray900 : LegacyDSColor.gray500
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        selected == segment
                            ? LegacyDSColor.surface
                                .shadow(.drop(color: .black.opacity(0.05), radius: 3, y: 1))
                            : Color.clear
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DSLayout.spacing(.space4))
        .background(LegacyDSColor.gray100)
        .clipShape(Capsule())
    }
}

#Preview {
    LegacyDSPomodoroSegmentedControl(selected: .constant(.focus))
        .padding()
}
