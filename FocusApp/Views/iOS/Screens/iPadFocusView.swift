// iPadFocusView.swift
// FocusApp — iPad Focus screen (centered timer)
// Spec: FIGMA_SETUP_GUIDE.md §5.4

import SwiftUI

struct iPadFocusView: View {
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: DSLayout.spacing(.space32)) {
            Spacer()

            // Title
            VStack(spacing: DSLayout.spacing(.space8)) {
                Text("Deep Work Session")
                    .font(LegacyDSTypography.headline)
                    .foregroundColor(LegacyDSColor.textPrimary)

                Text("Stay focused and track your progress.")
                    .font(LegacyDSTypography.subbody)
                    .foregroundColor(LegacyDSColor.gray500)
            }

            // Timer ring (larger on iPad)
            LegacyDSTimerRing(
                timeText: "25:00",
                statusText: isRunning ? "RUNNING" : "PAUSED",
                progress: 0.0,
                ringColor: LegacyDSColor.purple,
                size: 400
            )

            // Controls
            HStack(spacing: DSLayout.spacing(.space12)) {
                // Play button (circle)
                Button {
                    isRunning.toggle()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(LegacyDSColor.purple)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Reset button
                Button {
                    isRunning = false
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                        .foregroundColor(LegacyDSColor.gray500)
                        .frame(width: 48, height: 48)
                        .background(LegacyDSColor.surface)
                        .cornerRadius(LegacyDSRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: LegacyDSRadius.medium)
                                .stroke(LegacyDSColor.divider, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            // Stats row
            HStack(spacing: DSLayout.spacing(.space48)) {
                VStack(spacing: DSLayout.spacing(.space4)) {
                    Text("3")
                        .font(LegacyDSTypography.headline)
                        .foregroundColor(LegacyDSColor.textPrimary)
                    Text("SESSIONS")
                        .font(LegacyDSTypography.captionStrong)
                        .foregroundColor(LegacyDSColor.gray400)
                        .kerning(1)
                }

                VStack(spacing: DSLayout.spacing(.space4)) {
                    Text("75m")
                        .font(LegacyDSTypography.headline)
                        .foregroundColor(LegacyDSColor.textPrimary)
                    Text("TOTAL FOCUS")
                        .font(LegacyDSTypography.captionStrong)
                        .foregroundColor(LegacyDSColor.gray400)
                        .kerning(1)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    iPadFocusView()
        .frame(width: 574, height: 1194)
}
