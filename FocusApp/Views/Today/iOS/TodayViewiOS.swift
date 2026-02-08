// swiftlint:disable file_length
#if os(iOS)
// TodayViewiOS.swift
// FocusApp -- Unified Today screen for iPhone and iPad
// Uses horizontalSizeClass to branch between compact (iPhone) and regular (iPad) layouts

import FocusDesignSystem
import SwiftUI

// swiftlint:disable:next type_body_length
struct TodayViewiOS: View {
    @ObservedObject var presenter: TodayPresenter
    var onSettingsTap: () -> Void
    var onStartFocus: () -> Void

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    var body: some View {
        if sizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Shared Computed Properties

    private var todayDay: TodayDayViewModel? {
        presenter.visibleDays.first(where: { $0.isToday })
    }

    private var completedCount: Int {
        todayDay?.completedCount ?? 0
    }

    private var totalCount: Int {
        todayDay?.totalCount ?? 0
    }

    private var carryoverDays: [TodayDayViewModel] {
        presenter.visibleDays.filter { !$0.isToday && !$0.problems.isEmpty }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            compactHeaderBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    // Date label
                    Text(formattedDateUppercased)
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                        .textCase(.uppercase)
                        .padding(.horizontal, theme.spacing.lg)

                    // Title
                    Text("Today")
                        .font(theme.typography.title)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Streak badge
                    compactStreakBadge
                        .padding(.horizontal, theme.spacing.lg)

                    // Daily Goal Card
                    compactDailyGoalCard
                        .padding(.horizontal, theme.spacing.lg)

                    // Habits section
                    compactHabitsSection
                        .padding(.horizontal, theme.spacing.lg)

                    // Start Focus CTA
                    compactStartFocusCTA
                        .padding(.horizontal, theme.spacing.lg)

                    // Today's Plan header with sync
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

                    // Problem rows for today
                    if let today = todayDay {
                        VStack(spacing: 0) {
                            ForEach(
                                Array(today.problems.enumerated()),
                                id: \.element.id
                            ) { index, problemVM in
                                if index > 0 {
                                    Divider().padding(.leading, 52)
                                }
                                TaskRow(
                                    title: problemVM.problem.name,
                                    subtitle: problemVM.problem.leetcodeNumber.map {
                                        "LeetCode #\($0)"
                                    },
                                    isCompleted: problemVM.isCompleted,
                                    difficulty: problemVM.problem.difficulty,
                                    theme: theme,
                                    onTap: {
                                        if let url = URL(string: problemVM.problem.url) {
                                            openURL(url)
                                        }
                                    }
                                )
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

                    // Carryover days
                    ForEach(carryoverDays) { day in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Text("Day \(day.id): \(day.topic)")
                                .font(theme.typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: 0xEA580C))
                                .padding(.horizontal, theme.spacing.lg)

                            VStack(spacing: 0) {
                                ForEach(
                                    Array(day.problems.enumerated()),
                                    id: \.element.id
                                ) { index, problemVM in
                                    if index > 0 {
                                        Divider().padding(.leading, 52)
                                    }
                                    TaskRow(
                                        title: problemVM.problem.name,
                                        subtitle: problemVM.problem.leetcodeNumber.map {
                                            "LeetCode #\($0)"
                                        },
                                        isCompleted: problemVM.isCompleted,
                                        difficulty: problemVM.problem.difficulty,
                                        theme: theme,
                                        onTap: {
                                            if let url = URL(
                                                string: problemVM.problem.url
                                            ) {
                                                openURL(url)
                                            }
                                        }
                                    )
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

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                regularHeaderSection
                regularCardStrip
                regularPlanHeader

                if let today = todayDay {
                    regularTaskList(for: today)
                }

                // Carryover days
                ForEach(carryoverDays) { day in
                    regularCarryoverSection(for: day)
                }
            }
            .padding(.bottom, 48)
        }
        .onAppear {
            presenter.syncNow()
        }
    }

    // MARK: - Compact Header Bar

    private var compactHeaderBar: some View {
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

    // MARK: - Compact Streak Badge

    private var compactStreakBadge: some View {
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

    // MARK: - Compact Daily Goal Card

    private var compactDailyGoalCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
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

            VStack(alignment: .leading, spacing: 2) {
                Text("\(completedCount)/\(totalCount)")
                    .font(theme.typography.title)
                    .foregroundColor(.white)

                Text("Problems completed")
                    .font(theme.typography.body)
                    .foregroundColor(.white.opacity(0.8))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: totalCount > 0
                                ? geo.size.width * CGFloat(completedCount) / CGFloat(totalCount)
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

    // MARK: - Compact Habits Section

    private var compactHabitsSection: some View {
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

    // MARK: - Compact Start Focus CTA

    private var compactStartFocusCTA: some View {
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

    // MARK: - Regular Header Section

    private var regularHeaderSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(formattedDateUppercased)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)

                Text(todayDay?.topic ?? "Study Plan")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
            }

            Spacer()

            if !presenter.lastSyncResult.isEmpty {
                Text(presenter.lastSyncResult)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.pill)
            }
        }
        .padding(.horizontal, theme.spacing.xl)
        .padding(.top, theme.spacing.xl)
    }

    // MARK: - Regular Card Strip

    private var regularCardStrip: some View {
        HStack(spacing: theme.spacing.md) {
            regularDailyGoalCard
            regularHabitsCard
            regularSyncCard
        }
        .frame(height: 120)
        .padding(.horizontal, theme.spacing.xl)
    }

    private var regularDailyGoalCard: some View {
        let progress: CGFloat = totalCount > 0
            ? CGFloat(completedCount) / CGFloat(totalCount)
            : 0

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.white)
                Text("Daily Goal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text("\(completedCount)/\(totalCount)")
                .font(.system(size: 24, weight: .bold))
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
                        .frame(width: geo.size.width * progress, height: 4)
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

    private var regularHabitsCard: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(theme.colors.success)
                    Text("Habits")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
                Text("\(presenter.habitsCompletedCount)/\(presenter.habits.count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("Completed today")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
    }

    private var regularSyncCard: some View {
        Button {
            presenter.syncNow()
        } label: {
            VStack(spacing: theme.spacing.xs) {
                Image(
                    systemName: presenter.isSyncing
                        ? "arrow.triangle.2.circlepath"
                        : "arrow.clockwise"
                )
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.colors.primary)
                .rotationEffect(presenter.isSyncing ? .degrees(360) : .zero)
                .animation(
                    presenter.isSyncing
                        ? .linear(duration: 1).repeatForever(autoreverses: false)
                        : .default,
                    value: presenter.isSyncing
                )
                Text("Sync LeetCode")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("Fetch progress")
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
        .buttonStyle(.plain)
        .disabled(presenter.isSyncing)
    }

    // MARK: - Regular Plan Header

    private var regularPlanHeader: some View {
        HStack {
            Text("Today's Plan")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)

            if let day = todayDay {
                Text("Day \(day.id)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.xl)
    }

    // MARK: - Regular Task List

    private func regularTaskList(for day: TodayDayViewModel) -> some View {
        VStack(spacing: 0) {
            ForEach(
                Array(day.problems.enumerated()),
                id: \.element.id
            ) { offset, problemVM in
                TaskRow(
                    title: problemVM.problem.name,
                    subtitle: day.topic,
                    isCompleted: problemVM.isCompleted,
                    difficulty: problemVM.problem.difficulty,
                    isCarryover: false,
                    theme: theme,
                    onTap: {
                        if let url = URL(string: problemVM.problem.url) {
                            openURL(url)
                        }
                    }
                )
                if offset < day.problems.count - 1 {
                    Divider().padding(.leading, 52)
                }
            }

            // Habits section in task list (iPad style)
            if !presenter.habits.isEmpty {
                Divider().padding(.leading, 52)
                ForEach(presenter.habits) { habit in
                    RegularHabitRow(
                        habit: habit,
                        theme: theme,
                        onToggle: { presenter.toggleHabit(habit.id) }
                    )
                }
            }
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .padding(.horizontal, theme.spacing.xl)
    }

    // MARK: - Regular Carryover Section

    private func regularCarryoverSection(for day: TodayDayViewModel) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Text("Day \(day.id) - \(day.topic)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.warning)
                Text("(\(day.problems.count) carryover)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.warning)
            }
            .padding(.horizontal, theme.spacing.xl)

            VStack(spacing: 0) {
                ForEach(
                    Array(day.problems.enumerated()),
                    id: \.element.id
                ) { offset, problemVM in
                    TaskRow(
                        title: problemVM.problem.name,
                        subtitle: day.topic,
                        isCompleted: problemVM.isCompleted,
                        difficulty: problemVM.problem.difficulty,
                        isCarryover: true,
                        theme: theme,
                        onTap: {
                            if let url = URL(string: problemVM.problem.url) {
                                openURL(url)
                            }
                        }
                    )
                    if offset < day.problems.count - 1 {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(theme.colors.surface)
            .cornerRadius(theme.radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.md)
                    .stroke(theme.colors.warning.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, theme.spacing.xl)
        }
    }

    // MARK: - Date Formatter

    private var formattedDateUppercased: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date()).uppercased()
    }
}

// MARK: - TaskRow (Shared, Private to File)

private struct TaskRow: View {
    var title: String
    var subtitle: String?
    var isCompleted: Bool = false
    var difficulty: Difficulty?
    var isCarryover: Bool = false
    var theme: DSTheme
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Check icon
                if isCompleted {
                    ZStack {
                        Circle()
                            .fill(theme.colors.primary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .strokeBorder(
                            isCarryover ? theme.colors.warning : theme.colors.border,
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
                                ? theme.colors.textSecondary
                                : theme.colors.textPrimary
                        )
                        .strikethrough(isCompleted)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }

                Spacer()

                // Difficulty badge
                if let difficulty {
                    DSBadge(
                        difficulty.rawValue,
                        config: DSBadgeConfig(
                            style: DifficultyBadgeHelper.badgeStyle(for: difficulty)
                        )
                    )
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - RegularHabitRow (iPad task-list habit row, private to file)

private struct RegularHabitRow: View {
    let habit: HabitViewModel
    let theme: DSTheme
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                if habit.isCompleted {
                    ZStack {
                        Circle()
                            .fill(theme.colors.success)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .strokeBorder(
                            theme.colors.border,
                            style: StrokeStyle(lineWidth: 1.5)
                        )
                        .frame(width: 24, height: 24)
                }

                Image(systemName: habit.icon)
                    .font(.system(size: 14))
                    .foregroundColor(
                        habit.isCompleted
                            ? theme.colors.success
                            : theme.colors.textSecondary
                    )

                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        habit.isCompleted
                            ? theme.colors.textSecondary
                            : theme.colors.textPrimary
                    )
                    .strikethrough(habit.isCompleted)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }
}
#endif
