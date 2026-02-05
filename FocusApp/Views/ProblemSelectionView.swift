import SwiftUI

struct ProblemSelectionView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()
                .background(Color.appGray700)

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
        .background(Color.appIndigo)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(L10n.ProblemSelection.backToTimer)
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray400)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            VStack(spacing: 4) {
                Text(L10n.ProblemSelection.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text(L10n.ProblemSelection.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color.appGray400)
            }
        }
        .padding(20)
        .background(Color.appIndigoLight)
    }

    private func sectionBlock(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.isToday
                     ? L10n.ProblemSelection.sectionToday( section.dayId)
                     : L10n.ProblemSelection.sectionBacklog( section.dayId))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.appGray400)

                Spacer()

                Text("\(section.completedCount)/\(section.totalCount)")
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray500)
            }

            VStack(spacing: 12) {
                ForEach(section.problems) { item in
                    problemCard(item)
                }
            }
        }
    }

    private func problemCard(_ item: CodingProblemItem) -> some View {
        Button(action: {
            presenter.selectProblem(item)
        }, label: {
            HStack(spacing: 12) {
                // Completion indicator
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? Color.appGreen : Color.appGray600, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.appGreen)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.problem.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        difficultyBadge(item.problem.difficulty)

                        if item.isCompleted {
                            Text(L10n.ProblemSelection.solved)
                                .font(.system(size: 10))
                                .foregroundColor(Color.appGreen)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appGray800.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appGray700, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
    }

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        Text(difficulty.rawValue)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(difficulty == .easy ? Color.appGreen : Color.appAmber)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill((difficulty == .easy ? Color.appGreen : Color.appAmber).opacity(0.15))
            )
    }
}
