// iPhoneFocusView.swift
// FocusApp — iPhone Focus (Pomodoro) screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.6 & §4.7

import SwiftUI

struct iPhoneFocusView: View {
    @State private var selectedSegment: LegacyPomodoroSegment = .focus
    @State private var isRunning = false
    @State private var progress: Double = 0.0
    @State private var sessionCount = 0

    var body: some View {
        VStack(spacing: 0) {
            // Custom header (no standard header bar for Focus)
            HStack {
                Text("Focus")
                    .font(LegacyDSTypography.section)
                    .foregroundColor(LegacyDSColor.textPrimary)

                Spacer()

                // Sessions badge
                Text("Sessions: \(sessionCount)")
                    .font(LegacyDSTypography.subbodyStrong)
                    .foregroundColor(LegacyDSColor.gray600)
                    .padding(.horizontal, DSLayout.spacing(.space12))
                    .padding(.vertical, DSLayout.spacing(.space4))
                    .background(LegacyDSColor.gray100)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, DSLayout.spacing(.space16))
            .padding(.top, DSLayout.spacing(.space8))

            ScrollView {
                VStack(spacing: DSLayout.spacing(.space24)) {
                    // Timer card
                    VStack(spacing: DSLayout.spacing(.space16)) {
                        // Segmented control
                        LegacyDSPomodoroSegmentedControl(selected: $selectedSegment)
                            .padding(.horizontal, DSLayout.spacing(.space16))

                        // Timer ring
                        LegacyDSTimerRing(
                            timeText: isRunning ? "24:54" : "25:00",
                            statusText: isRunning ? "RUNNING" : "PAUSED",
                            progress: isRunning ? 0.004 : 0.0,
                            ringColor: LegacyDSColor.red
                        )
                        .padding(.vertical, DSLayout.spacing(.space16))

                        // Buttons
                        HStack(spacing: DSLayout.spacing(.space12)) {
                            // Start/Pause button
                            Button {
                                isRunning.toggle()
                            } label: {
                                HStack(spacing: DSLayout.spacing(.space8)) {
                                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 16))
                                    Text(isRunning ? "Pause" : "Start")
                                        .font(LegacyDSTypography.bodyStrong)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, DSLayout.spacing(.space16))
                                .frame(height: 48)
                                .background(LegacyDSColor.red)
                                .cornerRadius(LegacyDSRadius.medium)
                            }
                            .buttonStyle(.plain)

                            // Reset button
                            Button {
                                isRunning = false
                                progress = 0
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
                    }
                    .padding(DSLayout.spacing(.space16))
                    .background(LegacyDSColor.redLight)
                    .cornerRadius(LegacyDSRadius.large)
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    // Current Focus section
                    VStack(spacing: DSLayout.spacing(.space4)) {
                        Text("CURRENT FOCUS")
                            .font(LegacyDSTypography.captionStrong)
                            .foregroundColor(LegacyDSColor.gray400)
                            .textCase(.uppercase)

                        Text("No active tasks")
                            .font(LegacyDSTypography.subbody)
                            .foregroundColor(LegacyDSColor.gray400)
                            .italic()
                    }

                    // Tasks card
                    LegacyDSSurfaceCard {
                        VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                            Text("Tasks 0")
                                .font(LegacyDSTypography.bodyStrong)
                                .foregroundColor(LegacyDSColor.textPrimary)

                            Text("No tasks linked to this session")
                                .font(LegacyDSTypography.subbody)
                                .foregroundColor(LegacyDSColor.gray400)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, DSLayout.spacing(.space16))
                }
                .padding(.top, DSLayout.spacing(.space16))
                .padding(.bottom, DSLayout.spacing(.space32))
            }
        }
        .background(LegacyDSColor.background)
    }
}

#Preview {
    iPhoneFocusView()
}
