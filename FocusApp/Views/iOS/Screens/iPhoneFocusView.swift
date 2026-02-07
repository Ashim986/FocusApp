// iPhoneFocusView.swift
// FocusApp — iPhone Focus (Pomodoro) screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.6 & §4.7

import SwiftUI

struct iPhoneFocusView: View {
    @State private var selectedSegment: PomodoroSegment = .focus
    @State private var isRunning = false
    @State private var progress: Double = 0.0
    @State private var sessionCount = 0

    var body: some View {
        VStack(spacing: 0) {
            // Custom header (no standard header bar for Focus)
            HStack {
                Text("Focus")
                    .font(DSTypography.section)
                    .foregroundColor(DSColor.textPrimary)

                Spacer()

                // Sessions badge
                Text("Sessions: \(sessionCount)")
                    .font(DSTypography.subbodyStrong)
                    .foregroundColor(DSColor.gray600)
                    .padding(.horizontal, DSSpacing.space12)
                    .padding(.vertical, DSSpacing.space4)
                    .background(DSColor.gray100)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, DSSpacing.space16)
            .padding(.top, DSSpacing.space8)

            ScrollView {
                VStack(spacing: DSSpacing.space24) {
                    // Timer card
                    VStack(spacing: DSSpacing.space16) {
                        // Segmented control
                        DSPomodoroSegmentedControl(selected: $selectedSegment)
                            .padding(.horizontal, DSSpacing.space16)

                        // Timer ring
                        DSTimerRing(
                            timeText: isRunning ? "24:54" : "25:00",
                            statusText: isRunning ? "RUNNING" : "PAUSED",
                            progress: isRunning ? 0.004 : 0.0,
                            ringColor: DSColor.red
                        )
                        .padding(.vertical, DSSpacing.space16)

                        // Buttons
                        HStack(spacing: DSSpacing.space12) {
                            // Start/Pause button
                            Button {
                                isRunning.toggle()
                            } label: {
                                HStack(spacing: DSSpacing.space8) {
                                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 16))
                                    Text(isRunning ? "Pause" : "Start")
                                        .font(DSTypography.bodyStrong)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, DSSpacing.space16)
                                .frame(height: 48)
                                .background(DSColor.red)
                                .cornerRadius(DSRadius.medium)
                            }
                            .buttonStyle(.plain)

                            // Reset button
                            Button {
                                isRunning = false
                                progress = 0
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
                    }
                    .padding(DSSpacing.space16)
                    .background(DSColor.redLight)
                    .cornerRadius(DSRadius.large)
                    .padding(.horizontal, DSSpacing.space16)

                    // Current Focus section
                    VStack(spacing: DSSpacing.space4) {
                        Text("CURRENT FOCUS")
                            .font(DSTypography.captionStrong)
                            .foregroundColor(DSColor.gray400)
                            .textCase(.uppercase)

                        Text("No active tasks")
                            .font(DSTypography.subbody)
                            .foregroundColor(DSColor.gray400)
                            .italic()
                    }

                    // Tasks card
                    DSSurfaceCard {
                        VStack(alignment: .leading, spacing: DSSpacing.space8) {
                            Text("Tasks 0")
                                .font(DSTypography.bodyStrong)
                                .foregroundColor(DSColor.textPrimary)

                            Text("No tasks linked to this session")
                                .font(DSTypography.subbody)
                                .foregroundColor(DSColor.gray400)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, DSSpacing.space16)
                }
                .padding(.top, DSSpacing.space16)
                .padding(.bottom, DSSpacing.space32)
            }
        }
        .background(DSColor.background)
    }
}

#Preview {
    iPhoneFocusView()
}
