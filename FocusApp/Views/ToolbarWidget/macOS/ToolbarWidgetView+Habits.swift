#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var habitsSection: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(8)) {
            Text(L10n.Widget.habitsTitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary.opacity(0.85))

            HStack(spacing: DSLayout.spacing(8)) {
                HabitToggle(
                    label: L10n.Habit.Label.dsa,
                    icon: "book.fill",
                    done: presenter.data.getHabitStatus(habit: "dsa")
                ) {
                    presenter.toggleHabit("dsa")
                }
                HabitToggle(
                    label: L10n.Habit.Label.exercise,
                    icon: "figure.run",
                    done: presenter.data.getHabitStatus(habit: "exercise")
                ) {
                    presenter.toggleHabit("exercise")
                }
                HabitToggle(
                    label: L10n.Habit.Label.other,
                    icon: "lightbulb.fill",
                    done: presenter.data.getHabitStatus(habit: "other")
                ) {
                    presenter.toggleHabit("other")
                }
            }
        }
    }
}

#endif
