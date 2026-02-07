// iPadTodayView.swift
// FocusApp — iPad Today screen (834x1194)
// Spec: FIGMA_SETUP_GUIDE.md §5.1

import SwiftUI

struct iPadTodayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.space16) {
                // Date + Greeting + Streak
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DSSpacing.space4) {
                        Text("SATURDAY, FEBRUARY 7")
                            .font(DSTypography.captionStrong)
                            .foregroundColor(DSColor.gray500)
                            .textCase(.uppercase)

                        Text("Good Morning, John")
                            .font(DSTypography.title)
                            .foregroundColor(DSColor.textPrimary)
                    }

                    Spacer()

                    DSStreakBadge(streakDays: 12)
                }
                .padding(.horizontal, DSSpacing.space24)
                .padding(.top, DSSpacing.space24)

                // Card strip (3 horizontal cards)
                HStack(spacing: DSSpacing.space12) {
                    // Daily Goal (compact)
                    VStack(alignment: .leading, spacing: DSSpacing.space8) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.white)
                            Text("Daily Goal")
                                .font(DSTypography.captionStrong)
                                .foregroundColor(.white)
                        }
                        Text("1/4")
                            .font(DSTypography.headline)
                            .foregroundColor(.white)
                        Text("Tasks done")
                            .font(DSTypography.caption)
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
                    .padding(DSSpacing.space16)
                    .background(DSColor.purpleGradient)
                    .cornerRadius(DSRadius.medium)

                    // Focus Time (compact)
                    DSSurfaceCard {
                        VStack(alignment: .leading, spacing: DSSpacing.space4) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(DSColor.green)
                                Text("Focus Time")
                                    .font(DSTypography.captionStrong)
                                    .foregroundColor(DSColor.gray500)
                            }
                            Text("2h 15m")
                                .font(DSTypography.headline)
                                .foregroundColor(DSColor.gray900)
                            Text("35m remaining")
                                .font(DSTypography.caption)
                                .foregroundColor(DSColor.gray500)
                        }
                    }

                    // Start Focus (compact)
                    Button { } label: {
                        VStack(spacing: DSSpacing.space4) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(DSColor.purple)
                            Text("Start Focus")
                                .font(DSTypography.captionStrong)
                                .foregroundColor(DSColor.gray900)
                            Text("Get in the zone")
                                .font(DSTypography.caption)
                                .foregroundColor(DSColor.gray500)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(DSColor.surface)
                        .cornerRadius(DSRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.medium)
                                .strokeBorder(
                                    DSColor.divider,
                                    style: StrokeStyle(lineWidth: 1, dash: [4])
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 120)
                .padding(.horizontal, DSSpacing.space24)

                // Today's Plan
                HStack {
                    Text("Today's Plan")
                        .font(DSTypography.section)
                        .foregroundColor(DSColor.textPrimary)

                    Spacer()

                    Button("View Full Plan") { }
                        .font(DSTypography.subbody)
                        .foregroundColor(DSColor.purple)
                }
                .padding(.horizontal, DSSpacing.space24)

                // Task rows
                VStack(spacing: 0) {
                    DSTaskRow(
                        title: "Complete Two Sum",
                        subtitle: "Arrays & Hashing - LeetCode 75",
                        isCompleted: true,
                        difficulty: .easy
                    )
                    Divider().padding(.leading, 52)

                    DSTaskRow(
                        title: "Read System Design Chapter 5",
                        subtitle: "System Design",
                        isCompleted: true
                    )
                    Divider().padding(.leading, 52)

                    DSTaskRow(
                        title: "Review Pull Requests",
                        subtitle: "Code Review",
                        isCompleted: false
                    )
                    Divider().padding(.leading, 52)

                    DSTaskRow(
                        title: "Exercise",
                        isCompleted: true,
                        progressText: "1/4"
                    )
                }
                .background(DSColor.surface)
                .cornerRadius(DSRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.medium)
                        .stroke(DSColor.divider, lineWidth: 1)
                )
                .padding(.horizontal, DSSpacing.space24)
            }
            .padding(.bottom, DSSpacing.space48)
        }
    }
}

#Preview {
    iPadTodayView()
        .frame(width: 574, height: 1194)
}
