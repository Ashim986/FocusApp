import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    var leftPanel: some View {
        problemDetailPanel
            .background(theme.colors.background)
    }

    var problemSidebar: some View {
        VStack(spacing: 0) {
            sidebarHeader

            Divider()
                .background(theme.colors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(presenter.problemSections) { section in
                        sectionView(section)
                    }
                }
                .padding(12)
            }
        }
        .background(theme.colors.surface)
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 6, y: 0)
    }

    private var problemDetailPanel: some View {
        VStack(spacing: 0) {
            detailTabBar

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailHeader
                    detailContent
                }
                .padding(18)
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
            DSText(L10n.Coding.sidebarTitle)
                .font(theme.typography.subtitle)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()

            DSText(L10n.Coding.sidebarPendingLeft(pendingCount))
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.colors.surfaceElevated)
    }

    private var detailHeader: some View {
        DSCard(config: .init(style: .outlined, padding: 16, cornerRadius: 12)) {
            VStack(alignment: .leading, spacing: 8) {
            if let problem = presenter.selectedProblem {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        DSText(problem.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.colors.textPrimary)
                            .lineLimit(2)

                        DSText(L10n.Coding.sidebarDayTopic(
                                               selectedDayLabel,
                                               presenter.selectedDayTopic))
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    statusBadge(isSolved: isSelectedProblemSolved)
                }

                HStack(spacing: 8) {
                    difficultyBadge(problem.difficulty)
                    infoBadge(title: presenter.selectedDayTopic, icon: "tag")
                    infoBadge(title: L10n.Coding.sidebarDayBadge(selectedDayLabel), icon: "calendar")
                }
            } else {
                DSText(L10n.Coding.sidebarSelectPrompt)
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
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(theme.colors.surface)
        .overlay(
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func detailTabButton(_ tab: ProblemDetailTab) -> some View {
        DSButton(action: {
            codingCoordinator.detailTab = tab
        }, label: {
            HStack(spacing: 6) {
                DSImage(systemName: tab.icon)
                    .font(.system(size: 10, weight: .semibold))
                DSText(tab.title)
                    .font(.system(size: 11, weight: codingCoordinator.detailTab == tab ? .semibold : .regular))
            }
            .foregroundColor(codingCoordinator.detailTab == tab ? theme.colors.textPrimary : theme.colors.textSecondary)
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .fill(codingCoordinator.detailTab == tab ? theme.colors.primary : Color.clear)
                    .frame(height: 2),
                alignment: .bottom
            )
        })
        .buttonStyle(.plain)
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
        HStack(spacing: 4) {
            DSImage(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            DSText(title)
                .font(theme.typography.caption)
        }
        .foregroundColor(theme.colors.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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
