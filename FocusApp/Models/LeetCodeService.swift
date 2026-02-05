import Foundation

protocol LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String>
    func fetchProblemContent(slug: String) async throws -> QuestionContent?
}

final class LeetCodeRestClient: LeetCodeClientProtocol {
    private let baseURL: URL
    private let graphQLURL: URL
    private let requestBuilder: RequestBuilding
    private let executor: RequestExecuting
    private let decoder: JSONDecoder

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
        var slugs = Set<String>()
        let cappedLimit = min(limit, LeetCodeConstants.manualSubmissionsLimit)

        do {
            let submissions = try await fetchSubmissions(
                username: username,
                path: "acSubmission",
                limit: cappedLimit
            )
            slugs.formUnion(submissions.map { $0.titleSlug })
        } catch {
            // Fall through to attempt broader submission fetch
        }

        if slugs.isEmpty {
            do {
                let submissions = try await fetchSubmissions(
                    username: username,
                    path: "submission",
                    limit: cappedLimit
                )
                let accepted = submissions.filter { submission in
                    submission.statusDisplay?.caseInsensitiveCompare("accepted") == .orderedSame
                }
                slugs.formUnion(accepted.map { $0.titleSlug })
            } catch {
                // Fall through to GraphQL fallback
            }
        }

        guard slugs.isEmpty else { return slugs }

        if limit >= LeetCodeConstants.manualSubmissionsLimit {
            if let fallback = try? await fetchSolvedSlugsGraphQLAll(username: username, limit: cappedLimit) {
                return fallback
            }
        }

