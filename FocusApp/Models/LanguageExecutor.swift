import Foundation

/// Protocol for language-specific code executors
protocol LanguageExecutor {
    var language: ProgrammingLanguage { get }
    func execute(code: String, input: String) async -> ExecutionResult
}

/// Configuration for code execution
struct ExecutionConfig {
    let timeout: TimeInterval
    let tempDirectory: URL

    static var `default`: Self {
        Self(
            timeout: 10,
            tempDirectory: FileManager.default.temporaryDirectory
        )
    }
}
