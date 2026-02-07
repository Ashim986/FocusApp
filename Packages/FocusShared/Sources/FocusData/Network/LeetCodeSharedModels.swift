import Foundation

public struct QuestionContent: Sendable, Equatable {
    public let title: String
    public let content: String
    public let exampleTestcases: String
    public let sampleTestCase: String
    public let difficulty: String
    public let codeSnippets: [String: String]
    public let metaData: String?
    public let questionId: String?

    public init(
        title: String,
        content: String,
        exampleTestcases: String,
        sampleTestCase: String,
        difficulty: String,
        codeSnippets: [String: String],
        metaData: String?,
        questionId: String?
    ) {
        self.title = title
        self.content = content
        self.exampleTestcases = exampleTestcases
        self.sampleTestCase = sampleTestCase
        self.difficulty = difficulty
        self.codeSnippets = codeSnippets
        self.metaData = metaData
        self.questionId = questionId
    }
}

public struct LeetCodeAuthSession: Codable, Equatable, Sendable {
    public let session: String
    public let csrfToken: String
    public let updatedAt: Date

    public init(session: String, csrfToken: String, updatedAt: Date) {
        self.session = session
        self.csrfToken = csrfToken
        self.updatedAt = updatedAt
    }
}
