#if os(iOS)
// iPhoneTodayView.swift
// FocusApp -- iPhone Today screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneTodayView: View {
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    @ObservedObject var presenter: TodayPresenter
    var onSettingsTap: () -> Void
    var onStartFocus: () -> Void

    private var todayDay: TodayDayViewModel? {
        presenter.visibleDays.last(where: { $0.isToday })
    }

    private var completedCount: Int {
        todayDay?.completedCount ?? 0
    }

    private var totalCount: Int {
        todayDay?.totalCount ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar

            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    // Date label
                    Text(currentDateString.uppercased())
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    // Greeting
                    Text("Today")
                        .font(theme.typography.title)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Streak badge
                    streakBadge
                        .padding(.horizontal, theme.spacing.lg)

                    // Daily Goal Card
                    dailyGoalCard(completed: completedCount, total: totalCount)
                        .padding(.horizontal, theme.spacing.lg)

                    // Habits section
                    habitsSection
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

                        if presenter.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Button {
                                presenter.syncNow()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14))
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.sm)

                    // Sync status
                    if !presenter.lastSyncResult.isEmpty {
                        Text(presenter.lastSyncResult)
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))
                            .padding(.horizontal, theme.spacing.lg)
                    }

                    // Problem rows from presenter
                    if let today = todayDay {
                        VStack(spacing: 0) {
                            ForEach(Array(today.problems.enumerated()), id: \.element.id) { index, vm in
                                if index > 0 {
                                    Divider().padding(.leading, 52)
                                }
                                problemRow(vm: vm, dayId: today.id)
                            }
                        }
                        .background(theme.colors.surface)
                        .cornerRadius(theme.radii.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.md)
                                .stroke(theme.colors.border, lineWidth: 1)
                        )
                        .padding(.horizontal, theme.spacing.lg)
                    }

                    // Carryover days (incomplete problems from previous days)
                    ForEach(presenter.visibleDays.filter({ !$0.isToday && !$0.problems.isEmpty })) { day in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Text("Day \(day.id): \(day.topic)")
                                .font(theme.typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: 0xEA580C))
                                .padding(.horizontal, theme.spacing.lg)

                            VStack(spacing: 0) {
                                ForEach(Array(day.problems.enumerated()), id: \.element.id) { index, vm in
                                    if index > 0 {
                                        Divider().padding(.leading, 52)
                                    }
                                    problemRow(vm: vm, dayId: day.id)
                                }
                            }
                            .background(theme.colors.surface)
                            .cornerRadius(theme.radii.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radii.md)
                                    .stroke(theme.colors.border, lineWidth: 1)
                            )
                            .padding(.horizontal, theme.spacing.lg)
                        }
                    }
                }
                .padding(.top, theme.spacing.lg)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Current Date String

    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
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
                onSettingsTap()
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
        let habitsCount = presenter.habitsCompletedCount
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xEA580C))

            Text("\(habitsCount)/3 Habits Today")
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

                Text("Problems completed")
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

    // MARK: - Habits Section

    private var habitsSection: some View {
        HStack(spacing: theme.spacing.md) {
            ForEach(presenter.habits) { habit in
                Button {
                    presenter.toggleHabit(habit.id)
                } label: {
                    VStack(spacing: theme.spacing.xs) {
                        ZStack {
                            Circle()
                                .fill(
                                    habit.isCompleted
                                        ? Color(hex: 0xD1FAE5)
                                        : Color(hex: 0xF3F4F6)
                                )
                                .frame(width: 40, height: 40)
                            Image(systemName: habit.icon)
                                .font(.system(size: 18))
                                .foregroundColor(
                                    habit.isCompleted
                                        ? theme.colors.success
                                        : Color(hex: 0x6B7280)
                                )
                        }

                        Text(habit.title)
                            .font(theme.typography.caption)
                            .foregroundColor(
                                habit.isCompleted
                                    ? theme.colors.success
                                    : Color(hex: 0x6B7280)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacing.md)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(
                                habit.isCompleted
                                    ? theme.colors.success.opacity(0.3)
                                    : theme.colors.border,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Start Focus CTA

    private var startFocusCTA: some View {
        Button {
            onStartFocus()
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

    // MARK: - Problem Row

    private func problemRow(vm: TodayProblemViewModel, dayId: Int) -> some View {
        Button {
            if let url = URL(string: vm.problem.url) {
                openURL(url)
            }
        } label: {
            HStack(spacing: theme.spacing.md) {
                // Check icon
                if vm.isCompleted {
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
                    Text(vm.problem.name)
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            vm.isCompleted ? Color(hex: 0x9CA3AF) : theme.colors.textPrimary
                        )
                        .strikethrough(vm.isCompleted)

                    if let number = vm.problem.leetcodeNumber {
                        Text("LeetCode #\(number)")
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))
                    }
                }

                Spacer()

                difficultyBadge(vm.problem.difficulty)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x9CA3AF))
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Difficulty Badge

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        Text(difficulty.rawValue)
            .font(theme.typography.caption)
            .fontWeight(.semibold)
            .foregroundColor(difficultyTextColor(difficulty))
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(difficultyBgColor(difficulty))
            .cornerRadius(theme.radii.sm)
    }

    private func difficultyTextColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Color(hex: 0x059669)
        case .medium: return Color(hex: 0xD97706)
        case .hard: return Color(hex: 0xDC2626)
        }
    }

    private func difficultyBgColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Color(hex: 0xD1FAE5)
        case .medium: return Color(hex: 0xFEF3C7)
        case .hard: return Color(hex: 0xFEE2E2)
        }
    }
}
#endif
