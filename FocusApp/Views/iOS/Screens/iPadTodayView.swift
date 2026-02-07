// iPadTodayView.swift
// FocusApp — iPad Today screen (834x1194)
// Spec: FIGMA_SETUP_GUIDE.md §5.1

import SwiftUI

struct iPadTodayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                // Date + Greeting + Streak
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                        Text("SATURDAY, FEBRUARY 7")
                            .font(LegacyDSTypography.captionStrong)
                            .foregroundColor(LegacyDSColor.gray500)
                            .textCase(.uppercase)

                        Text("Good Morning, John")
                            .font(LegacyDSTypography.title)
                            .foregroundColor(LegacyDSColor.textPrimary)
                    }

                    Spacer()

                    LegacyDSStreakBadge(streakDays: 12)
                }
                .padding(.horizontal, DSLayout.spacing(.space24))
                .padding(.top, DSLayout.spacing(.space24))

                // Card strip (3 horizontal cards)
                HStack(spacing: DSLayout.spacing(.space12)) {
                    // Daily Goal (compact)
                    VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.white)
                            Text("Daily Goal")
                                .font(LegacyDSTypography.captionStrong)
                                .foregroundColor(.white)
                        }
                        Text("1/4")
                            .font(LegacyDSTypography.headline)
                            .foregroundColor(.white)
                        Text("Tasks done")
                            .font(LegacyDSTypography.caption)
                            .foregroundColor(.white.opacity(0.8))

                        // Mini progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.3)).frame(height: 4)
                                Capsule().fill(Color.white).frame(width: geo.size.width * 0.25, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(DSLayout.spacing(.space16))
                    .background(LegacyDSColor.purpleGradient)
                    .cornerRadius(LegacyDSRadius.medium)

                    // Focus Time (compact)
                    LegacyDSSurfaceCard {
                        VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(LegacyDSColor.green)
                                Text("Focus Time")
                                    .font(LegacyDSTypography.captionStrong)
                                    .foregroundColor(LegacyDSColor.gray500)
                            }
                            Text("2h 15m")
                                .font(LegacyDSTypography.headline)
                                .foregroundColor(LegacyDSColor.gray900)
                            Text("35m remaining")
                                .font(LegacyDSTypography.caption)
                                .foregroundColor(LegacyDSColor.gray500)
                        }
                    }

                    // Start Focus (compact)
                    Button { } label: {
                        VStack(spacing: DSLayout.spacing(.space4)) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(LegacyDSColor.purple)
                            Text("Start Focus")
                                .font(LegacyDSTypography.captionStrong)
                                .foregroundColor(LegacyDSColor.gray900)
                            Text("Get in the zone")
                                .font(LegacyDSTypography.caption)
                                .foregroundColor(LegacyDSColor.gray500)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(LegacyDSColor.surface)
                        .cornerRadius(LegacyDSRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: LegacyDSRadius.medium)
                                .strokeBorder(
                                    LegacyDSColor.divider,
                                    style: StrokeStyle(lineWidth: 1, dash: [4])
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 120)
                .padding(.horizontal, DSLayout.spacing(.space24))

                // Today's Plan
                HStack {
                    Text("Today's Plan")
                        .font(LegacyDSTypography.section)
                        .foregroundColor(LegacyDSColor.textPrimary)

                    Spacer()

                    Button("View Full Plan") { }
                        .font(LegacyDSTypography.subbody)
                        .foregroundColor(LegacyDSColor.purple)
                }
                .padding(.horizontal, DSLayout.spacing(.space24))

                // Task rows
                VStack(spacing: 0) {
                    LegacyDSTaskRow(
                        title: "Complete Two Sum",
                        subtitle: "Arrays & Hashing - LeetCode 75",
                        isCompleted: true,
                        difficulty: .easy
                    )
                    Divider().padding(.leading, DSLayout.spacing(52))

                    LegacyDSTaskRow(
                        title: "Read System Design Chapter 5",
                        subtitle: "System Design",
                        isCompleted: true
                    )
                    Divider().padding(.leading, DSLayout.spacing(52))

                    LegacyDSTaskRow(
                        title: "Review Pull Requests",
                        subtitle: "Code Review",
                        isCompleted: false
                    )
                    Divider().padding(.leading, DSLayout.spacing(52))

                    LegacyDSTaskRow(
                        title: "Exercise",
                        isCompleted: true,
                        progressText: "1/4"
                    )
                }
                .background(LegacyDSColor.surface)
                .cornerRadius(LegacyDSRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: LegacyDSRadius.medium)
                        .stroke(LegacyDSColor.divider, lineWidth: 1)
                )
                .padding(.horizontal, DSLayout.spacing(.space24))
            }
            .padding(.bottom, DSLayout.spacing(.space48))
        }
    }
}

#Preview {
    iPadTodayView()
        .frame(width: 574, height: 1194)
}
