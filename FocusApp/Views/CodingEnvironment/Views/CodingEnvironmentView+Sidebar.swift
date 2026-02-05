import SwiftUI

extension CodingEnvironmentView {
    var leftPanel: some View {
        problemDetailPanel
            .background(Color.appGray900)
    }

    var problemSidebar: some View {
        VStack(spacing: 0) {
            sidebarHeader

            Divider()
                .background(Color.appGray700)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(presenter.problemSections) { section in
                        sectionView(section)
                    }
                }
                .padding(12)
            }
        }
        .background(Color.appGray900)
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 6, y: 0)
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
        .background(Color.appGray900)
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Text(L10n.Coding.sidebarPendingLeft( pendingCount))
                .font(.system(size: 11))
                .foregroundColor(Color.appGray400)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.appGray800)
    }

    private var detailHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let problem = presenter.selectedProblem {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(problem.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text(L10n.Coding.sidebarDayTopic(
                                               selectedDayLabel,
                                               presenter.selectedDayTopic))
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray400)
                    }

                    Spacer()

                    statusBadge(isSolved: isSelectedProblemSolved)
                }

                HStack(spacing: 8) {
                    difficultyBadge(problem.difficulty)
                    infoBadge(title: presenter.selectedDayTopic, icon: "tag")
                    infoBadge(title: L10n.Coding.sidebarDayBadge( selectedDayLabel), icon: "calendar")
                }
            } else {
                Text(L10n.Coding.sidebarSelectPrompt)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appGray800.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appGray700, lineWidth: 1)
                )
        )
    }

    private var detailTabBar: some View {
        HStack(spacing: 16) {
            ForEach(ProblemDetailTab.allCases, id: \.self) { tab in
                detailTabButton(tab)
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.appGray900)
        .overlay(
            Rectangle()
                .fill(Color.appGray700)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func detailTabButton(_ tab: ProblemDetailTab) -> some View {
        Button(action: {
            detailTab = tab
        }, label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 11, weight: detailTab == tab ? .semibold : .regular))
            }
            .foregroundColor(detailTab == tab ? .white : Color.appGray500)
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .fill(detailTab == tab ? Color.appPurple : Color.clear)
                    .frame(height: 2),
                alignment: .bottom
            )
        })
        .buttonStyle(.plain)
    }

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        Text(difficulty.rawValue.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(difficulty == .easy ? Color.appGreen : Color.appAmber)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill((difficulty == .easy ? Color.appGreen : Color.appAmber).opacity(0.15))
            )
    }

    private func infoBadge(title: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(title)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(Color.appGray300)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appGray800.opacity(0.6))
        )
    }

    private func statusBadge(isSolved: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isSolved ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 10, weight: .semibold))
            Text(isSolved
                 ? L10n.Coding.statusSolved
                 : L10n.Coding.statusUnsolved)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(isSolved ? Color.appGreen : Color.appGray400)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill((isSolved ? Color.appGreen : Color.appGray600).opacity(0.15))
        )
    }

    private var isSelectedProblemSolved: Bool {
        guard presenter.selectedProblem != nil else { return false }
        return presenter.isProblemCompleted(day: selectedDayLabel, index: presenter.selectedProblemIndex)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch detailTab {
        case .description:
            descriptionContent
        case .editorial:
            editorialContent
        case .solution:
            SolutionTabView(solution: presenter.currentSolution)
        case .submissions:
            pastSubmissionsContent
        case .debug:
            DebugLogView(store: debugLogStore, isEmbedded: true)
        }
    }

}
