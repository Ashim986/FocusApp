import SwiftUI

extension ToolbarWidgetView {
    var habitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habits")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 8) {
                HabitToggle(label: "DSA", icon: "book.fill", done: presenter.data.getHabitStatus(habit: "dsa")) {
                    presenter.toggleHabit("dsa")
                }
                HabitToggle(label: "Exercise", icon: "figure.run", done: presenter.data.getHabitStatus(habit: "exercise")) {
                    presenter.toggleHabit("exercise")
                }
                HabitToggle(label: "Other", icon: "lightbulb.fill", done: presenter.data.getHabitStatus(habit: "other")) {
                    presenter.toggleHabit("other")
                }
            }
        }
    }
}
