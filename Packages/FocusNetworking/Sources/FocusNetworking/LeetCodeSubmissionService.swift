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
                if let recovered = decodeSubmissionCheckLeniently(from: data) {
                    if recovered.isComplete {
                        return recovered
                    }
                    attempts += 1
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    continue
                }
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

    private func decodeSubmissionCheckLeniently(from data: Data) -> LeetCodeSubmissionCheck? {
        // LeetCode occasionally returns non-JSON prefixes/suffixes (or HTML) for the check endpoint.
        // Try to recover by extracting the first JSON object from the payload.
        guard let start = data.firstIndex(of: 0x7B), // "{"
              let end = data.lastIndex(of: 0x7D),   // "}"
              start < end else {
            return nil
        }
        let slice = data[start...end]
        return try? decoder.decode(LeetCodeSubmissionCheck.self, from: Data(slice))
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        state = container.decodeLossyStringIfPresent(forKey: .state)
        finished = container.decodeLossyBoolIfPresent(forKey: .finished)
        statusCode = container.decodeLossyIntIfPresent(forKey: .statusCode)
        statusMsg = container.decodeLossyStringIfPresent(forKey: .statusMsg)
        runSuccess = container.decodeLossyBoolIfPresent(forKey: .runSuccess)
        totalTestcases = container.decodeLossyIntIfPresent(forKey: .totalTestcases)
        totalCorrect = container.decodeLossyIntIfPresent(forKey: .totalCorrect)
        runtimeError = container.decodeLossyStringIfPresent(forKey: .runtimeError)
        compileError = container.decodeLossyStringIfPresent(forKey: .compileError)
        lastTestcase = container.decodeLossyStringIfPresent(forKey: .lastTestcase)
        expectedOutput = container.decodeLossyStringIfPresent(forKey: .expectedOutput)
        codeOutput = container.decodeLossyStringIfPresent(forKey: .codeOutput)
        stdout = container.decodeLossyStringIfPresent(forKey: .stdout)
        memory = container.decodeLossyStringIfPresent(forKey: .memory)
        statusMemory = container.decodeLossyStringIfPresent(forKey: .statusMemory)
        runtime = container.decodeLossyStringIfPresent(forKey: .runtime)
        statusRuntime = container.decodeLossyStringIfPresent(forKey: .statusRuntime)
        runtimePercentile = container.decodeLossyDoubleIfPresent(forKey: .runtimePercentile)
        memoryPercentile = container.decodeLossyDoubleIfPresent(forKey: .memoryPercentile)
    }

    public var isComplete: Bool {
        if finished == true { return true }
        if let state, state.uppercased() == "SUCCESS" { return true }
        return false
    }
}

extension KeyedDecodingContainer {
    fileprivate func decodeLossyStringIfPresent(forKey key: Key) -> String? {
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return String(value)
        }
        if let value = try? decodeIfPresent(Bool.self, forKey: key) {
            return value ? "true" : "false"
        }
        return nil
    }

    fileprivate func decodeLossyIntIfPresent(forKey key: Key) -> Int? {
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(value)
        }
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if let value = try? decodeIfPresent(Bool.self, forKey: key) {
            return value ? 1 : 0
        }
        return nil
    }

    fileprivate func decodeLossyDoubleIfPresent(forKey key: Key) -> Double? {
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return Double(value)
        }
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return Double(value.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if let value = try? decodeIfPresent(Bool.self, forKey: key) {
            return value ? 1 : 0
        }
        return nil
    }

    fileprivate func decodeLossyBoolIfPresent(forKey key: Key) -> Bool? {
        if let value = try? decodeIfPresent(Bool.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value != 0
        }
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return value != 0
        }
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "true", "1", "yes", "y", "t":
                return true
            case "false", "0", "no", "n", "f":
                return false
            default:
                return nil
            }
        }
        return nil
    }
}
