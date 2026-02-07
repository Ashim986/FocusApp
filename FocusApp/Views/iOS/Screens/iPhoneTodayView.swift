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
            DSHeaderBar(onSettingsTap: onSettingsTap)

            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.space12) {
                    // Date label
                    Text("FRIDAY, FEBRUARY 6")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray500)
                        .textCase(.uppercase)
                        .padding(.horizontal, DSSpacing.space16)

                    // Greeting
                    Text("Good Morning, John")
                        .font(DSTypography.title)
                        .foregroundColor(DSColor.textPrimary)
                        .padding(.horizontal, DSSpacing.space16)

                    // Streak badge
                    DSStreakBadge(streakDays: 12)
                        .padding(.horizontal, DSSpacing.space16)

                    // Daily Goal Card
                    DSDailyGoalCard(completed: 1, total: 4)
                        .padding(.horizontal, DSSpacing.space16)

                    // Focus Time Card
                    DSFocusTimeCard()
                        .padding(.horizontal, DSSpacing.space16)

                    // Start Focus CTA
                    DSStartFocusCTA(onTap: onStartFocus)
                        .padding(.horizontal, DSSpacing.space16)

                    // Today's Plan section
                    HStack {
                        Text("Today's Plan")
                            .font(DSTypography.section)
                            .foregroundColor(DSColor.textPrimary)

                        Spacer()

                        Button("View Full Plan") { }
                            .font(DSTypography.subbody)
                            .foregroundColor(DSColor.purple)
                    }
                    .padding(.horizontal, DSSpacing.space16)
                    .padding(.top, DSSpacing.space8)

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
    iPhoneTodayView()
}
