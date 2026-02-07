import FocusDesignSystem
import SwiftUI

struct DayCard: View {
    let viewModel: PlanDayViewModel
    let onToggleProblem: (Int) -> Void
    let onSelectProblem: (Int) -> Void
    @State private var isExpanded = false
    @Environment(\.dsTheme) private var theme

    var body: some View {
        DSCard(config: .init(style: .elevated, padding: 0)) {
            VStack(spacing: 0) {
                DSButton(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }, label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(viewModel.isFullyCompleted ? theme.colors.success : theme.colors.primary)
                                .frame(width: 40, height: 40)

                            if viewModel.isFullyCompleted {
                                DSImage(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                DSText("\(viewModel.id)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            DSText(viewModel.topic)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.colors.textPrimary)

                            DSText(viewModel.date)
                                .font(.system(size: 13))
                                .foregroundColor(theme.colors.textSecondary)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(viewModel.problems) { problem in
                                Circle()
                                    .fill(problem.isCompleted ? theme.colors.success : theme.colors.border)
                                    .frame(width: 8, height: 8)
                            }
                        }

                        DSImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
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
                                },
                                onSelect: {
                                    onSelectProblem(problem.index)
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
