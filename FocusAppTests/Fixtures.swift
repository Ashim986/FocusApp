@testable import FocusApp
import Foundation
import UserNotifications
import XCTest

final class InMemoryAppStorage: AppStorage {
    private var stored: AppData

    init(initial: AppData = AppData()) {
        self.stored = initial
    }

    func load() -> AppData {
        stored
    }

    func save(_ data: AppData) {
        stored = data
    }
}

struct FixedDateProvider: DateProviding {
    let date: Date

    func now() -> Date {
        date
    }
}

final class SpyNotificationScheduler: NotificationScheduling {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [[String]] = []
    var requestedOptions: [UNAuthorizationOptions] = []
    var authorizationResult: Bool = true
    var authorizationError: Error?
    var addError: Error?

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestedOptions.append(options)
        if let authorizationError {
            throw authorizationError
        }
        return authorizationResult
    }

    func notificationSettings() async -> UNNotificationSettings {
        await UNUserNotificationCenter.current().notificationSettings()
    }

    func add(_ request: UNNotificationRequest) async throws {
        if let addError {
            throw addError
        }
        addedRequests.append(request)
    }

    func removePendingRequests(identifiers: [String]) {
        removedIdentifiers.append(identifiers)
    }
}

final class InMemoryNotificationSettingsStore: NotificationSettingsStoring {
    private var stored: NotificationSettings

    init(settings: NotificationSettings) {
        self.stored = settings
    }

    func loadSettings() -> NotificationSettings {
        stored
    }

    func saveSettings(_ settings: NotificationSettings) {
        stored = settings
    }
}

struct TestError: Error, Equatable {}

final class FakeLeetCodeClient: LeetCodeClientProtocol {
    var validateResult: Result<Bool, Error> = .success(true)
    var solvedSlugsResult: Result<Set<String>, Error> = .success([])
    var contentBySlug: [String: QuestionContent] = [:]

    func validateUsername(_ username: String) async throws -> Bool {
        try validateResult.get()
    }

    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> {
        try solvedSlugsResult.get()
    }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        contentBySlug[slug]
    }
}

final class FakeCodeExecutor: CodeExecuting {
    var lastRequest: (code: String, language: ProgrammingLanguage, input: String)?
    var result: ExecutionResult = .failure("Not configured")

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        lastRequest = (code, language, input)
        return result
    }

    func cancelExecution() { }
}

final class FakeLanguageExecutor: LanguageExecutor {
    let language: ProgrammingLanguage
    let result: ExecutionResult

    init(language: ProgrammingLanguage, result: ExecutionResult) {
        self.language = language
        self.result = result
    }

    func execute(code: String, input: String) async -> ExecutionResult {
        result
    }
}

func makeDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    return Calendar(identifier: .gregorian).date(from: components) ?? Date()
}
