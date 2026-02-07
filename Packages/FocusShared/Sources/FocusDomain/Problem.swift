import Foundation

public struct Problem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public let name: String
    public let difficulty: Difficulty
    public let url: String
    public let leetcodeNumber: Int?

    public init(
        id: UUID = UUID(),
        name: String,
        difficulty: Difficulty,
        url: String,
        leetcodeNumber: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.url = url
        self.leetcodeNumber = leetcodeNumber
    }

    public var displayName: String {
        guard let leetcodeNumber else { return name }
        return "#\(leetcodeNumber) \(name)"
    }
}
