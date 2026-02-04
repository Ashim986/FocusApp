import SwiftUI

struct DayCard: View {
    let viewModel: PlanDayViewModel
    let onToggleProblem: (Int) -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }, label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isFullyCompleted ? Color.appGreen : Color.appPurple)
                            .frame(width: 40, height: 40)

                        if viewModel.isFullyCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(viewModel.id)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.topic)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.appGray800)

                        Text(viewModel.date)
                            .font(.system(size: 13))
                            .foregroundColor(Color.appGray500)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        ForEach(viewModel.problems) { problem in
                            Circle()
                                .fill(problem.isCompleted ? Color.appGreen : Color.appGray300)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.appGray400)
                }
                .padding(16)
                .contentShape(Rectangle())
            })
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(viewModel.problems) { problem in
                        ProblemRow(
                            problem: problem.problem,
                            isCompleted: problem.isCompleted,
                            onToggle: {
                                onToggleProblem(problem.index)
                            }
                        )

                        if problem.index < viewModel.problems.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(viewModel.isFullyCompleted ? Color.appGreen.opacity(0.3) : Color.appGray200, lineWidth: 1)
        )
    }
}

#if DEBUG
struct DayCard_Previews: PreviewProvider {
    static var previews: some View {
        let day = dsaPlan[0]
        let viewModel = PlanDayViewModel(
            id: day.id,
            date: day.date,
            topic: day.topic,
            problems: day.problems.enumerated().map { index, problem in
                PlanProblemViewModel(id: problem.id, problem: problem, isCompleted: index == 0, index: index)
            },
            completedCount: 1
        )
        return DayCard(viewModel: viewModel, onToggleProblem: { _ in })
            .padding()
            .frame(width: 500)
            .background(Color.appGray100)
    }
}
#endif
