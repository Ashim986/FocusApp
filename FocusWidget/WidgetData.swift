import Foundation

/// Lightweight data model shared between the main app and the widget extension.
/// Serialized to JSON in the shared App Group container.
struct WidgetData: Codable {
    let currentDay: Int
    let topic: String
    let completedToday: Int
    let totalToday: Int
    let totalCompleted: Int
    let totalProblems: Int
    let habitsCompleted: Int
    let habitsTotal: Int
    let problems: [WidgetProblem]
    let lastUpdated: Date

    static let empty = WidgetData(
        currentDay: 1,
        topic: "Getting Started",
        completedToday: 0,
        totalToday: 0,
        totalCompleted: 0,
        totalProblems: 0,
        habitsCompleted: 0,
        habitsTotal: 3,
        problems: [],
        lastUpdated: Date()
    )
}

struct WidgetProblem: Codable, Identifiable {
    let id: String
    let name: String
    let difficulty: String
    let isCompleted: Bool
}

// MARK: - Shared Constants

enum WidgetConstants {
    static let appGroupID = "group.com.dsafocus.focusapp"
    static let dataFileName = "widget-data.json"

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        )
    }

    static var dataFileURL: URL? {
        sharedContainerURL?.appendingPathComponent(dataFileName)
    }
}

// MARK: - Data Reader (used by widget)

enum WidgetDataReader {
    static func load() -> WidgetData {
        guard let fileURL = WidgetConstants.dataFileURL,
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return .empty
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(WidgetData.self, from: data)
        } catch {
            return .empty
        }
    }
}
