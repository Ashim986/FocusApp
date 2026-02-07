// LegacyDSStreakBadge.swift
// FocusApp — Streak badge (orange pill)
// Spec: FIGMA_SETUP_GUIDE.md §3.10

import SwiftUI

struct LegacyDSStreakBadge: View {
    var streakDays: Int = 12

    var body: some View {
        HStack(spacing: DSLayout.spacing(.space4)) {
            Text("🔥")
                .font(.system(size: 14))

            Text("\(streakDays) Day Streak")
                .font(LegacyDSTypography.subbodyStrong)
                .foregroundColor(LegacyDSColor.streakText)
        }
        .padding(.horizontal, DSLayout.spacing(.space12))
        .padding(.vertical, DSLayout.spacing(.space8))
        .background(LegacyDSColor.streakBg)
        .cornerRadius(LegacyDSRadius.full)
        .overlay(
            Capsule()
                .stroke(LegacyDSColor.streakBorder, lineWidth: 1)
        )
    }
}

#Preview {
    LegacyDSStreakBadge()
}
