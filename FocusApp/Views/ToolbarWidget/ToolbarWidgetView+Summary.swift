import SwiftUI

extension ToolbarWidgetView {
    var daySummary: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 5)

                Circle()
                    .trim(from: 0, to: presenter.progressPercentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int(presenter.progressPercentage))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(L10n.Widget.summaryDayFormat( presenter.currentDayNumber))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Text(L10n.Widget.summaryOfTotalFormat( dsaPlan.count))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }

                Text(L10n.Widget.summaryTopicTitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                Text(presenter.todaysTopic)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(L10n.Widget.summaryHabitsTitle)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                Text("\(presenter.habitsCompletedToday)/\(AppConstants.totalHabits)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(presenter.habitsCompletedToday == AppConstants.totalHabits ? .green : .white)
            }
        }
    }
}
