import Foundation

public protocol LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String>
    func fetchProblemContent(slug: String) async throws -> QuestionContent?
}

public final class LeetCodeRestClient: LeetCodeClientProtocol {
    public let baseURL: URL
    public let graphQLURL: URL
    public let requestBuilder: RequestBuilding
    public let executor: RequestExecuting
    public let decoder: JSONDecoder

    public init(
        baseURL: URL,
        graphQLURL: URL = LeetCodeConstants.graphQLBaseURL,
        requestBuilder: RequestBuilding,
        executor: RequestExecuting,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.graphQLURL = graphQLURL
        self.requestBuilder = requestBuilder
        self.executor = executor
        self.decoder = decoder
    }
}
