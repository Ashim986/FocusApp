import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var daySummary: some View {
        HStack(spacing: DSLayout.spacing(12)) {
            ZStack {
                Circle()
                    .stroke(theme.colors.border.opacity(0.4), lineWidth: 5)

                Circle()
                    .trim(from: 0, to: presenter.progressPercentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [theme.colors.primary, theme.colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int(presenter.progressPercentage))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(theme.colors.textPrimary)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                HStack(spacing: DSLayout.spacing(4)) {
                    Text(L10n.Widget.summaryDayFormat( presenter.currentDayNumber))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Text(L10n.Widget.summaryOfTotalFormat( dsaPlan.count))
                        .font(.system(size: 10))
                        .foregroundColor(theme.colors.textSecondary)
                }

                Text(L10n.Widget.summaryTopicTitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)

                Text(presenter.todaysTopic)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary.opacity(0.9))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DSLayout.spacing(2)) {
                Text(L10n.Widget.summaryHabitsTitle)
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
                Text("\(presenter.habitsCompletedToday)/\(AppConstants.totalHabits)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(
                        presenter.habitsCompletedToday == AppConstants.totalHabits
                            ? theme.colors.success
                            : theme.colors.textPrimary
                    )
            }
        }
    }
}
