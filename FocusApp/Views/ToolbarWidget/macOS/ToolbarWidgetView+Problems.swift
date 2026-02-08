#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var todaysProblemsSection: some View {
        VStack(spacing: DSLayout.spacing(0)) {
            HStack {
                Text(L10n.Widget.problemsTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary.opacity(0.85))

                Spacer()

                let solved = presenter.todaysProblems.enumerated().filter { item in
                    presenter.data.isProblemCompleted(day: presenter.currentDayNumber, problemIndex: item.offset)
                }.count
                Text("\(solved)/\(presenter.todaysProblems.count)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(
                        solved == presenter.todaysProblems.count
                            ? theme.colors.success
                            : theme.colors.textSecondary
                    )
                    .padding(.horizontal, DSLayout.spacing(8))
                    .padding(.vertical, DSLayout.spacing(3))
                    .background(
                        Capsule()
                            .fill(
                                solved == presenter.todaysProblems.count
                                    ? theme.colors.success.opacity(0.18)
                                    : theme.colors.surfaceElevated.opacity(0.5)
                            )
                    )
            }
            .padding(.horizontal, DSLayout.spacing(2))
            .padding(.top, DSLayout.spacing(4))
            .padding(.bottom, DSLayout.spacing(6))

            ScrollView {
                VStack(spacing: DSLayout.spacing(2)) {
                    ForEach(Array(presenter.todaysProblems.enumerated()), id: \.element.id) { index, problem in
                        ProblemRowWidget(
                            problem: problem,
                            isCompleted: presenter.data.isProblemCompleted(
                                day: presenter.currentDayNumber,
                                problemIndex: index
                            ),
                            onRefresh: {
                                presenter.syncNow()
                            }
                        )
                    }
                }
                .padding(.horizontal, DSLayout.spacing(2))
            }
            .frame(maxHeight: 180)
        }
    }

    var nextDaySection: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(theme.colors.success)
            Text(L10n.Widget.problemsAllDone)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.colors.success)
            Spacer()
            DSButton(
                L10n.Widget.problemsStartDayFormat(presenter.tomorrowDayNumber),
                config: .init(
                    style: .primary,
                    size: .small,
                    icon: Image(systemName: "arrow.right.circle.fill"),
                    iconPosition: .trailing
                ),
                action: {
                    presenter.advanceToNextDay()
                }
            )
        }
        .padding(.horizontal, DSLayout.spacing(8))
        .padding(.vertical, DSLayout.spacing(6))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.colors.surfaceElevated.opacity(0.35))
        )
    }
}

#endif
