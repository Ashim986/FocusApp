// DSStreakBadge.swift
// FocusApp — Streak badge (orange pill)
// Spec: FIGMA_SETUP_GUIDE.md §3.10

import SwiftUI

struct DSStreakBadge: View {
    var streakDays: Int = 12

    var body: some View {
        HStack(spacing: DSSpacing.space4) {
            Text("🔥")
                .font(.system(size: 14))

            Text("\(streakDays) Day Streak")
                .font(DSTypography.subbodyStrong)
                .foregroundColor(DSColor.streakText)
        }
        .padding(.horizontal, DSSpacing.space12)
        .padding(.vertical, DSSpacing.space8)
        .background(DSColor.streakBg)
        .cornerRadius(DSRadius.full)
        .overlay(
            Capsule()
                .stroke(DSColor.streakBorder, lineWidth: 1)
        )
    }
}

#Preview {
    DSStreakBadge()
}
