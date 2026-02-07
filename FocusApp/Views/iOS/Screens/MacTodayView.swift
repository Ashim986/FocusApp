// MacTodayView.swift
// FocusApp -- Mac Today screen (1200x760)

import FocusDesignSystem
import SwiftUI

struct MacTodayView: View {
    @Environment(\.dsTheme) var theme

    var onStartFocus: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Greeting row with streak badge
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("SATURDAY, FEBRUARY 7")
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.colors.textSecondary)
                            .textCase(.uppercase)

                        Text("Good Morning, John")
                            .font(theme.typography.title)
                            .foregroundColor(theme.colors.textPrimary)
                    }

                    Spacer()

                    macStreakBadge(days: 12)
                }
                .padding(.horizontal, theme.spacing.xl)
                .padding(.top, theme.spacing.xl)

                // Horizontal card strip
                HStack(spacing: theme.spacing.lg) {
                    // Daily Goal Card (purple gradient)
                    macDailyGoalCard(completed: 1, total: 4)

                    // Focus Time Card
                    macFocusTimeCard

                    // Start Focus CTA
                    macStartFocusCTA
                }
                .frame(height: 140)
                .padding(.horizontal, theme.spacing.xl)

                // Today's Plan section header
                HStack {
                    Text("Today's Plan")
                        .font(theme.typography.subtitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    DSButton(
                        "View Full Plan",
                        config: DSButtonConfig(style: .ghost, size: .small)
                    ) { }
                }
                .padding(.horizontal, theme.spacing.xl)

                // Task rows
                VStack(spacing: 0) {
                    macTaskRow(
                        title: "Complete Two Sum",
                        subtitle: "Arrays & Hashing - LeetCode 75",
                        isCompleted: true,
                        difficulty: .easy
                    )
                    Divider().padding(.leading, 52)

                    macTaskRow(
                        title: "Read System Design Chapter 5",
                        subtitle: "System Design",
                        isCompleted: true,
                        difficulty: nil
                    )
                    Divider().padding(.leading, 52)

                    macTaskRow(
                        title: "Review Pull Requests",
                        subtitle: "Code Review",
                        isCompleted: false,
                        difficulty: nil
                    )
                    Divider().padding(.leading, 52)

                    macTaskRow(
                        title: "Implement Binary Search",
                        subtitle: "Searching - LeetCode 75",
                        isCompleted: false,
                        difficulty: .medium
                    )
                    Divider().padding(.leading, 52)

                    macTaskRow(
                        title: "Exercise",
                        subtitle: nil,
                        isCompleted: true,
                        difficulty: nil,
                        progressText: "1/4"
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
            .padding(.bottom, 32)
        }
        .background(theme.colors.background)
    }

    // MARK: - Streak Badge

    private func macStreakBadge(days: Int) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Text("\u{1F525}")
                .font(.system(size: 14))

            Text("\(days) Day Streak")
                .font(theme.typography.body)
                .fontWeight(.semibold)
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

    // MARK: - Daily Goal Card

    private func macDailyGoalCard(completed: Int, total: Int) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 28, height: 28)
                    Image(systemName: "target")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }

                Text("Daily Goal")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text("\(completed)/\(total)")
                .font(theme.typography.title)
                .foregroundColor(.white)

            Text("Tasks done")
                .font(theme.typography.caption)
                .foregroundColor(.white.opacity(0.8))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: total > 0
                                ? geo.size.width * CGFloat(completed) / CGFloat(total)
                                : 0,
                            height: 4
                        )
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

    // MARK: - Focus Time Card

    private var macFocusTimeCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(theme.colors.success)
                Text("Focus Time")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Text("2h 15m")
                .font(theme.typography.subtitle)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.textPrimary)

            Text("35m remaining")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Start Focus CTA

    private var macStartFocusCTA: some View {
        DSActionButton(action: {
            onStartFocus?()
        } label: {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6366F1))

                Text("Start Focus")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Get in the zone")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
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
    }

    // MARK: - Task Row

    private func macTaskRow(
        title: String,
        subtitle: String?,
        isCompleted: Bool,
        difficulty: TaskDifficulty?,
        progressText: String? = nil
    ) -> some View {
        HStack(spacing: theme.spacing.md) {
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

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        isCompleted ? Color(hex: 0x9CA3AF) : theme.colors.textPrimary
                    )
                    .strikethrough(isCompleted)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Spacer()

            if let progressText {
                Text(progressText)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textSecondary)
            }

            if let difficulty {
                macDifficultyBadge(difficulty)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x9CA3AF))
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    // MARK: - Difficulty Badge

    private func macDifficultyBadge(_ difficulty: TaskDifficulty) -> some View {
        Text(difficulty.rawValue)
            .font(theme.typography.caption)
            .fontWeight(.semibold)
            .foregroundColor(difficulty.textColor)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(difficulty.bgColor)
            .cornerRadius(theme.radii.sm)
    }
}

#Preview("Mac Today") {
    MacTodayView()
        .frame(width: 1200, height: 760)
}
