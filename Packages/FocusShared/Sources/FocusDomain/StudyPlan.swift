import Foundation

public struct StudyDay: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let date: String
    public let topic: String
    public let problems: [Problem]

    public init(id: Int, date: String, topic: String, problems: [Problem]) {
        self.id = id
        self.date = date
        self.topic = topic
        self.problems = problems
    }
}

public struct StudyPlan: Codable, Hashable, Sendable {
    public let preCompletedTopics: [String]
    public let days: [StudyDay]

    public init(preCompletedTopics: [String], days: [StudyDay]) {
        self.preCompletedTopics = preCompletedTopics
        self.days = days
    }
}
