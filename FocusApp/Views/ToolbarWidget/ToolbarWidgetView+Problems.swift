import SwiftUI

extension ToolbarWidgetView {
    var todaysProblemsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.Widget.problemsTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                let solved = presenter.todaysProblems.enumerated().filter { item in
                    presenter.data.isProblemCompleted(day: presenter.currentDayNumber, problemIndex: item.offset)
                }.count
                Text("\(solved)/\(presenter.todaysProblems.count)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(solved == presenter.todaysProblems.count ? .green : .white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                solved == presenter.todaysProblems.count
                                    ? Color.green.opacity(0.2)
                                    : Color.white.opacity(0.08)
                            )
                    )
            }
            .padding(.horizontal, 2)
            .padding(.top, 4)
            .padding(.bottom, 6)

            ScrollView {
                VStack(spacing: 2) {
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
                .padding(.horizontal, 2)
            }
            .frame(maxHeight: 180)
        }
    }

    var nextDaySection: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
            Text(L10n.Widget.problemsAllDone)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.green)
            Spacer()
            Button(action: {
                presenter.advanceToNextDay()
            }, label: {
                HStack(spacing: 4) {
                    Text(L10n.Widget.problemsStartDayFormat(presenter.tomorrowDayNumber))
                        .font(.system(size: 10, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            })
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
        )
    }
}
