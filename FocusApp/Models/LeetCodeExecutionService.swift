#if os(iOS)
import FocusData
import Foundation

/// iOS code execution service that uses LeetCode's `interpret_solution` API
/// (the "Run Code" endpoint) to execute code remotely.
///
/// Conforms to `CodeExecuting` so it can replace `NoOpCodeExecutionService`
/// on iOS while keeping the same interface macOS uses.
///
/// Network behaviour:
/// - Each HTTP request uses a **20-second timeout**.
/// - The `submitInterpret` call retries up to **3 times** on transient network errors.
/// - Polling retries are built into the poll loop (up to 40 iterations).
final class LeetCodeExecutionService: CodeExecuting {
    private let executor: RequestExecuting
    private let logger: DebugLogRecording?
    private let decoder: JSONDecoder
    private var currentTask: Task<Void, Never>?

    /// Maximum number of retry attempts for a network request.
    private let maxRetries = 3

    /// Timeout (in seconds) applied to every outgoing URLRequest.
    private let requestTimeout: TimeInterval = 20

    init(
        executor: RequestExecuting,
        logger: DebugLogRecording? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.executor = executor
        self.logger = logger
        self.decoder = decoder
    }

    // MARK: - Context

    /// Set by the interactor before calling execute, providing the problem context.
    var problemSlug: String?
    var questionId: String?
    var authSession: LeetCodeAuthSession?

    // MARK: - CodeExecuting

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        guard let slug = problemSlug, !slug.isEmpty else {
            return .failure("No problem selected. Please select a problem before running code.")
        }
        guard let auth = authSession else {
            return .failure("LeetCode login required. Go to Settings to log in.")
        }

        logger?.recordAsync(
            DebugLogEntry(
                level: .info,
                category: .execution,
                    title: "iOS Execution started",
                    message: "LeetCode interpret_solution for \(slug)",
                    metadata: [
                        "language": language.langSlug,
                        "input_bytes": "\(input.utf8.count)",
                        "code_bytes": "\(code.utf8.count)"
                    ]
                )
            )

