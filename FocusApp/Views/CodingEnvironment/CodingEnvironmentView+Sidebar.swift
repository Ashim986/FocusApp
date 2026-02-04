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
            Text("Problems")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Text("\(pendingCount) left")
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
                        Text(problem.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text("Day \(selectedDayLabel) · \(presenter.selectedDayTopic)")
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray400)
                    }

                    Spacer()

                    statusBadge(isSolved: isSelectedProblemSolved)
                }

                HStack(spacing: 8) {
                    difficultyBadge(problem.difficulty)
                    infoBadge(title: presenter.selectedDayTopic, icon: "tag")
                    infoBadge(title: "Day \(selectedDayLabel)", icon: "calendar")
                }
            } else {
                Text("Select a problem to view details")
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
            ForEach(ProblemDetailTab.allCases, id: \.rawValue) { tab in
                Button(action: { detailTab = tab }) {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 10, weight: .semibold))
                        Text(tab.rawValue)
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
                }
                .buttonStyle(.plain)
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
            Text(isSolved ? "Solved" : "Unsolved")
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
        case .submissions:
            pastSubmissionsContent
        }
    }

    private func sectionView(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(section.isToday ? "Today · Day \(section.dayId)" : "Backlog · Day \(section.dayId)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.appGray300)

                Spacer()

                Text("\(section.completedCount)/\(section.totalCount)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.appGray500)
            }

            VStack(spacing: 6) {
                ForEach(section.problems) { item in
                    sidebarRow(item)
                }
            }
        }
    }

    private func sidebarRow(_ item: CodingProblemItem) -> some View {
        let isSelected = presenter.selectedProblem?.id == item.problem.id

        return Button(action: {
            presenter.selectProblem(item)
        }) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? Color.appGreen : Color.appGray600, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color.appGreen)
                    } else {
                        Text("\(item.index + 1)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(Color.appGray500)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.problem.name)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : Color.appGray300)
                        .lineLimit(1)

                    Text(item.problem.difficulty.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(item.problem.difficulty == .easy ? Color.appGreen : Color.appAmber)
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.appPurple.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
