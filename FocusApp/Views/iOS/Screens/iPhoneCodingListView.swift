#if os(iOS)
// iPhoneCodingListView.swift
// FocusApp -- iPhone Coding Problem List screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneCodingListView: View {
    @Environment(\.dsTheme) var theme

    @ObservedObject var presenter: CodingEnvironmentPresenter
    var onSelectProblem: (Problem, Int, Int) -> Void

    @State private var searchText = ""

    private var sections: [CodingProblemSection] {
        presenter.problemSections
    }

    private var filteredSections: [CodingProblemSection] {
        guard !searchText.isEmpty else { return sections }
        return sections.compactMap { section in
            let filtered = section.problems.filter {
                $0.problem.name.localizedCaseInsensitiveContains(searchText)
            }
            guard !filtered.isEmpty else { return nil }
            return CodingProblemSection(
                id: section.id,
                dayId: section.dayId,
                topic: section.topic,
                isToday: section.isToday,
                problems: filtered,
                completedCount: section.completedCount,
                totalCount: section.totalCount
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(spacing: theme.spacing.md) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, theme.spacing.lg)

                    // Problem sections by day
                    ForEach(filteredSections) { section in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            // Section header
                            HStack {
                                Text("Day \(section.dayId): \(section.topic)")
                                    .font(theme.typography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.colors.textPrimary)

                                Spacer()

                                Text("\(section.completedCount)/\(section.totalCount)")
                                    .font(theme.typography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: 0x6B7280))

                                if section.isToday {
                                    Text("Today")
                                        .font(theme.typography.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: 0x6366F1))
                                        .padding(.horizontal, theme.spacing.sm)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: 0x6366F1).opacity(0.1))
                                        .cornerRadius(theme.radii.sm)
                                }
                            }
                            .padding(.horizontal, theme.spacing.lg)

                            // Problem cards
                            ForEach(section.problems) { item in
                                problemCard(item: item, dayId: section.dayId)
                                    .padding(.horizontal, theme.spacing.lg)
                            }
                        }
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

            Text("Problems")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        DSTextField(
            placeholder: "Search problems...",
            text: $searchText
        )
    }

    // MARK: - Problem Card

    private func problemCard(item: CodingProblemItem, dayId: Int) -> some View {
        Button {
            onSelectProblem(item.problem, item.index, dayId)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(item.problem.displayName)
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(item.problem.difficulty.rawValue)
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(difficultyTextColor(item.problem.difficulty))
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                        .background(difficultyBgColor(item.problem.difficulty))
                        .cornerRadius(theme.radii.sm)
                }

                Spacer()

                // Completion indicator
                if item.isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0x059669))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(Color(hex: 0xD1D5DB), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
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
        .buttonStyle(.plain)
    }

    // MARK: - Difficulty Helpers

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
