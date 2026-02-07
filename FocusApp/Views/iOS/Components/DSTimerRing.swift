// DSTimerRing.swift
// FocusApp — Timer ring (280x280 iPhone, 400x400 iPad)
// Spec: FIGMA_SETUP_GUIDE.md §3.13

import SwiftUI

struct DSTimerRing: View {
    var timeText: String = "25:00"
    var statusText: String = "PAUSED"
    var progress: Double = 0.0 // 0.0 to 1.0
    var ringColor: Color = DSColor.red
    var size: CGFloat = 280

    var body: some View {
        ZStack {
            // Track circle
            Circle()
                .stroke(DSColor.gray200, lineWidth: 8)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Dot indicator at progress position
            if progress > 0 {
                Circle()
                    .fill(ringColor)
                    .frame(width: 12, height: 12)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * progress - 90))
            }

            // Center text
            VStack(spacing: DSSpacing.space4) {
                Text(timeText)
                    .font(DSTypography.timerLarge)
                    .foregroundColor(DSColor.gray900)

                Text(statusText)
                    .font(DSTypography.captionStrong)
                    .foregroundColor(DSColor.gray400)
                    .kerning(2)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        DSTimerRing(progress: 0.0)
        DSTimerRing(
            timeText: "24:54",
            statusText: "RUNNING",
            progress: 0.004,
            ringColor: DSColor.red
        )
    }
}
