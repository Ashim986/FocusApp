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
    struct Request {
        let code: String
        let language: ProgrammingLanguage
        let input: String
    }

    var lastRequest: Request?
    var result: ExecutionResult = .failure("Not configured")

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        lastRequest = Request(code: code, language: language, input: input)
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

final class FakeSolutionStore: SolutionProviding, @unchecked Sendable {
    var solutionsBySlug: [String: ProblemSolution] = [:]

    func solution(for slug: String) -> ProblemSolution? {
        solutionsBySlug[slug]
    }

    func allSolutions() -> [ProblemSolution] {
        Array(solutionsBySlug.values)
    }

    var solutionCount: Int {
        solutionsBySlug.count
    }
}

func makeDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    return Calendar(identifier: .gregorian).date(from: components) ?? Date()
}

// MARK: - Fake Notification Manager

final class FakeNotificationManager: NotificationManaging {
    var storedSettings = NotificationSettings(
        studyReminderEnabled: false,
        studyReminderTime: Date(),
        habitReminderEnabled: false,
        habitReminderTime: Date()
    )
    var authorizationStatus: Bool = false
    var requestAuthorizationCalled = false
    var checkAuthorizationCalled = false
    var updateAllRemindersCalled = false
    var lastReminderSettings: NotificationSettings?
    var lastReminderAuthorized: Bool?
    var topicCompleteCelebrationCalled = false
    var lastCelebrationTopic: String?
    var allHabitsCelebrationCalled = false

    func loadSettings() -> NotificationSettings {
        storedSettings
    }

    func saveSettings(_ settings: NotificationSettings) {
        storedSettings = settings
    }

    func requestAuthorization() async -> Bool {
        requestAuthorizationCalled = true
        return authorizationStatus
    }

    func checkAuthorizationStatus() async -> Bool {
        checkAuthorizationCalled = true
        return authorizationStatus
    }

    func updateAllReminders(settings: NotificationSettings, authorized: Bool) async {
        updateAllRemindersCalled = true
        lastReminderSettings = settings
        lastReminderAuthorized = authorized
    }

    func sendTopicCompleteCelebration(topic: String, authorized: Bool) async {
        topicCompleteCelebrationCalled = true
        lastCelebrationTopic = topic
    }

    func sendAllHabitsCelebration(authorized: Bool) async {
        allHabitsCelebrationCalled = true
    }
}

// MARK: - Fake LeetCode Sync Interactor

final class FakeRequestExecutor: RequestExecuting {
    var result: Result<Data, Error> = .success(Data())
    var lastRequest: URLRequest?

    func execute(_ request: URLRequest) async throws -> Data {
        lastRequest = request
        return try result.get()
    }
}

final class FakeLeetCodeSyncInteractor {
    var validateUsernameResult: Bool = true
    var validateUsernameCalled = false
    var lastValidatedUsername: String?
    var syncResult = LeetCodeSyncResult(syncedCount: 0, totalMatched: 0)
    var syncCalled = false
    var lastSyncUsername: String?
    var lastSyncLimit: Int?

    func validateUsername(_ username: String) async -> Bool {
        validateUsernameCalled = true
        lastValidatedUsername = username
        return validateUsernameResult
    }

    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult {
        syncCalled = true
        lastSyncUsername = username
        lastSyncLimit = limit
        return syncResult
    }
}
