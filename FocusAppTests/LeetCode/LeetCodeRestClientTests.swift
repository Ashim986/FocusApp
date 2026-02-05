@testable import FocusApp
import XCTest

final class LeetCodeRestClientTests: XCTestCase {
    func testValidateUsernameReturnsTrue() async throws {
        let builder = CapturingRequestBuilder()
        let executor = StubRequestExecutor()
        executor.data = Data("{\"username\":\"valid\"}".utf8)
        let client = LeetCodeRestClient(baseURL: URL(string: "https://example.com")!, requestBuilder: builder, executor: executor)

        let isValid = try await client.validateUsername("valid")

        XCTAssertTrue(isValid)
        XCTAssertEqual(builder.lastEndpoint?.url.path, "/valid")
    }

    func testValidateUsernameReturnsFalseOnEmpty() async throws {
        let builder = CapturingRequestBuilder()
        let executor = StubRequestExecutor()
        executor.data = Data("{\"username\":\"\"}".utf8)
        let client = LeetCodeRestClient(baseURL: URL(string: "https://example.com")!, requestBuilder: builder, executor: executor)

        let isValid = try await client.validateUsername("empty")

        XCTAssertFalse(isValid)
    }

    func testFetchSolvedSlugsIncludesLimitQuery() async throws {
        let builder = CapturingRequestBuilder()
        let executor = StubRequestExecutor()
        executor.data = Data("{\"submission\":[{\"titleSlug\":\"a\"},{\"titleSlug\":\"b\"},{\"titleSlug\":\"a\"}]}".utf8)
        let client = LeetCodeRestClient(baseURL: URL(string: "https://example.com")!, requestBuilder: builder, executor: executor)

        let slugs = try await client.fetchSolvedSlugs(username: "user", limit: 20)

        XCTAssertEqual(slugs, ["a", "b"])
        XCTAssertTrue(builder.lastEndpoint?.url.query?.contains("limit=20") == true)
    }

    func testFetchSolvedSlugsFallsBackToGraphQLAll() async throws {
        let builder = CapturingRequestBuilder()
        let graphQLResponse = """
        {"data":{"recentAcSubmissionList":[{"titleSlug":"add-two-numbers"}]}}
        """
        let executor = SequenceRequestExecutor(responses: [
            Data("{\"submission\":[]}".utf8),
            Data("{\"submission\":[]}".utf8),
            Data(graphQLResponse.utf8)
        ])
        let client = LeetCodeRestClient(
            baseURL: URL(string: "https://example.com")!,
            graphQLURL: LeetCodeConstants.graphQLBaseURL,
            requestBuilder: builder,
            executor: executor
        )

        let slugs = try await client.fetchSolvedSlugs(
            username: "user",
            limit: LeetCodeConstants.manualSubmissionsLimit
        )

        XCTAssertEqual(slugs, ["add-two-numbers"])
        XCTAssertEqual(builder.lastEndpoint?.url, LeetCodeConstants.graphQLBaseURL)
    }

    func testFetchProblemContentMapsSnippets() async throws {
        let builder = CapturingRequestBuilder()
        let executor = StubRequestExecutor()
        let json = """
        {"title":"","content":"<p>Body</p>","exampleTestcases":"1","sampleTestCase":"1","difficulty":"Medium",
        "codeSnippets":[{"langSlug":"python3","code":"print(1)"}]}
        """
        executor.data = Data(json.utf8)
        let client = LeetCodeRestClient(baseURL: URL(string: "https://example.com")!, requestBuilder: builder, executor: executor)

        let content = try await client.fetchProblemContent(slug: "two-sum")

        XCTAssertEqual(content?.codeSnippets["python3"], "print(1)")
        XCTAssertEqual(content?.content, "<p>Body</p>")
    }
}

private final class CapturingRequestBuilder: RequestBuilding {
    private(set) var lastEndpoint: NetworkEndpoint?

    func buildRequest(for endpoint: NetworkEndpoint) -> URLRequest {
        lastEndpoint = endpoint
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

private final class StubRequestExecutor: RequestExecuting {
    var data = Data()
    var error: Error?

    func execute(_ request: URLRequest) async throws -> Data {
        if let error {
            throw error
        }
        return data
    }
}

private final class SequenceRequestExecutor: RequestExecuting {
    private var responses: [Data]

    init(responses: [Data]) {
        self.responses = responses
    }

    func execute(_ request: URLRequest) async throws -> Data {
        guard !responses.isEmpty else {
            throw LeetCodeError.noData
        }
        return responses.removeFirst()
    }
}
