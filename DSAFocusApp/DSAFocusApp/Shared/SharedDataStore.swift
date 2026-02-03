import Foundation

/// Shared data storage that can be accessed by both the main app and widgets
/// Uses home directory for shared file access (works without App Groups when sandbox is disabled)
struct SharedDataStore {
    static let dataFileName = ".dsa-focus-data.json"

    /// Use home directory for shared storage (works without App Groups)
    static var sharedDataFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(dataFileName)
    }

    /// Load AppData from the shared location
    static func loadData() -> AppData {
        let fileURL = sharedDataFileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return AppData()
        }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(AppData.self, from: jsonData)
        } catch {
            print("SharedDataStore: Failed to load data: \(error)")
            return AppData()
        }
    }

    /// Save AppData to the shared location
    static func saveData(_ data: AppData) {
        let fileURL = sharedDataFileURL

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch {
            print("SharedDataStore: Failed to save data: \(error)")
        }
    }

    /// Calculate overall progress percentage
    static func progressPercentage(from data: AppData) -> Double {
        let totalProblems = dsaPlan.reduce(0) { $0 + $1.problems.count }
        let completedProblems = data.totalCompletedProblems()
        guard totalProblems > 0 else { return 0 }
        return Double(completedProblems) / Double(totalProblems) * 100
    }

    /// Get today's day number based on the plan (without offset)
    static func baseDayNumber() -> Int {
        let calendar = Calendar.current
        let today = Date()

        // Plan starts Feb 3, 2026
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 3

        guard let startDate = calendar.date(from: components) else { return 1 }

        let daysDiff = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0

        // Clamp to valid range 1-13
        return min(max(daysDiff + 1, 1), 13)
    }

    /// Get current day number with offset (for advancing early)
    static func currentDayNumber(offset: Int = 0) -> Int {
        let baseDay = baseDayNumber()
        return min(baseDay + offset, 13)
    }

    /// Get today's day number (loads offset from saved data)
    static func currentDayNumber() -> Int {
        let data = loadData()
        return currentDayNumber(offset: data.dayOffset)
    }

    /// Get today's topic
    static func todaysTopic() -> String {
        let dayNum = currentDayNumber()
        return dsaPlan.first(where: { $0.id == dayNum })?.topic ?? "Linked List"
    }

    /// Get topic for a specific day
    static func topic(for day: Int) -> String {
        return dsaPlan.first(where: { $0.id == day })?.topic ?? "Unknown"
    }

    /// Get habits completed count for today
    static func habitsCompletedToday(from data: AppData) -> Int {
        return data.todayHabitsCount()
    }

    /// Total habits count
    static let totalHabits = 3

    /// Available habits
    static let habitsList = ["dsa", "exercise", "other"]
}
