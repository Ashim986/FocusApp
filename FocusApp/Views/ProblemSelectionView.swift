import FocusDesignSystem
import SwiftUI

struct ProblemSelectionView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    let onBack: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()
                .background(theme.colors.border)

            // Problem list
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(presenter.problemSections) { section in
                        sectionBlock(section)
                    }
                }
                .padding(20)
            }
        }
        .background(theme.colors.background)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                DSButton(action: onBack) {
                    HStack(spacing: 4) {
                        DSImage(systemName: "chevron.left")
                        DSText(L10n.ProblemSelection.backToTimer)
                    }
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            VStack(spacing: 4) {
                DSText(L10n.ProblemSelection.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                DSText(L10n.ProblemSelection.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .padding(20)
        .background(theme.colors.surfaceElevated)
    }

    private func sectionBlock(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                DSText(section.isToday
                     ? L10n.ProblemSelection.sectionToday( section.dayId)
                     : L10n.ProblemSelection.sectionBacklog( section.dayId))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                DSText("\(section.completedCount)/\(section.totalCount)")
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: 12) {
                ForEach(section.problems) { item in
                    problemCard(item)
                }
            }
        }
    }

    private func problemCard(_ item: CodingProblemItem) -> some View {
        DSButton(action: {
            presenter.selectProblem(item)
        }, label: {
            HStack(spacing: 12) {
                // Completion indicator
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        DSImage(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(theme.colors.success)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    DSText(item.problem.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        difficultyBadge(item.problem.difficulty)

                        if item.isCompleted {
                            DSText(L10n.ProblemSelection.solved)
                                .font(.system(size: 10))
                                .foregroundColor(theme.colors.success)
                        }
                    }
                }

                Spacer()

                DSImage(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.colors.surfaceElevated.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
    }

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        DSBadge(
            difficulty.rawValue,
            config: .init(style: difficulty == .easy ? .success : .warning)
        )
    }
}
