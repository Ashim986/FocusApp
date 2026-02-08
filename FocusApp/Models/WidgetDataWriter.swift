#if os(iOS)
import Foundation
import WidgetKit

/// Writes widget-compatible data to the shared App Group container.
/// Called from `AppStateStore` whenever data changes that could affect the widget.
enum WidgetDataWriter {
    static func write(from data: AppData, currentDay: Int, topic: String) {
        guard let fileURL = WidgetConstants.dataFileURL else { return }

        let dayProblems = dsaPlan.first(where: { $0.id == currentDay })?.problems ?? []
        let totalToday = dayProblems.count
        var completedToday = 0
        var widgetProblems: [WidgetProblem] = []

        for (index, problem) in dayProblems.enumerated() {
            let isCompleted = data.isProblemCompleted(day: currentDay, problemIndex: index)
            if isCompleted { completedToday += 1 }
            widgetProblems.append(WidgetProblem(
                id: "\(currentDay)-\(index)",
                name: problem.displayName,
                difficulty: problem.difficulty.rawValue,
                isCompleted: isCompleted
            ))
        }

        // Calculate total progress across all days
        var totalCompleted = 0
        var totalProblems = 0
        for day in dsaPlan {
            totalProblems += day.problems.count
            for idx in day.problems.indices
            where data.isProblemCompleted(day: day.id, problemIndex: idx) {
                totalCompleted += 1
            }
        }

        // Habits for today
        let todayStr = AppData.todayString()
        let todayHabits = data.habits[todayStr] ?? [:]
        let habitsCompleted = todayHabits.values.filter { $0 }.count

        let widgetData = WidgetData(
            currentDay: currentDay,
            topic: topic,
            completedToday: completedToday,
            totalToday: totalToday,
            totalCompleted: totalCompleted,
            totalProblems: totalProblems,
            habitsCompleted: habitsCompleted,
            habitsTotal: 3,
            problems: widgetProblems,
            lastUpdated: Date()
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(widgetData)
            try jsonData.write(to: fileURL, options: .atomic)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // Silently fail — widget will show stale data
        }
    }
}
#endif