        return (try? await fetchSolvedSlugsGraphQLRecent(
            username: username,
            limit: min(cappedLimit, 200)
        )) ?? []
    }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        var restContent: QuestionContent?

        do {
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

            restContent = QuestionContent(
                title: title,
                content: response.content,
                exampleTestcases: response.exampleTestcases,
                sampleTestCase: response.sampleTestCase,
                difficulty: response.difficulty.isEmpty ? "Unknown" : response.difficulty,
                codeSnippets: snippets,
                metaData: response.metaData
            )
        } catch {
            // Fall through to GraphQL fallback
        }

        if let restContent {
            let needsFallback = restContent.metaData == nil || restContent.codeSnippets.isEmpty
            if needsFallback, let fallback = try? await fetchProblemContentGraphQL(slug: slug) {
                return mergeProblemContent(primary: restContent, fallback: fallback, slug: slug)
            }
            return restContent
        }

        return try? await fetchProblemContentGraphQL(slug: slug)
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

    private func makeGraphQLRequest(query: String, variables: [String: Any]) throws -> URLRequest {
        let body = try JSONSerialization.data(withJSONObject: [
            "query": query,
            "variables": variables
        ])
        let endpoint = NetworkEndpoint(
            url: graphQLURL,
            method: .post,
            headers: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "User-Agent": "FocusApp/1.0"
            ],
            body: body
        )
        return requestBuilder.buildRequest(for: endpoint)
    }

    private func fetchSubmissions(
        username: String,
        path: String,
        limit: Int
    ) async throws -> [LeetCodeRestSubmission] {
        let request = try makeRequest(
            path: "\(username)/\(path)",
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeRestSubmissionListResponse.self, from: data)
        return response.submissions
    }

    private func fetchSolvedSlugsGraphQLRecent(username: String, limit: Int) async throws -> Set<String> {
        let submissions = try await fetchGraphQLAcSubmissions(
            username: username,
            limit: min(limit, 200),
            offset: nil
        )
        return Set(submissions.map { $0.titleSlug })
    }

    private func fetchSolvedSlugsGraphQLAll(username: String, limit: Int) async throws -> Set<String> {
        let targetLimit = min(limit, LeetCodeConstants.manualSubmissionsLimit)
        let pageSize = min(200, targetLimit)
        var offset = 0
        var slugs = Set<String>()
        var seen = Set<String>()

        while offset < targetLimit {
            let submissions = try await fetchGraphQLAcSubmissions(
                username: username,
                limit: pageSize,
                offset: offset
            )
            if submissions.isEmpty { break }

            let beforeCount = slugs.count
            for submission in submissions where seen.insert(submission.titleSlug).inserted {
                slugs.insert(submission.titleSlug)
            }
            if slugs.count == beforeCount { break }
            if submissions.count < pageSize { break }

            offset += pageSize
        }

        if slugs.isEmpty {
            return try await fetchSolvedSlugsGraphQLRecent(username: username, limit: targetLimit)
        }

        return slugs
    }

    private func fetchGraphQLAcSubmissions(
        username: String,
        limit: Int,
        offset: Int?
    ) async throws -> [LeetCodeGraphQLSubmission] {
        let query: String
        var variables: [String: Any] = [
            "username": username,
            "limit": limit
        ]

        if let offset {
            query = """
            query recentAcSubmissions($username: String!, $limit: Int!, $offset: Int!) {
              recentAcSubmissionList(username: $username, limit: $limit, offset: $offset) {
                titleSlug
              }
            }
            """
            variables["offset"] = offset
        } else {
            query = """
            query recentAcSubmissions($username: String!, $limit: Int!) {
              recentAcSubmissionList(username: $username, limit: $limit) {
                titleSlug
              }
            }
            """
        }

        let request = try makeGraphQLRequest(query: query, variables: variables)
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeGraphQLResponse<LeetCodeRecentAcSubmissionsData>.self, from: data)
        if let errors = response.errors, !errors.isEmpty {
            let message = errors.map { $0.message }.joined(separator: "; ")
            throw LeetCodeError.graphQLError(message)
        }
        return response.data?.recentAcSubmissionList ?? []
    }

    private func fetchProblemContentGraphQL(slug: String) async throws -> QuestionContent? {
        let query = """
        query questionData($titleSlug: String!) {
          question(titleSlug: $titleSlug) {
            title
            content
            exampleTestcases
            sampleTestCase
            difficulty
            codeSnippets {
              langSlug
              code
            }
            metaData
          }
        }
        """
        let request = try makeGraphQLRequest(query: query, variables: ["titleSlug": slug])
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeGraphQLResponse<LeetCodeGraphQLQuestionData>.self, from: data)
        if let errors = response.errors, !errors.isEmpty {
            let message = errors.map { $0.message }.joined(separator: "; ")
            throw LeetCodeError.graphQLError(message)
        }
        guard let question = response.data?.question else { return nil }

        let snippets = Dictionary(uniqueKeysWithValues: question.codeSnippets.map { ($0.langSlug, $0.code) })
        let title = question.title.isEmpty ? slug.replacingOccurrences(of: "-", with: " ").capitalized : question.title

        return QuestionContent(
            title: title,
            content: question.content,
            exampleTestcases: question.exampleTestcases,
            sampleTestCase: question.sampleTestCase,
            difficulty: question.difficulty.isEmpty ? "Unknown" : question.difficulty,
            codeSnippets: snippets,
            metaData: question.metaData
        )
    }

    private func mergeProblemContent(
        primary: QuestionContent,
        fallback: QuestionContent,
        slug: String
    ) -> QuestionContent {
        let title = primary.title.isEmpty ? fallback.title : primary.title
        let content = primary.content.isEmpty ? fallback.content : primary.content
        let exampleTestcases = primary.exampleTestcases.isEmpty
            ? fallback.exampleTestcases
            : primary.exampleTestcases
        let sampleTestCase = primary.sampleTestCase.isEmpty
            ? fallback.sampleTestCase
            : primary.sampleTestCase
        let difficulty = primary.difficulty == "Unknown" ? fallback.difficulty : primary.difficulty
        let snippets = primary.codeSnippets.isEmpty ? fallback.codeSnippets : primary.codeSnippets
        let metaData = primary.metaData ?? fallback.metaData
        let normalizedTitle = title.isEmpty ? slug.replacingOccurrences(of: "-", with: " ").capitalized : title

        return QuestionContent(
            title: normalizedTitle,
            content: content,
            exampleTestcases: exampleTestcases,
            sampleTestCase: sampleTestCase,
            difficulty: difficulty.isEmpty ? "Unknown" : difficulty,
            codeSnippets: snippets,
            metaData: metaData
        )
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
    private let logger: DebugLogRecording?

    init(
        appStore: AppStateStore,
        client: LeetCodeClientProtocol,
        logger: DebugLogRecording? = nil
    ) {
        self.appStore = appStore
        self.client = client
        self.logger = logger
    }

    func validateUsername(_ username: String) async -> Bool {
        do {
            return try await client.validateUsername(username)
        } catch {
            return false
        }
    }

    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult {
        logger?.recordAsync(
            DebugLogEntry(
                level: .info,
                category: .sync,
                title: "Sync started",
                message: "Fetching solved problems",
                metadata: [
                    "username": username,
                    "limit": "\(limit)"
                ]
            )
        )
        do {
            let solved = try await client.fetchSolvedSlugs(username: username, limit: limit)
            let result = appStore.applySolvedSlugs(solved)
            logger?.recordAsync(
                DebugLogEntry(
                    level: .info,
                    category: .sync,
                    title: "Sync complete",
                    message: "Updated progress",
                    metadata: [
                        "matched": "\(result.totalMatched)",
                        "new": "\(result.syncedCount)"
                    ]
                )
            )
            return LeetCodeSyncResult(syncedCount: result.syncedCount, totalMatched: result.totalMatched)
        } catch {
            logger?.recordAsync(
                DebugLogEntry(
                    level: .error,
                    category: .sync,
                    title: "Sync failed",
                    message: "Unable to fetch solved problems",
                    metadata: [
                        "error": error.localizedDescription
                    ]
                )
            )
            return LeetCodeSyncResult(syncedCount: 0, totalMatched: 0)
        }
    }
}
