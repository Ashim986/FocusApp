#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    var leftPanel: some View {
        problemDetailPanel
            .background(theme.colors.background)
    }

    var problemSidebar: some View {
        VStack(spacing: DSLayout.spacing(0)) {
            sidebarHeader

            Divider()
                .background(theme.colors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(16)) {
                    ForEach(presenter.problemSections) { section in
                        sectionView(section)
                    }
                }
                .padding(DSLayout.spacing(12))
            }
        }
        .background(theme.colors.surface)
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 6, y: 0)
    }

    private var problemDetailPanel: some View {
        VStack(spacing: DSLayout.spacing(0)) {
            detailTabBar

            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(20)) {
                    detailHeader
                    detailContent
                }
                .padding(DSLayout.spacing(18))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(theme.colors.background)
    }

    private var pendingCount: Int {
        presenter.problemSections
            .flatMap { $0.problems }
            .filter { !$0.isCompleted }
            .count
    }

    private var sidebarHeader: some View {
        HStack {
            Text(L10n.Coding.sidebarTitle)
                .font(theme.typography.subtitle)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()

            Text(L10n.Coding.sidebarPendingLeft(pendingCount))
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .padding(.horizontal, DSLayout.spacing(12))
        .padding(.vertical, DSLayout.spacing(10))
        .background(theme.colors.surfaceElevated)
    }

    private var detailHeader: some View {
        DSCard(config: .init(style: .outlined, padding: 16, cornerRadius: 12)) {
            VStack(alignment: .leading, spacing: DSLayout.spacing(8)) {
            if let problem = presenter.selectedProblem {
                HStack(alignment: .top, spacing: DSLayout.spacing(12)) {
                    VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
                        Text(problem.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.colors.textPrimary)
                            .lineLimit(2)

                        Text(L10n.Coding.sidebarDayTopic(
                                               selectedDayLabel,
                                               presenter.selectedDayTopic))
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    statusBadge(isSolved: isSelectedProblemSolved)
                }

                HStack(spacing: DSLayout.spacing(8)) {
                    difficultyBadge(problem.difficulty)
                    infoBadge(title: presenter.selectedDayTopic, icon: "tag")
                    infoBadge(title: L10n.Coding.sidebarDayBadge(selectedDayLabel), icon: "calendar")
                }
            } else {
                Text(L10n.Coding.sidebarSelectPrompt)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            }
        }
    }

    private var detailTabBar: some View {
        let items = ProblemDetailTab.allCases.map {
            DSSegmentItem(id: $0.title, title: $0.title)
        }
        return HStack {
            DSSegmentedControl(
                items: items,
                state: .init(selectedId: codingCoordinator.detailTab.title),
                onSelect: { selected in
                    if let tab = ProblemDetailTab.allCases.first(where: { $0.title == selected }) {
                        codingCoordinator.detailTab = tab
                    }
                }
            )
        }
        .padding(.horizontal, DSLayout.spacing(18))
        .padding(.vertical, DSLayout.spacing(10))
        .background(theme.colors.surface)
        .overlay(
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        let style: DSBadgeStyle = {
            switch difficulty {
            case .easy: return .success
            case .medium: return .warning
            case .hard: return .danger
            }
        }()
        return DSBadge(difficulty.rawValue.uppercased(), config: .init(style: style))
    }

    private func infoBadge(title: String, icon: String) -> some View {
        HStack(spacing: DSLayout.spacing(4)) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(title)
                .font(theme.typography.caption)
        }
        .foregroundColor(theme.colors.textSecondary)
        .padding(.horizontal, DSLayout.spacing(8))
        .padding(.vertical, DSLayout.spacing(4))
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surfaceElevated)
        )
    }

    private func statusBadge(isSolved: Bool) -> some View {
        let style: DSBadgeStyle = isSolved ? .success : .neutral
        return DSBadge(
            isSolved ? L10n.Coding.statusSolved : L10n.Coding.statusUnsolved,
            config: .init(style: style)
        )
    }

    private var isSelectedProblemSolved: Bool {
        guard presenter.selectedProblem != nil else { return false }
        return presenter.isProblemCompleted(day: selectedDayLabel, index: presenter.selectedProblemIndex)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch codingCoordinator.detailTab {
        case .description:
            descriptionContent
        case .editorial:
            editorialContent
        case .solution:
            SolutionTabView(
                solution: presenter.currentSolution
            )
        case .submissions:
            pastSubmissionsContent
        case .debug:
            DebugLogView(store: debugLogStore, isEmbedded: true)
        }
    }

}

#endif