        do {
            let interpretId = try await submitInterpret(
                code: code,
                language: language,
                slug: slug,
                questionId: questionId,
                input: input,
                auth: auth
            )

            let result = try await pollResult(
                interpretId: interpretId,
                slug: slug,
                auth: auth
            )

            logger?.recordAsync(
                DebugLogEntry(
                    level: result.exitCode == 0 ? .info : .error,
                    category: .execution,
                    title: "iOS Execution finished",
                    message: "\(language.rawValue) via LeetCode API",
                    metadata: [
                        "exit_code": "\(result.exitCode)",
                        "timed_out": "\(result.timedOut)"
                    ]
                )
            )

            return result
        } catch is CancellationError {
            return ExecutionResult(
                output: "",
                error: "Execution cancelled.",
                exitCode: -1,
                timedOut: false,
                wasCancelled: true
            )
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            logger?.recordAsync(
                DebugLogEntry(
                    level: .error,
                    category: .execution,
                    title: "iOS Execution failed",
                    message: message
                )
            )
            return .failure(message)
        }
    }

    func cancelExecution() {
        currentTask?.cancel()
        currentTask = nil
    }

    // MARK: - Network Helpers

    /// Execute a `URLRequest` with retry logic.
    /// Retries up to `maxRetries` times on transient network errors (timeout,
    /// connection lost, not connected). Non-transient errors are thrown immediately.
    private func executeWithRetry(_ request: URLRequest) async throws -> Data {
        var lastError: Error?
        for attempt in 1...maxRetries {
            if Task.isCancelled { throw CancellationError() }
            do {
                return try await executor.execute(request)
            } catch {
                lastError = error
                let nsError = error as NSError
                let isTransient = nsError.domain == NSURLErrorDomain && [
                    NSURLErrorTimedOut,
                    NSURLErrorNetworkConnectionLost,
                    NSURLErrorNotConnectedToInternet,
                    NSURLErrorCannotConnectToHost,
                    NSURLErrorCannotFindHost
                ].contains(nsError.code)

                if !isTransient || attempt == maxRetries {
                    throw error
                }

                logger?.recordAsync(
                    DebugLogEntry(
                        level: .warning,
                        category: .network,
                        title: "Network retry",
                        message: "Attempt \(attempt)/\(maxRetries) failed, retrying…",
                        metadata: ["error": nsError.localizedDescription]
                    )
                )

                // Exponential backoff: 1s, 2s
                let delay = UInt64(attempt) * 1_000_000_000
                try await Task.sleep(nanoseconds: delay)
            }
        }
        throw lastError ?? LeetCodeSubmissionError.timeout
    }

    /// Build and apply common LeetCode headers + the 20-second timeout.
    private func buildRequest(
        url: URL,
        method: String,
        slug: String,
        auth: LeetCodeAuthSession
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Origin")
        request.setValue(
            "https://leetcode.com/problems/\(slug)/",
            forHTTPHeaderField: "Referer"
        )
        request.setValue(auth.csrfToken, forHTTPHeaderField: "X-CSRFToken")

        let cookieHeader = [
            "LEETCODE_SESSION=\(auth.session)",
            "csrftoken=\(auth.csrfToken)"
        ].joined(separator: "; ")
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        return request
    }

    // MARK: - LeetCode interpret_solution API

    private func submitInterpret(
        code: String,
        language: ProgrammingLanguage,
        slug: String,
        questionId: String?,
        input: String,
        auth: LeetCodeAuthSession
    ) async throws -> String {
        let urlString = "https://leetcode.com/problems/\(slug)/interpret_solution/"
        guard let url = URL(string: urlString) else {
            throw LeetCodeSubmissionError.invalidURL
        }

        var body: [String: String] = [
            "lang": language.langSlug,
            "typed_code": code,
            "data_input": input
        ]
        if let questionId, !questionId.isEmpty {
            body["question_id"] = questionId
        }

        var request = buildRequest(url: url, method: "POST", slug: slug, auth: auth)
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data = try await executeWithRetry(request)

        let response = try decoder.decode(InterpretResponse.self, from: data)
        if let interpretId = response.interpretId, !interpretId.isEmpty {
            return interpretId
        }
        if let error = response.error, !error.isEmpty {
            throw LeetCodeSubmissionError.submissionFailed(error)
        }
        throw LeetCodeSubmissionError.invalidResponse
    }

    private func pollResult(
        interpretId: String,
        slug: String,
        auth: LeetCodeAuthSession
    ) async throws -> ExecutionResult {
        let checkURLString = "https://leetcode.com/submissions/detail/\(interpretId)/check/"
        guard let checkURL = URL(string: checkURLString) else {
            throw LeetCodeSubmissionError.invalidURL
        }

        var attempts = 0
        let maxAttempts = 40

        while attempts < maxAttempts {
            if Task.isCancelled { throw CancellationError() }

            let request = buildRequest(url: checkURL, method: "GET", slug: slug, auth: auth)

            let data: Data
            do {
                data = try await executeWithRetry(request)
            } catch {
                // Even after retries the poll request failed — count as an attempt
                attempts += 1
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continue
            }

            let check: InterpretCheck
            do {
                check = try decoder.decode(InterpretCheck.self, from: data)
            } catch {
                // Sometimes LeetCode returns partial JSON, retry
                attempts += 1
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continue
            }

            if check.isComplete {
                return mapToExecutionResult(check)
            }

            attempts += 1
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        return ExecutionResult(
            output: "",
            error: "LeetCode execution timed out after \(maxAttempts) seconds.",
            exitCode: -1,
            timedOut: true,
            wasCancelled: false
        )
    }

    private func mapToExecutionResult(_ check: InterpretCheck) -> ExecutionResult {
        // Compile error
        if let compileError = check.compileError, !compileError.isEmpty {
            return ExecutionResult(
                output: "",
                error: compileError,
                exitCode: 1,
                timedOut: false,
                wasCancelled: false
            )
        }

        // Runtime error
        if let runtimeError = check.runtimeError, !runtimeError.isEmpty {
            var output = ""
            if let stdout = check.stdout, !stdout.isEmpty {
                output = stdout
            }
            if let codeOutput = check.codeOutput {
                if !output.isEmpty { output += "\n" }
                output += codeOutput
            }
            return ExecutionResult(
                output: output,
                error: runtimeError,
                exitCode: 1,
                timedOut: false,
                wasCancelled: false
            )
        }

        // Success
        var outputParts: [String] = []
        if let stdout = check.stdout, !stdout.isEmpty {
            outputParts.append(stdout)
        }
        if let codeOutput = check.codeOutput, !codeOutput.isEmpty {
            outputParts.append(codeOutput)
        }
        let output = outputParts.joined(separator: "\n")

        // Check if tests passed
        let success = check.runSuccess == true || check.statusCode == 10
        let stderr = check.statusMsg ?? ""

        return ExecutionResult(
            output: output,
            error: success ? "" : stderr,
            exitCode: success ? 0 : 1,
            timedOut: false,
            wasCancelled: false
        )
    }
}

// MARK: - Response Models

private struct InterpretResponse: Decodable {
    let interpretId: String?
    let testCase: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case interpretId = "interpret_id"
        case testCase = "test_case"
        case error
    }
}

private struct InterpretCheck: Decodable {
    let state: String?
    let finished: Bool?
    let statusCode: Int?
    let statusMsg: String?
    let runSuccess: Bool?
    let compileError: String?
    let runtimeError: String?
    let codeOutput: String?
    let stdout: String?
    let expectedOutput: String?
    let totalCorrect: Int?
    let totalTestcases: Int?
    let codeAnswer: [String]?
    let expectedCodeAnswer: [String]?

    enum CodingKeys: String, CodingKey {
        case state
        case finished
        case statusCode = "status_code"
        case statusMsg = "status_msg"
        case runSuccess = "run_success"
        case compileError = "compile_error"
        case runtimeError = "runtime_error"
        case codeOutput = "code_output"
        case stdout
        case expectedOutput = "expected_output"
        case totalCorrect = "total_correct"
        case totalTestcases = "total_testcases"
        case codeAnswer = "code_answer"
        case expectedCodeAnswer = "expected_code_answer"
    }

    var isComplete: Bool {
        if finished == true { return true }
        if let state, state.uppercased() == "SUCCESS" { return true }
        return false
    }
}

#endif
