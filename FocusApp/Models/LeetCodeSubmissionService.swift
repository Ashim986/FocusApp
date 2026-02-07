import Foundation

enum LeetCodeSubmissionError: Error, LocalizedError {
    case missingAuth
    case invalidURL
    case invalidResponse
    case submissionFailed(String)
    case timeout

    var errorDescription: String? {
        switch self {
        case .missingAuth:
            return "LeetCode login required."
        case .invalidURL:
            return "Invalid LeetCode submission URL."
        case .invalidResponse:
            return "Invalid response from LeetCode."
        case .submissionFailed(let message):
            return message
        case .timeout:
            return "LeetCode submission timed out."
        }
    }
}

struct LeetCodeSubmissionService {
    private let executor: RequestExecuting
    private let decoder: JSONDecoder

    init(
        executor: RequestExecuting,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.executor = executor
        self.decoder = decoder
    }

    func submit(
        code: String,
        language: ProgrammingLanguage,
        slug: String,
        questionId: String,
        auth: LeetCodeAuthSession
    ) async throws -> LeetCodeSubmissionCheck {
        let submitURLString = "https://leetcode.com/problems/\(slug)/submit/"
        guard let submitURL = URL(string: submitURLString) else {
            throw LeetCodeSubmissionError.invalidURL
        }

        let requestBody = LeetCodeSubmitRequest(
            lang: language.langSlug,
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
        let submitResponse = try decoder.decode(LeetCodeSubmitResponse.self, from: submitData)
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
        while attempts < 40 {
            if Task.isCancelled { throw CancellationError() }
            let request = try buildRequest(
                url: checkURL,
                method: .get,
                auth: auth,
                slug: slug
            )
            let data = try await executor.execute(request)
            let status = try decoder.decode(LeetCodeSubmissionCheck.self, from: data)
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

struct LeetCodeSubmissionCheck: Decodable {
    let state: String?
    let statusCode: Int?
    let statusMsg: String?
    let totalTestcases: Int?
    let totalCorrect: Int?
    let runtimeError: String?
    let compileError: String?
    let lastTestcase: String?
    let expectedOutput: String?
    let codeOutput: String?
    let stdout: String?
    let memory: String?
    let runtime: String?

    enum CodingKeys: String, CodingKey {
        case state
        case statusCode = "status_code"
        case statusMsg = "status_msg"
        case totalTestcases = "total_testcases"
        case totalCorrect = "total_correct"
        case runtimeError = "runtime_error"
        case compileError = "compile_error"
        case lastTestcase = "last_testcase"
        case expectedOutput = "expected_output"
        case codeOutput = "code_output"
        case stdout
        case memory
        case runtime
    }

    var isComplete: Bool {
        guard let state else { return false }
        return state.uppercased() == "SUCCESS"
    }
}
