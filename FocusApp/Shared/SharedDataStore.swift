import FocusData
import Foundation

typealias AppStorage = FocusData.AppStorage
typealias FileAppStorage = FocusData.FileAppStorage
typealias InMemoryAppStorage = FocusData.InMemoryAppStorage

struct PlanCalendar {
    let calendar: Calendar
    let startDate: Date

    init(calendar: Calendar = Calendar.current, startDate: Date? = nil) {
        self.calendar = calendar
        if let startDate {
            self.startDate = startDate
        } else {
            self.startDate = calendar.startOfDay(for: Date())
        }
    }

    func baseDayNumber(today: Date) -> Int {
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        return min(max(daysDiff + 1, 1), dsaPlan.count)
    }

    func currentDayNumber(today: Date, offset: Int) -> Int {
        let baseDay = baseDayNumber(today: today)
        return min(baseDay + offset, dsaPlan.count)
    }
}

struct AppConstants {
    static let totalHabits = 3
    static let habitsList = ["dsa", "exercise", "other"]
}
