import Foundation

struct AppData: Codable {
    var progress: [String: Bool]  // "day-problemIndex": true/false
    var habits: [String: [String: Bool]]  // "2026-02-02": {"dsa": true, "exercise": false, "other": true}
    var dayOffset: Int  // Days advanced ahead of schedule (when completing all problems early)
    var leetCodeUsername: String  // LeetCode username for syncing

    init() {
        self.progress = [:]
        self.habits = [:]
        self.dayOffset = 0
        self.leetCodeUsername = "ashim986"  // Default username
    }

    // Custom decoder to handle missing fields in old data files
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        progress = try container.decode([String: Bool].self, forKey: .progress)
        habits = try container.decode([String: [String: Bool]].self, forKey: .habits)
        dayOffset = try container.decodeIfPresent(Int.self, forKey: .dayOffset) ?? 0
        leetCodeUsername = try container.decodeIfPresent(String.self, forKey: .leetCodeUsername) ?? "ashim986"
    }

    // Get completion status for a specific problem
    func isProblemCompleted(day: Int, problemIndex: Int) -> Bool {
        let key = "\(day)-\(problemIndex)"
        return progress[key] ?? false
    }

    // Get habit status for today
    func getHabitStatus(habit: String) -> Bool {
        let today = Self.todayString()
        return habits[today]?[habit] ?? false
    }

    // Count completed problems for a day
    func completedProblemsCount(day: Int, totalProblems: Int) -> Int {
        var count = 0
        for i in 0..<totalProblems {
            if isProblemCompleted(day: day, problemIndex: i) {
                count += 1
            }
        }
        return count
    }

    // Total completed problems across all days
    func totalCompletedProblems() -> Int {
        return progress.values.filter { $0 }.count
    }

    // Count completed topics (days where all 5 problems are done)
    func completedTopicsCount() -> Int {
        var count = 0
        for day in dsaPlan {
            if completedProblemsCount(day: day.id, totalProblems: day.problems.count) == day.problems.count {
                count += 1
            }
        }
        return count
    }

    // Today's habits count
    func todayHabitsCount() -> Int {
        let today = Self.todayString()
        guard let todayHabits = habits[today] else { return 0 }
        return todayHabits.values.filter { $0 }.count
    }

    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
