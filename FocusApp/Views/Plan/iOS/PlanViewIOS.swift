#if os(iOS)
// PlanViewIOS.swift
// FocusApp -- Unified Plan screen (adaptive: iPhone compact / iPad regular)

import FocusDesignSystem
import SwiftUI

// swiftlint:disable:next type_body_length
struct PlanViewIOS: View {
    @ObservedObject var presenter: PlanPresenter

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    // Compact (iPhone) state
    @State private var expandedDayId: Int?

    // Regular (iPad) state
    @State private var selectedDayId: Int?

    var body: some View {
        if sizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            compactHeaderBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    // Title
                    Text("Study Plan")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Sync status
                    if presenter.isSyncing {
                        HStack(spacing: theme.spacing.sm) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Syncing...")
                                .font(theme.typography.caption)
                                .foregroundColor(Color(hex: 0x6B7280))
                        }
                        .padding(.horizontal, theme.spacing.lg)
                    } else if !presenter.lastSyncResult.isEmpty {
                        Text(presenter.lastSyncResult)
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))
                            .padding(.horizontal, theme.spacing.lg)
                    }

                    // Day cards
                    ForEach(presenter.days) { day in
                        compactDayCard(day)
                            .padding(.horizontal, theme.spacing.lg)
                    }
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
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
                presenter.syncNow()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .padding(.trailing, theme.spacing.lg)
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Compact Day Card

    private func compactDayCard(_ day: PlanDayViewModel) -> some View {
        let isExpanded = expandedDayId == day.id

        return VStack(alignment: .leading, spacing: 0) {
            compactDayHeader(day, isExpanded: isExpanded)
            compactDayProgressBar(for: day)

            if isExpanded {
                compactProblemList(for: day)
                    .padding(.bottom, theme.spacing.sm)
            }
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    private func compactDayHeader(_ day: PlanDayViewModel, isExpanded: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedDayId = isExpanded ? nil : day.id
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Day \(day.id): \(day.topic)")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("\(day.date) - \(day.completedCount)/\(day.problems.count) completed")
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }

                Spacer()

                if day.isFullyCompleted {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0xD1FAE5))
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: 0x059669))
                    }
                } else {
                    Text("\(day.completedCount)/\(day.problems.count)")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6B7280))
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x9CA3AF))
            }
            .padding(theme.spacing.lg)
        }
    }

    private func compactDayProgressBar(for day: PlanDayViewModel) -> some View {
        GeometryReader { geo in
            let fraction = day.problems.isEmpty
                ? 0
                : CGFloat(day.completedCount) / CGFloat(day.problems.count)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(hex: 0xE5E7EB))
                    .frame(height: 4)

                Capsule()
                    .fill(day.isFullyCompleted ? Color(hex: 0x059669) : Color(hex: 0x6366F1))
                    .frame(width: geo.size.width * fraction, height: 4)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, theme.spacing.lg)
    }

    private func compactProblemList(for day: PlanDayViewModel) -> some View {
        VStack(spacing: 0) {
            ForEach(day.problems) { problem in
                Divider().padding(.leading, 52)
                compactProblemRow(problem)
            }
        }
    }

    private func compactProblemRow(_ problem: PlanProblemViewModel) -> some View {
        Button {
            if let url = URL(string: problem.problem.url) {
                openURL(url)
            }
        } label: {
            HStack(spacing: theme.spacing.md) {
                if problem.isCompleted {
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
                        .strokeBorder(Color(hex: 0xD1D5DB), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(problem.problem.name)
                        .font(theme.typography.body)
                        .foregroundColor(problem.isCompleted ? Color(hex: 0x9CA3AF) : theme.colors.textPrimary)
                        .strikethrough(problem.isCompleted)

                    if let number = problem.problem.leetcodeNumber {
                        Text("LeetCode #\(number)")
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))
                    }
                }

                Spacer()

                DSBadge(
                    problem.problem.difficulty.rawValue,
                    config: DSBadgeConfig(style: DifficultyBadgeHelper.badgeStyle(for: problem.problem.difficulty))
                )
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 48)
        }
    }

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            // Title + Sync
            HStack {
                Text("Study Plan")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                if !presenter.lastSyncResult.isEmpty {
                    Text(presenter.lastSyncResult)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.colors.textSecondary)
                }

                DSButton(
                    "Sync",
                    config: DSButtonConfig(
                        style: .secondary,
                        size: .small,
                        icon: Image(systemName: "arrow.clockwise")
                    )
                ) {
                    presenter.syncNow()
                }
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, theme.spacing.xl)

            // Two-column layout
            HStack(alignment: .top, spacing: theme.spacing.md) {
                // Left column: Day list
                regularDayListColumn

                // Right column: Day detail
                regularDayDetailColumn
            }
            .padding(.horizontal, theme.spacing.xl)

            Spacer()
        }
    }

    // MARK: - Regular Day List Column

    private var regularDayListColumn: some View {
        ScrollView {
            VStack(spacing: theme.spacing.sm) {
                ForEach(presenter.days) { day in
                    regularDayRow(day: day, isSelected: selectedDayId == day.id) {
                        selectedDayId = day.id
                    }
                }
            }
            .padding(theme.spacing.sm)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .frame(maxWidth: 280)
    }

    // MARK: - Regular Day Row

    private func regularDayRow(
        day: PlanDayViewModel,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: theme.spacing.md) {
                // Day number circle
                ZStack {
                    Circle()
                        .fill(
                            day.isFullyCompleted
                                ? theme.colors.success
                                : isSelected
                                    ? theme.colors.primary
                                    : theme.colors.border
                        )
                        .frame(width: 32, height: 32)

                    if day.isFullyCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(day.id)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(
                                isSelected ? .white : theme.colors.textPrimary
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(day.topic)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    Text("\(day.completedCount)/\(day.problems.count) problems")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                Text(day.date)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(
                isSelected
                    ? theme.colors.primary.opacity(0.08)
                    : Color.clear
            )
            .cornerRadius(theme.radii.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Regular Day Detail Column

    private var regularDayDetailColumn: some View {
        Group {
            if let dayId = selectedDayId,
               let day = presenter.days.first(where: { $0.id == dayId }) {
                regularDayDetail(for: day)
            } else if let firstDay = presenter.days.first {
                regularDayDetail(for: firstDay)
                    .onAppear { selectedDayId = firstDay.id }
            } else {
                regularEmptyDetail
            }
        }
    }

    private func regularDayDetail(for day: PlanDayViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                // Day header
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Day \(day.id) - \(day.topic)")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)

                        Text(day.date)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    // Progress badge
                    DSBadge(
                        "\(day.completedCount)/\(day.problems.count)",
                        config: DSBadgeConfig(style: day.isFullyCompleted ? .success : .neutral)
                    )
                }

                // Progress bar
                GeometryReader { geo in
                    let progress = day.problems.isEmpty
                        ? 0.0
                        : CGFloat(day.completedCount) / CGFloat(day.problems.count)
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.colors.border)
                            .frame(height: 6)
                        Capsule()
                            .fill(day.isFullyCompleted ? theme.colors.success : theme.colors.primary)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)

                // Problem list
                VStack(spacing: 0) {
                    ForEach(Array(day.problems.enumerated()), id: \.element.id) { offset, problem in
                        regularProblemRow(problem: problem)

                        if offset < day.problems.count - 1 {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .background(theme.colors.surface)
                .cornerRadius(theme.radii.md)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.md)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    // MARK: - Regular Problem Row

    private func regularProblemRow(problem: PlanProblemViewModel) -> some View {
        Button {
            if let url = URL(string: problem.problem.url) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                // Status icon
                if problem.isCompleted {
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
                        .strokeBorder(theme.colors.border, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }

                // Problem name
                Text(problem.problem.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(
                        problem.isCompleted
                            ? theme.colors.textSecondary
                            : theme.colors.textPrimary
                    )
                    .strikethrough(problem.isCompleted)

                Spacer()

                // Difficulty
                DSBadge(
                    problem.problem.difficulty.rawValue,
                    config: DSBadgeConfig(
                        style: DifficultyBadgeHelper.badgeStyle(for: problem.problem.difficulty)
                    )
                )

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Regular Empty Detail

    private var regularEmptyDetail: some View {
        VStack {
            Spacer()
            Text("No plan data available")
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
#endif
