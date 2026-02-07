// iPadFocusView.swift
// FocusApp — iPad Focus screen (centered timer)
// Spec: FIGMA_SETUP_GUIDE.md §5.4

import SwiftUI

struct iPadFocusView: View {
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: DSSpacing.space32) {
            Spacer()

            // Title
            VStack(spacing: DSSpacing.space8) {
                Text("Deep Work Session")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColor.textPrimary)

                Text("Stay focused and track your progress.")
                    .font(DSTypography.subbody)
                    .foregroundColor(DSColor.gray500)
            }

            // Timer ring (larger on iPad)
            DSTimerRing(
                timeText: "25:00",
                statusText: isRunning ? "RUNNING" : "PAUSED",
                progress: 0.0,
                ringColor: DSColor.purple,
                size: 400
            )

            // Controls
            HStack(spacing: DSSpacing.space12) {
                // Play button (circle)
                Button {
                    isRunning.toggle()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(DSColor.purple)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Reset button
                Button {
                    isRunning = false
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                        .foregroundColor(DSColor.gray500)
                        .frame(width: 48, height: 48)
                        .background(DSColor.surface)
                        .cornerRadius(DSRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.medium)
                                .stroke(DSColor.divider, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            // Stats row
            HStack(spacing: DSSpacing.space48) {
                VStack(spacing: DSSpacing.space4) {
                    Text("3")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColor.textPrimary)
                    Text("SESSIONS")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray400)
                        .kerning(1)
                }

                VStack(spacing: DSSpacing.space4) {
                    Text("75m")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColor.textPrimary)
                    Text("TOTAL FOCUS")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray400)
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
