#if os(iOS)
// TodayViewIOS+Regular.swift
// FocusApp -- iPad (regular) layout shell.

import FocusDesignSystem
import SwiftUI

extension TodayViewIOS {

    // MARK: - Regular Layout (iPad)

    var regularLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                regularHeaderSection
                regularCardStrip
                regularPlanHeader

                if let today = todayDay {
                    regularTaskList(for: today)
                }

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
                Image(systemName: presenter.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
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
}

#endif
