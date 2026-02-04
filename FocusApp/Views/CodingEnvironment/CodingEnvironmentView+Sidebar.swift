import SwiftUI

extension CodingEnvironmentView {
    var leftPanel: some View {
        VSplitView {
            problemSidebar
                .frame(minHeight: 220)

            problemDetailPanel
                .frame(minHeight: 220)
        }
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
    }

    private var problemDetailPanel: some View {
        VStack(spacing: 0) {
            detailHeader

            detailToggle

            Divider()
                .background(Color.appGray700)

            ScrollView {
                detailContent
                    .padding(12)
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
        VStack(alignment: .leading, spacing: 4) {
            Text("Problem Details")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)

            if let problem = presenter.selectedProblem {
                Text(problem.name)
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray400)
                    .lineLimit(1)
            } else {
                Text("Select a problem to view details")
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray500)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.appGray800)
    }

    private var detailToggle: some View {
        HStack(spacing: 6) {
            ForEach(ProblemDetailTab.allCases, id: \.rawValue) { tab in
                Button(action: { detailTab = tab }) {
                    Text(tab.rawValue)
                        .font(.system(size: 10, weight: detailTab == tab ? .semibold : .regular))
                        .foregroundColor(detailTab == tab ? .white : Color.appGray500)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(detailTab == tab ? Color.appPurple : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.appGray900)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch detailTab {
        case .description:
            descriptionContent
        case .solution:
            solutionContent
        case .history:
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
