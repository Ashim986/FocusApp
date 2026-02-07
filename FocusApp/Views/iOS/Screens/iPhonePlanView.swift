#if os(iOS)
// iPhonePlanView.swift
// FocusApp -- iPhone Plan screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhonePlanView: View {
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    @ObservedObject var presenter: PlanPresenter

    @State private var expandedDayId: Int?

    var body: some View {
        VStack(spacing: 0) {
            headerBar

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
                        dayCard(day)
                            .padding(.horizontal, theme.spacing.lg)
                    }
                }
                .padding(.top, theme.spacing.sm)
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

    // MARK: - Day Card

    private func dayCard(_ day: PlanDayViewModel) -> some View {
        let isExpanded = expandedDayId == day.id

        return VStack(alignment: .leading, spacing: 0) {
            // Header row (always visible)
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
                        // Progress indicator
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

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: 0xE5E7EB))
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            day.isFullyCompleted
                                ? Color(hex: 0x059669)
                                : Color(hex: 0x6366F1)
                        )
                        .frame(
                            width: day.problems.count > 0
                                ? geo.size.width * CGFloat(day.completedCount) / CGFloat(day.problems.count)
                                : 0,
                            height: 4
                        )
                }
            }
            .frame(height: 4)
            .padding(.horizontal, theme.spacing.lg)

            // Expanded problem list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(day.problems) { problem in
                        Divider().padding(.leading, 52)

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
                                        .strokeBorder(
                                            Color(hex: 0xD1D5DB),
                                            lineWidth: 1.5
                                        )
                                        .frame(width: 24, height: 24)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(problem.problem.name)
                                        .font(theme.typography.body)
                                        .foregroundColor(
                                            problem.isCompleted
                                                ? Color(hex: 0x9CA3AF)
                                                : theme.colors.textPrimary
                                        )
                                        .strikethrough(problem.isCompleted)

                                    if let number = problem.problem.leetcodeNumber {
                                        Text("LeetCode #\(number)")
                                            .font(theme.typography.caption)
                                            .foregroundColor(Color(hex: 0x6B7280))
                                    }
                                }

                                Spacer()

                                difficultyBadge(problem.problem.difficulty)
                            }
                            .padding(.horizontal, theme.spacing.lg)
                            .frame(height: 48)
                        }
                    }
                }
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
