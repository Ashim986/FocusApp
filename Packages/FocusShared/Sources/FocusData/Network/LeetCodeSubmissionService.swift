import Foundation

public struct LeetCodeSubmissionService {
    private let executor: RequestExecuting
    private let decoder: JSONDecoder

    public init(
        executor: RequestExecuting,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.executor = executor
        self.decoder = decoder
    }

    public func submit(
        code: String,
        languageSlug: String,
        slug: String,
        questionId: String,
        auth: LeetCodeAuthSession
    ) async throws -> LeetCodeSubmissionCheck {
        let submitURLString = "https://leetcode.com/problems/\(slug)/submit/"
        guard let submitURL = URL(string: submitURLString) else {
            throw LeetCodeSubmissionError.invalidURL
        }

        let requestBody = LeetCodeSubmitRequest(
            lang: languageSlug,
            questionId: questionId,
            typedCode: code
        )

        let request = try buildRequest(
            url: submitURL,
            method: .post,
            auth: auth,
            slug: slug,
            body: requestBody
        )

        let submitData = try await executor.execute(request)
        let submitResponse: LeetCodeSubmitResponse
        do {
            submitResponse = try decoder.decode(LeetCodeSubmitResponse.self, from: submitData)
        } catch {
            let body = String(data: submitData.prefix(500), encoding: .utf8) ?? "<binary>"
            throw LeetCodeSubmissionError.submissionFailed(
                "Unexpected response from LeetCode (decode error). Preview: \(body)"
            )
        }
        if let error = submitResponse.error, !error.isEmpty {
            throw LeetCodeSubmissionError.submissionFailed(error)
        }
        guard let submissionId = submitResponse.submissionId else {
            throw LeetCodeSubmissionError.invalidResponse
        }

        return try await pollSubmission(
            id: submissionId,
            auth: auth,
            slug: slug
        )
    }

    private func pollSubmission(
        id: Int,
        auth: LeetCodeAuthSession,
        slug: String
    ) async throws -> LeetCodeSubmissionCheck {
        let checkURLString = "https://leetcode.com/submissions/detail/\(id)/check/"
        guard let checkURL = URL(string: checkURLString) else {
            throw LeetCodeSubmissionError.invalidURL
        }

        var attempts = 0
        var decodeFailures = 0
        let maxDecodeFailures = 5

        while attempts < 40 {
            if Task.isCancelled { throw CancellationError() }

            let request = try buildRequest(
                url: checkURL,
                method: .get,
                auth: auth,
                slug: slug
            )
            let data = try await executor.execute(request)
            let status: LeetCodeSubmissionCheck
            do {
                status = try decoder.decode(LeetCodeSubmissionCheck.self, from: data)
            } catch {
                decodeFailures += 1
                if decodeFailures >= maxDecodeFailures {
                    let body = String(data: data.prefix(500), encoding: .utf8) ?? "<binary>"
                    throw LeetCodeSubmissionError.submissionFailed(
                        "LeetCode returned unreadable responses (\(decodeFailures) times). Preview: \(body)"
                    )
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continue
            }
            if status.isComplete {
                return status
            }
            attempts += 1
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        throw LeetCodeSubmissionError.timeout
    }

    private func buildRequest<T: Encodable>(
        url: URL,
        method: HTTPMethod,
        auth: LeetCodeAuthSession,
        slug: String,
        body: T?
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Origin")
        request.setValue("https://leetcode.com/problems/\(slug)/", forHTTPHeaderField: "Referer")
        request.setValue(auth.csrfToken, forHTTPHeaderField: "X-CSRFToken")

        let cookieHeader = [
            "LEETCODE_SESSION=\(auth.session)",
            "csrftoken=\(auth.csrfToken)"
        ].joined(separator: "; ")
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return request
    }

    private func buildRequest(
        url: URL,
        method: HTTPMethod,
        auth: LeetCodeAuthSession,
        slug: String
    ) throws -> URLRequest {
        try buildRequest(
            url: url,
            method: method,
            auth: auth,
            slug: slug,
            body: Optional<LeetCodeSubmitRequest>.none
        )
    }
}

private struct LeetCodeSubmitRequest: Encodable {
    let lang: String
    let questionId: String
    let typedCode: String

    enum CodingKeys: String, CodingKey {
        case lang
        case questionId = "question_id"
        case typedCode = "typed_code"
    }
}

private struct LeetCodeSubmitResponse: Decodable {
    let submissionId: Int?
    let statusCode: Int?
    let statusMsg: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case submissionId = "submission_id"
        case statusCode = "status_code"
        case statusMsg = "status_msg"
        case error
    }
}

public struct LeetCodeSubmissionCheck: Decodable, Sendable {
    public let state: String?
    public let finished: Bool?
    public let statusCode: Int?
    public let statusMsg: String?
    public let runSuccess: Bool?
    public let totalTestcases: Int?
    public let totalCorrect: Int?
    public let runtimeError: String?
    public let compileError: String?
    public let lastTestcase: String?
    public let expectedOutput: String?
    public let codeOutput: String?
    public let stdout: String?
    public let memory: String?
    public let statusMemory: String?
    public let runtime: String?
    public let statusRuntime: String?
    public let runtimePercentile: Double?
    public let memoryPercentile: Double?

    enum CodingKeys: String, CodingKey {
        case state
        case finished
        case statusCode = "status_code"
        case statusMsg = "status_msg"
        case runSuccess = "run_success"
        case totalTestcases = "total_testcases"
        case totalCorrect = "total_correct"
        case runtimeError = "runtime_error"
        case compileError = "compile_error"
        case lastTestcase = "last_testcase"
        case expectedOutput = "expected_output"
        case codeOutput = "code_output"
        case stdout
        case memory
        case statusMemory = "status_memory"
        case runtime
        case statusRuntime = "status_runtime"
        case runtimePercentile = "runtime_percentile"
        case memoryPercentile = "memory_percentile"
    }

    public var isComplete: Bool {
        if finished == true { return true }
        if let state, state.uppercased() == "SUCCESS" { return true }
        return false
    }
}
