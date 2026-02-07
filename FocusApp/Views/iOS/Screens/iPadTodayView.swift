// iPadTodayView.swift
// FocusApp — iPad Today screen (834x1194)
// Spec: FIGMA_SETUP_GUIDE.md §5.1

import FocusDesignSystem
import SwiftUI

// MARK: - Difficulty Badge

enum TaskDifficulty: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var bgColor: Color {
        switch self {
        case .easy: return Color(hex: 0xD1FAE5)
        case .medium: return Color(hex: 0xFEF3C7)
        case .hard: return Color(hex: 0xFEE2E2)
        }
    }

    var textColor: Color {
        switch self {
        case .easy: return Color(hex: 0x059669)
        case .medium: return Color(hex: 0xD97706)
        case .hard: return Color(hex: 0xDC2626)
        }
    }
}

struct iPadTodayView: View {
    @Environment(\.dsTheme) var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                // Date + Greeting + Streak
                headerSection

                // Card strip (3 horizontal cards)
                cardStrip

                // Today's Plan header
                planHeader

                // Task rows
                taskList
            }
            .padding(.bottom, 48)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("SATURDAY, FEBRUARY 7")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6B7280))
                    .textCase(.uppercase)

                Text("Good Morning, John")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
            }

            Spacer()

            // Streak badge
            streakBadge
        }
        .padding(.horizontal, theme.spacing.xl)
        .padding(.top, theme.spacing.xl)
    }

    private var streakBadge: some View {
        HStack(spacing: theme.spacing.xs) {
            Text("\u{1F525}")
                .font(.system(size: 14))

            Text("12 Day Streak")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: 0xEA580C))
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(Color(hex: 0xFFF7ED))
        .cornerRadius(theme.radii.pill)
        .overlay(
            Capsule()
                .stroke(Color(hex: 0xFDBA74), lineWidth: 1)
        )
    }

    // MARK: - Card Strip

    private var cardStrip: some View {
        HStack(spacing: theme.spacing.md) {
            // Daily Goal (gradient card)
            dailyGoalCard

            // Focus Time
            focusTimeCard

            // Start Focus
            startFocusCard
        }
        .frame(height: 120)
        .padding(.horizontal, theme.spacing.xl)
    }

    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.white)
                Text("Daily Goal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text("1/4")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text("Tasks done")
                .font(theme.typography.caption)
                .foregroundColor(.white.opacity(0.8))

            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * 0.25, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(theme.spacing.lg)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(theme.radii.md)
    }

    private var focusTimeCard: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(theme.colors.success)
                    Text("Focus Time")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: 0x6B7280))
                }
                Text("2h 15m")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("35m remaining")
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }
        }
    }

    private var startFocusCard: some View {
        Button { } label: {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6366F1))
                Text("Start Focus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("Get in the zone")
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.surface)
            .cornerRadius(theme.radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.md)
                    .strokeBorder(
                        theme.colors.border,
                        style: StrokeStyle(lineWidth: 1, dash: [4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Plan Header

    private var planHeader: some View {
        HStack {
            Text("Today's Plan")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)

            Spacer()

            Button("View Full Plan") { }
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: 0x6366F1))
        }
        .padding(.horizontal, theme.spacing.xl)
    }

    // MARK: - Task List

    private var taskList: some View {
        VStack(spacing: 0) {
            iPadTaskRow(
                title: "Complete Two Sum",
                subtitle: "Arrays & Hashing - LeetCode 75",
                isCompleted: true,
                difficulty: .easy,
                theme: theme
            )
            Divider().padding(.leading, 52)

            iPadTaskRow(
                title: "Read System Design Chapter 5",
                subtitle: "System Design",
                isCompleted: true,
                theme: theme
            )
            Divider().padding(.leading, 52)

            iPadTaskRow(
                title: "Review Pull Requests",
                subtitle: "Code Review",
                isCompleted: false,
                theme: theme
            )
            Divider().padding(.leading, 52)

            iPadTaskRow(
                title: "Exercise",
                isCompleted: true,
                progressText: "1/4",
                theme: theme
            )
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .padding(.horizontal, theme.spacing.xl)
    }
}

// MARK: - Task Row

private struct iPadTaskRow: View {
    var title: String
    var subtitle: String?
    var isCompleted: Bool = false
    var difficulty: TaskDifficulty?
    var progressText: String?
    var theme: DSTheme

    var body: some View {
        HStack(spacing: 12) {
            // Check icon
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x6366F1))
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Circle()
                    .strokeBorder(
                        Color(hex: 0xD1D5DB),
                        style: StrokeStyle(lineWidth: 1.5, dash: [3])
                    )
                    .frame(width: 24, height: 24)
            }

            // Title + Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        isCompleted
                            ? Color(hex: 0x9CA3AF)
                            : theme.colors.textPrimary
                    )
                    .strikethrough(isCompleted)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }
            }

            Spacer()

            // Progress text
            if let progressText {
                Text(progressText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            // Difficulty badge
            if let difficulty {
                Text(difficulty.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(difficulty.textColor)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(difficulty.bgColor)
                    .cornerRadius(theme.radii.sm)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x9CA3AF))
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }
}

#Preview {
    iPadTodayView()
        .frame(width: 574, height: 1194)
}
