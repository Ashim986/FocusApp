// iPhoneTodayView.swift
// FocusApp — iPhone Today screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.1

import SwiftUI

struct iPhoneTodayView: View {
    var onSettingsTap: (() -> Void)?
    var onStartFocus: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            LegacyDSHeaderBar(onSettingsTap: onSettingsTap)

            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
                    // Date label
                    Text("FRIDAY, FEBRUARY 6")
                        .font(LegacyDSTypography.captionStrong)
                        .foregroundColor(LegacyDSColor.gray500)
                        .textCase(.uppercase)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Greeting
                    Text("Good Morning, John")
                        .font(LegacyDSTypography.title)
                        .foregroundColor(LegacyDSColor.textPrimary)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Streak badge
                    LegacyDSStreakBadge(streakDays: 12)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Daily Goal Card
                    LegacyDSDailyGoalCard(completed: 1, total: 4)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Focus Time Card
                    LegacyDSFocusTimeCard()
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Start Focus CTA
                    LegacyDSStartFocusCTA(onTap: onStartFocus)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Today's Plan section
                    HStack {
                        Text("Today's Plan")
                            .font(LegacyDSTypography.section)
                            .foregroundColor(LegacyDSColor.textPrimary)

                        Spacer()

                        Button("View Full Plan") { }
                            .font(LegacyDSTypography.subbody)
                            .foregroundColor(LegacyDSColor.purple)
                    }
                    .padding(.horizontal, DSLayout.spacing(.space16))
                    .padding(.top, DSLayout.spacing(.space8))

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
    iPhoneTodayView()
}
