import Foundation

protocol AppStorage {
    func load() -> AppData
    func save(_ data: AppData)
}

struct FileAppStorage: AppStorage {
    private let fileURL: URL

    init(fileURL: URL = Self.defaultFileURL) {
        self.fileURL = fileURL
    }

    func load() -> AppData {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return AppData()
        }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(AppData.self, from: jsonData)
        } catch {
            print("FileAppStorage: Failed to load data: \(error)")
            return AppData()
        }
    }

    func save(_ data: AppData) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch {
            print("FileAppStorage: Failed to save data: \(error)")
        }
    }

    static var defaultFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".dsa-focus-data.json")
    }
}

struct PlanCalendar {
    let calendar: Calendar
    let startDate: Date

    init(calendar: Calendar = Calendar.current, startDate: Date? = nil) {
        self.calendar = calendar
        if let startDate {
            self.startDate = startDate
        } else {
            var components = DateComponents()
            components.year = 2026
            components.month = 2
            components.day = 3
            self.startDate = calendar.date(from: components) ?? Date()
        }
    }

    func baseDayNumber(today: Date) -> Int {
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        return min(max(daysDiff + 1, 1), 13)
    }

    func currentDayNumber(today: Date, offset: Int) -> Int {
        let baseDay = baseDayNumber(today: today)
        return min(baseDay + offset, 13)
    }
}

struct AppConstants {
    static let totalHabits = 3
    static let habitsList = ["dsa", "exercise", "other"]
}
