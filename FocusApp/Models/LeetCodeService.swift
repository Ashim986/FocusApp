import Foundation

protocol LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String>
    func fetchProblemContent(slug: String) async throws -> QuestionContent?
}

final class LeetCodeRestClient: LeetCodeClientProtocol {
    private let baseURL: URL
    private let requestBuilder: RequestBuilding
    private let executor: RequestExecuting
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        requestBuilder: RequestBuilding,
        executor: RequestExecuting,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.requestBuilder = requestBuilder
        self.executor = executor
        self.decoder = decoder
    }

    func validateUsername(_ username: String) async throws -> Bool {
        let request = try makeRequest(
            path: "\(username)"
        )
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeUserProfileResponse.self, from: data)
        guard let name = response.username?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return false
        }
        return true
    }

    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> {
        let request = try makeRequest(
            path: "\(username)/acSubmission",
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeRestSubmissionListResponse.self, from: data)
        let slugs = response.submissions.map { $0.titleSlug }
        return Set(slugs)
    }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        let request = try makeRequest(
            path: "select",
            queryItems: [
                URLQueryItem(name: "titleSlug", value: slug)
            ]
        )
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeRestProblemResponse.self, from: data)
        let snippets = Dictionary(uniqueKeysWithValues: response.codeSnippets.map { ($0.langSlug, $0.code) })
        let title = response.title.isEmpty ? slug.replacingOccurrences(of: "-", with: " ").capitalized : response.title

        return QuestionContent(
            title: title,
            content: response.content,
            exampleTestcases: response.exampleTestcases,
            sampleTestCase: response.sampleTestCase,
            difficulty: response.difficulty.isEmpty ? "Unknown" : response.difficulty,
            codeSnippets: snippets
        )
    }

    private func makeRequest(
        path: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        let fullURL = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else {
            throw LeetCodeError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw LeetCodeError.invalidURL
        }

        let endpoint = NetworkEndpoint(
            url: url,
            method: .get,
            headers: [
                "Accept": "application/json",
                "User-Agent": "FocusApp/1.0"
            ],
            body: nil
        )
        return requestBuilder.buildRequest(for: endpoint)
    }
}

struct LeetCodeSyncResult {
    let syncedCount: Int
    let totalMatched: Int
}

@MainActor
final class LeetCodeSyncInteractor {
    private let appStore: AppStateStore
    private let client: LeetCodeClientProtocol

    init(appStore: AppStateStore, client: LeetCodeClientProtocol) {
        self.appStore = appStore
        self.client = client
    }

    func validateUsername(_ username: String) async -> Bool {
        do {
            return try await client.validateUsername(username)
        } catch {
            return false
        }
    }

    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult {
        do {
            let solved = try await client.fetchSolvedSlugs(username: username, limit: limit)
            let result = appStore.applySolvedSlugs(solved)
            return LeetCodeSyncResult(syncedCount: result.syncedCount, totalMatched: result.totalMatched)
        } catch {
            return LeetCodeSyncResult(syncedCount: 0, totalMatched: 0)
        }
    }
}
