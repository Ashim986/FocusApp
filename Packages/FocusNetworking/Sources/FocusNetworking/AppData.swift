import Foundation

public struct AppData: Codable {
    public var progress: [String: Bool]
    public var habits: [String: [String: Bool]]
    public var dayOffset: Int
    public var planStartDate: Date
    public var leetCodeUsername: String
    public var savedSolutions: [String: String]
    public var submissions: [String: [CodeSubmission]]
    public var aiProviderKind: String
    public var aiProviderApiKey: String
    public var aiProviderModel: String
    public var leetCodeAuth: LeetCodeAuthSession?

    public init() {
        self.progress = [:]
        self.habits = [:]
        self.dayOffset = 0
        self.planStartDate = Self.startOfToday()
        self.leetCodeUsername = "ashim986"
        self.savedSolutions = [:]
        self.submissions = [:]
        self.aiProviderKind = "groq"
        self.aiProviderApiKey = ""
        self.aiProviderModel = ""
        self.leetCodeAuth = nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        progress = try container.decode([String: Bool].self, forKey: .progress)
        habits = try container.decode([String: [String: Bool]].self, forKey: .habits)
        dayOffset = try container.decodeIfPresent(Int.self, forKey: .dayOffset) ?? 0
        planStartDate = try container.decodeIfPresent(Date.self, forKey: .planStartDate) ?? Self.startOfToday()
        leetCodeUsername = try container.decodeIfPresent(String.self, forKey: .leetCodeUsername) ?? "ashim986"
        savedSolutions = try container.decodeIfPresent([String: String].self, forKey: .savedSolutions) ?? [:]
        submissions = try container.decodeIfPresent([String: [CodeSubmission]].self, forKey: .submissions) ?? [:]
        aiProviderKind = try container.decodeIfPresent(String.self, forKey: .aiProviderKind) ?? "groq"
        aiProviderApiKey = try container.decodeIfPresent(String.self, forKey: .aiProviderApiKey) ?? ""
        aiProviderModel = try container.decodeIfPresent(String.self, forKey: .aiProviderModel) ?? ""
        leetCodeAuth = try container.decodeIfPresent(LeetCodeAuthSession.self, forKey: .leetCodeAuth)
    }

    public func isProblemCompleted(day: Int, problemIndex: Int) -> Bool {
        let key = "\(day)-\(problemIndex)"
        return progress[key] ?? false
    }

    public func getHabitStatus(habit: String) -> Bool {
        let today = Self.todayString()
        return habits[today]?[habit] ?? false
    }

    public func completedProblemsCount(day: Int, totalProblems: Int) -> Int {
        var count = 0
        for index in 0..<totalProblems where isProblemCompleted(day: day, problemIndex: index) {
            count += 1
        }
        return count
    }

    public func totalCompletedProblems() -> Int {
        progress.values.filter { $0 }.count
    }

    public func todayHabitsCount() -> Int {
        let today = Self.todayString()
        guard let todayHabits = habits[today] else { return 0 }
        return todayHabits.values.filter { $0 }.count
    }

    public static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    public static func startOfToday(calendar: Calendar = Calendar.current) -> Date {
        calendar.startOfDay(for: Date())
    }
}

public struct CodeSubmission: Codable, Identifiable, Equatable {
    public let id: UUID
    public let languageSlug: String
    public let code: String
    public let createdAt: Date
    public let algorithmTag: String?

    public init(
        id: UUID,
        languageSlug: String,
        code: String,
        createdAt: Date,
        algorithmTag: String?
    ) {
        self.id = id
        self.languageSlug = languageSlug
        self.code = code
        self.createdAt = createdAt
        self.algorithmTag = algorithmTag
    }
}
