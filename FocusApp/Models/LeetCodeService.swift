import Foundation

protocol LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String>
    func fetchProblemContent(slug: String) async throws -> QuestionContent?
}

final class LeetCodeRestClient: LeetCodeClientProtocol {
    let baseURL: URL
    let graphQLURL: URL
    let requestBuilder: RequestBuilding
    let executor: RequestExecuting
    let decoder: JSONDecoder

    init(
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
