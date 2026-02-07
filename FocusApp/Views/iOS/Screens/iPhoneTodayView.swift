// iPhoneTodayView.swift
// FocusApp -- iPhone Today screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneTodayView: View {
    @Environment(\.dsTheme) var theme

    var onSettingsTap: (() -> Void)?
    var onStartFocus: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar

            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    // Date label
                    Text("FRIDAY, FEBRUARY 6")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    // Greeting
                    Text("Good Morning, John")
                        .font(theme.typography.title)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Streak badge
                    streakBadge
                        .padding(.horizontal, theme.spacing.lg)

                    // Daily Goal Card
                    dailyGoalCard(completed: 1, total: 4)
                        .padding(.horizontal, theme.spacing.lg)

                    // Focus Time Card
                    focusTimeCard
                        .padding(.horizontal, theme.spacing.lg)

                    // Start Focus CTA
                    startFocusCTA
                        .padding(.horizontal, theme.spacing.lg)

                    // Today's Plan section
                    HStack {
                        Text("Today's Plan")
                            .font(theme.typography.subtitle)
                            .foregroundColor(theme.colors.textPrimary)

                        Spacer()

                        Button("View Full Plan") { }
                            .font(theme.typography.body)
                            .foregroundColor(Color(hex: 0x6366F1))
                    }
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.sm)

                    // Task rows
                    VStack(spacing: 0) {
                        taskRow(
                            title: "Complete Two Sum",
                            subtitle: "Arrays & Hashing - LeetCode 75",
                            isCompleted: true,
                            difficulty: .easy
                        )
                        Divider().padding(.leading, 52)

                        taskRow(
                            title: "Read System Design Chapter 5",
                            subtitle: "System Design",
                            isCompleted: true,
                            difficulty: nil
                        )
                        Divider().padding(.leading, 52)

                        taskRow(
                            title: "Review Pull Requests",
                            subtitle: "Code Review",
                            isCompleted: false,
                            difficulty: nil
                        )
                        Divider().padding(.leading, 52)

                        taskRow(
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
                    .padding(.horizontal, theme.spacing.lg)
                }
                .padding(.top, theme.spacing.lg)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button {
                onSettingsTap?()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.trailing, theme.spacing.lg)
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        HStack(spacing: theme.spacing.xs) {
            Text("\u{1F525}")
                .font(.system(size: 14))

            Text("12 Day Streak")
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

    private func dailyGoalCard(completed: Int, total: Int) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            // Row 1: Icon + Label
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "target")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                Text("Daily Goal")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()
            }

            // Row 2: Progress count
            VStack(alignment: .leading, spacing: 2) {
                Text("\(completed)/\(total)")
                    .font(theme.typography.title)
                    .foregroundColor(.white)

                Text("Tasks completed")
                    .font(theme.typography.body)
                    .foregroundColor(.white.opacity(0.8))
            }

            // Row 3: Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: total > 0
                                ? geo.size.width * CGFloat(completed) / CGFloat(total)
                                : 0,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(theme.radii.lg)
    }

    // MARK: - Focus Time Card

    private var focusTimeCard: some View {
        HStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(Color(hex: 0xD1FAE5))
                    .frame(width: 40, height: 40)
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 18))
                    .foregroundColor(theme.colors.success)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Focus Time")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x6B7280))

                Text("2h 15m")
                    .font(theme.typography.subtitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("35m remaining today")
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            Spacer()
        }
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

    private var startFocusCTA: some View {
        Button {
            onStartFocus?()
        } label: {
            VStack(spacing: theme.spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x6366F1).opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: 0x6366F1))
                }

                Text("Start Focus Session")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Ready to get in the zone?")
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
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

    // MARK: - Task Row

    private func taskRow(
        title: String,
        subtitle: String?,
        isCompleted: Bool,
        difficulty: TaskDifficulty?,
        progressText: String? = nil
    ) -> some View {
        HStack(spacing: theme.spacing.md) {
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
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        isCompleted ? Color(hex: 0x9CA3AF) : theme.colors.textPrimary
                    )
                    .strikethrough(isCompleted)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }
            }

            Spacer()

            if let progressText {
                Text(progressText)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            if let difficulty {
                difficultyBadge(difficulty)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x9CA3AF))
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 56)
    }

    // MARK: - Difficulty Badge

    private func difficultyBadge(_ difficulty: TaskDifficulty) -> some View {
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

// TaskDifficulty enum is defined in iPadTodayView.swift

#Preview {
    iPhoneTodayView()
}
