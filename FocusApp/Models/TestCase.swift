import Foundation

struct TestCase: Identifiable {
    let id = UUID()
    let input: String
    let expectedOutput: String
    var actualOutput: String?
    var passed: Bool?

    init(input: String, expectedOutput: String) {
        self.input = input
        self.expectedOutput = expectedOutput
    }
}

enum ProgrammingLanguage: String, CaseIterable {
    case swift = "Swift"
    case python = "Python"

    var fileExtension: String {
        switch self {
        case .swift: return "swift"
        case .python: return "py"
        }
    }

    var langSlug: String {
        switch self {
        case .swift: return "swift"
        case .python: return "python3"
        }
    }

    var snippetSlugs: [String] {
        switch self {
        case .swift:
            return ["swift"]
        case .python:
            return ["python3", "python"]
        }
    }

    var defaultTemplate: String {
        switch self {
        case .swift:
            return """
            // Solution
            func solution() {
                // Your code here
            }

            // Read input and call solution
            solution()
            """
        case .python:
            return """
            # Solution
            def solution():
                # Your code here
                pass

            # Read input and call solution
            solution()
            """
        }
    }
}

struct ExecutionResult {
    let output: String
    let error: String
    let exitCode: Int32
    let timedOut: Bool
    let wasCancelled: Bool

    var isSuccess: Bool {
        exitCode == 0 && !timedOut && !wasCancelled && error.isEmpty
    }

    static func failure(_ message: String) -> Self {
        Self(output: "", error: message, exitCode: -1, timedOut: false, wasCancelled: false)
    }

    static func timeout() -> Self {
        Self(output: "", error: "Execution timed out", exitCode: -1, timedOut: true, wasCancelled: false)
    }

    static func cancelled() -> Self {
        Self(output: "", error: "Execution stopped by user", exitCode: -1, timedOut: false, wasCancelled: true)
    }
}
