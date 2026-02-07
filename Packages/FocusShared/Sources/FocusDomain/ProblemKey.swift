import Foundation

public struct ProblemKey: Hashable, Codable, Sendable {
    public let dayID: Int
    public let problemIndex: Int

    public init(dayID: Int, problemIndex: Int) {
        self.dayID = dayID
        self.problemIndex = problemIndex
    }

    public var storageKey: String {
        "\(dayID)-\(problemIndex)"
    }
}
