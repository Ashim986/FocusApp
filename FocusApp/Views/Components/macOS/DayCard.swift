#if os(macOS)
import FocusDesignSystem
import SwiftUI

struct DayCard: View {
    let viewModel: PlanDayViewModel
    let onToggleProblem: (Int) -> Void
    let onSelectProblem: (Int) -> Void
    @State private var isExpanded = false
    @Environment(\.dsTheme) var theme

    var body: some View {
        DSCard(config: .init(style: .elevated, padding: 0)) {
            VStack(spacing: DSLayout.spacing(0)) {
                DSActionButton(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }, label: {
                    HStack(spacing: DSLayout.spacing(16)) {
                        ZStack {
                            Circle()
                                .fill(viewModel.isFullyCompleted ? theme.colors.success : theme.colors.primary)
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

                        VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                            Text(viewModel.topic)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.colors.textPrimary)

                            Text(viewModel.date)
                                .font(.system(size: 13))
                                .foregroundColor(theme.colors.textSecondary)
                        }

                        Spacer()

                        HStack(spacing: DSLayout.spacing(4)) {
                            ForEach(viewModel.problems) { problem in
                                Circle()
                                    .fill(problem.isCompleted ? theme.colors.success : theme.colors.border)
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .padding(DSLayout.spacing(16))
                    .contentShape(Rectangle())
                })

                if isExpanded {
                    Divider()
                        .padding(.horizontal, DSLayout.spacing(16))

                    VStack(spacing: DSLayout.spacing(0)) {
                        ForEach(viewModel.problems) { problem in
                            ProblemRow(
                                problem: problem.problem,
                                isCompleted: problem.isCompleted,
                                onToggle: {
                                    onToggleProblem(problem.index)
                                },
                                onSelect: {
                                    onSelectProblem(problem.index)
                                }
                            )

                            if problem.index < viewModel.problems.count - 1 {
                                Divider()
                                    .padding(.leading, DSLayout.spacing(44))
                            }
                        }
                    }
                    .padding(.bottom, DSLayout.spacing(8))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.lg)
                .strokeBorder(
                    viewModel.isFullyCompleted ? theme.colors.success.opacity(0.3) : theme.colors.border,
                    lineWidth: 1
                )
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
        return DSThemeProvider(theme: .light) {
            DayCard(
                viewModel: viewModel,
                onToggleProblem: { _ in },
                onSelectProblem: { _ in }
            )
            .padding()
            .frame(width: 500)
            .background(DSTheme.light.colors.background)
        }
    }
}
#endif

#endif
