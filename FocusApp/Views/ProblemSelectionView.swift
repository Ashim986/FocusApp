import FocusDesignSystem
import SwiftUI

struct ProblemSelectionView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    let onBack: () -> Void
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(spacing: DSLayout.spacing(0)) {
            // Header
            header

            Divider()
                .background(theme.colors.border)

            // Problem list
            ScrollView {
                VStack(spacing: DSLayout.spacing(16)) {
                    ForEach(presenter.problemSections) { section in
                        sectionBlock(section)
                    }
                }
                .padding(DSLayout.spacing(20))
            }
        }
        .background(theme.colors.background)
    }

    private var header: some View {
        VStack(spacing: DSLayout.spacing(12)) {
            HStack {
                DSButton(
                    L10n.ProblemSelection.backToTimer,
                    config: .init(
                        style: .ghost,
                        size: .small,
                        icon: Image(systemName: "chevron.left"),
                        iconPosition: .leading
                    ),
                    action: {
                        onBack()
                    }
                )
                .tint(theme.colors.textSecondary)

                Spacer()
            }

            VStack(spacing: DSLayout.spacing(4)) {
                Text(L10n.ProblemSelection.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(L10n.ProblemSelection.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .padding(DSLayout.spacing(20))
        .background(theme.colors.surfaceElevated)
    }

    private func sectionBlock(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
            HStack {
                Text(section.isToday
                     ? L10n.ProblemSelection.sectionToday( section.dayId)
                     : L10n.ProblemSelection.sectionBacklog( section.dayId))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                Text("\(section.completedCount)/\(section.totalCount)")
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: DSLayout.spacing(12)) {
                ForEach(section.problems) { item in
                    problemCard(item)
                }
            }
        }
    }

    private func problemCard(_ item: CodingProblemItem) -> some View {
        DSActionButton(action: {
            presenter.selectProblem(item)
        }) {
            HStack(spacing: DSLayout.spacing(12)) {
                // Completion indicator
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(theme.colors.success)
                    }
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                    Text(item.problem.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: DSLayout.spacing(8)) {
                        difficultyBadge(item.problem.difficulty)

                        if item.isCompleted {
                            Text(L10n.ProblemSelection.solved)
                                .font(.system(size: 10))
                                .foregroundColor(theme.colors.success)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(DSLayout.spacing(16))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.colors.surfaceElevated.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
        }
    }

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        DSBadge(
            difficulty.rawValue,
            config: .init(style: difficulty == .easy ? .success : .warning)
        )
    }
}
