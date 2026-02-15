import Foundation
import SwiftUI

enum CodingViewState {
    case problemSelection
    case coding
}

@MainActor
final class CodingEnvironmentPresenter: ObservableObject {
    @Published var viewState: CodingViewState = .problemSelection
    @Published var selectedProblem: Problem?
    @Published var selectedProblemIndex: Int = 0
    @Published var selectedProblemDay: Int = 0
    @Published var code: String = "" {
        didSet {
            handleCodeChange(oldValue: oldValue)
        }
    }
    @Published var language: ProgrammingLanguage = .swift
    @Published var testCases: [TestCase] = []
    @Published var isRunning: Bool = false
    @Published var isLoadingProblem: Bool = false
    @Published var compilationOutput: String = ""
    @Published var errorOutput: String = ""
    @Published var problemContent: QuestionContent?
    @Published var problemDescriptionText: String = ""
    @Published var showSubmissionTagPrompt: Bool = false
    @Published var submissionTagInput: String = ""
    @Published var errorDiagnostics: [CodeEditorDiagnostic] = []
    @Published var currentSolution: ProblemSolution?
    @Published var showLeetCodeLogin: Bool = false
    @Published private(set) var dataJourney: [DataJourneyEvent] = []
    @Published var selectedJourneyEventID: UUID?
    @Published var highlightedExecutionLine: Int?
    @Published private(set) var isJourneyTruncated = false
    var traceEventsByTestCase: [Int: (events: [DataJourneyEvent], truncated: Bool)] = [:]
    @Published var codeResetNotice: String?
    @Published var executionLogAnchor: Date?
    @Published var hiddenTestCases: [SolutionTestCase] = []
    @Published var isGeneratingHiddenTests: Bool = false
    @Published var hiddenTestsHaveFailures: Bool = false
    var hiddenTestGenerationTask: Task<Void, Never>?

    let interactor: CodingEnvironmentInteractor
    let logger: DebugLogRecording?
    struct CachedContent {
        let content: QuestionContent
        let timestamp: Date
    }
    static let cacheTTL: TimeInterval = 24 * 60 * 60  // 24 hours
    var problemContentCache: [String: CachedContent] = [:]
    var problemDescriptionCache: [String: String] = [:]
    var codeSaveTask: Task<Void, Never>?
    var isApplyingExternalCode: Bool = false
    var runTask: Task<Void, Never>?
    var activeProblemSlug: String?
    var activeContentRequestID: UUID?
    struct PendingSubmission {
        let problem: Problem
        let code: String
        let language: ProgrammingLanguage
    }

    var pendingSubmission: PendingSubmission?

    var currentDayNumber: Int {
        interactor.currentDayNumber()
    }

    var todaysTopic: String {
        interactor.todaysTopic()
    }

    var selectedDayTopic: String {
        guard let day = dsaPlan.first(where: { $0.id == selectedProblemDay }) else {
            return todaysTopic
        }
        return day.topic
    }

    var problemSections: [CodingProblemSection] {
        let normalizedDay = max(1, min(currentDayNumber, dsaPlan.count))
        let canPreviewTomorrow = canAccessTomorrow(from: normalizedDay)
        let maxDay = min(normalizedDay + (canPreviewTomorrow ? 1 : 0), dsaPlan.count)

        return dsaPlan.filter { $0.id <= maxDay }.compactMap { day in
            let isToday = day.id == normalizedDay
            let totalCount = day.problems.count
            var completedCount = 0

            let problems = day.problems.enumerated().compactMap { index, problem -> CodingProblemItem? in
                let isCompleted = interactor.isProblemCompleted(day: day.id, problemIndex: index)
                if isCompleted {
                    completedCount += 1
                }
                if !isToday && isCompleted {
                    return nil
                }

                return CodingProblemItem(
                    id: problem.id,
                    dayId: day.id,
                    index: index,
                    problem: problem,
                    isCompleted: isCompleted,
                    isToday: isToday
                )
            }

            if isToday || !problems.isEmpty {
                return CodingProblemSection(
                    id: day.id,
                    dayId: day.id,
                    topic: day.topic,
                    isToday: isToday,
                    problems: problems,
                    completedCount: completedCount,
                    totalCount: totalCount
                )
            }

            return nil
        }
    }

    private func canAccessTomorrow(from currentDay: Int) -> Bool {
        guard currentDay < dsaPlan.count else { return false }
        guard let dayData = dsaPlan.first(where: { $0.id == currentDay }) else { return false }
        return dayData.problems.indices.allSatisfy { index in
            interactor.isProblemCompleted(day: currentDay, problemIndex: index)
        }
    }

    func cachedContentNeedsRefresh(_ content: QuestionContent) -> Bool {
        if content.metaData == nil || content.codeSnippets.isEmpty {
            return true
        }
        #if os(iOS)
        if content.questionId?.isEmpty ?? true {
            return true
        }
        #endif
        return false
    }

    init(
        interactor: CodingEnvironmentInteractor,
        logger: DebugLogRecording? = nil
    ) {
        self.interactor = interactor
        self.logger = logger
        self.code = ""
    }

    func isProblemCompleted(day: Int, index: Int) -> Bool {
        interactor.isProblemCompleted(day: day, problemIndex: index)
    }

    func selectProblem(_ problem: Problem, at index: Int, day: Int) {
        let newSlug = LeetCodeSlugExtractor.extractSlug(from: problem.url)
        if selectedProblem?.id == problem.id,
           selectedProblemIndex == index,
           selectedProblemDay == day {
            viewState = .coding
            if let slug = newSlug, let description = problemDescriptionCache[slug] {
                problemDescriptionText = description
            }
            return
        }

        persistCurrentCode()
        runTask?.cancel()
        runTask = nil
        isRunning = false
        clearJourney()

        activeProblemSlug = newSlug
        let requestID = UUID()
        activeContentRequestID = requestID

        selectedProblem = problem
        selectedProblemIndex = index
        selectedProblemDay = day
        setCode(initialCode(for: problem, language: language))
        testCases = []
        compilationOutput = ""
        errorOutput = ""
        if let slug = newSlug,
           let cached = problemContentCache[slug],
           Date().timeIntervalSince(cached.timestamp) < Self.cacheTTL {
            problemContent = cached.content
            parseTestCases(from: cached.content)
            applySnippetIfNeeded(from: cached.content)
            if let cachedDescription = problemDescriptionCache[slug] {
                problemDescriptionText = cachedDescription
            } else {
                problemDescriptionText = ""
            }
        } else {
            problemContent = nil
            problemDescriptionText = ""
        }
        currentSolution = nil
        hiddenTestCases = []
        hiddenTestGenerationTask?.cancel()
        isLoadingProblem = false
        viewState = .coding

        // Fetch problem content and solution
        let shouldFetch = newSlug.flatMap { slug in
            guard let cached = problemContentCache[slug] else { return true }
            if Date().timeIntervalSince(cached.timestamp) >= Self.cacheTTL {
                return true
            }
            return cachedContentNeedsRefresh(cached.content)
        } ?? true
        if shouldFetch {
            Task {
                await loadProblemContent(for: problem, requestID: requestID)
            }
        }
        loadSolution(for: problem)
        #if os(macOS)
        startHiddenTestGeneration()
        #endif
    }

    func loadSolution(for problem: Problem) {
        currentSolution = interactor.solution(for: problem)
        applySolutionTestCaseFallback()
    }

    func updateLeetCodeAuth(_ auth: LeetCodeAuthSession) {
        interactor.updateLeetCodeAuth(auth)
    }

    func clearJourney() {
        dataJourney = []
        selectedJourneyEventID = nil
        highlightedExecutionLine = nil
        isJourneyTruncated = false
        traceEventsByTestCase = [:]
    }

    func updateJourney(_ events: [DataJourneyEvent], truncated: Bool = false) {
        dataJourney = events
        isJourneyTruncated = truncated
        if let step = events.first(where: { $0.kind == .step }) {
            selectJourneyEvent(step)
        } else if let input = events.first(where: { $0.kind == .input }) {
            selectJourneyEvent(input)
        } else if let output = events.first(where: { $0.kind == .output }) {
            selectJourneyEvent(output)
        } else {
            selectedJourneyEventID = nil
            highlightedExecutionLine = nil
        }
    }

    func showJourneyForTestCase(_ index: Int) {
        if let stored = traceEventsByTestCase[index] {
            updateJourney(stored.events, truncated: stored.truncated)
        } else {
            dataJourney = []
            selectedJourneyEventID = nil
            highlightedExecutionLine = nil
            isJourneyTruncated = false
        }
    }

    func selectJourneyEvent(_ event: DataJourneyEvent) {
        selectedJourneyEventID = event.id
        highlightedExecutionLine = event.line
    }

    func ensureProblemSelection() {
        guard selectedProblem == nil else { return }
        if let todayItem = problemSections.first(where: { $0.isToday })?.problems.first {
            selectProblem(todayItem)
            return
        }
        if let firstItem = problemSections.first?.problems.first {
            selectProblem(firstItem)
        }
    }

    func backToProblemSelection() {
        persistCurrentCode()
        viewState = .problemSelection
        selectedProblem = nil
        selectedProblemDay = 0
        testCases = []
        compilationOutput = ""
        errorOutput = ""
        problemContent = nil
    }

    func changeLanguage(_ newLanguage: ProgrammingLanguage) {
        persistCurrentCode()
        language = newLanguage
        guard let problem = selectedProblem else {
            setCode("")
            return
        }
        setCode(initialCode(for: problem, language: newLanguage))
    }

    func announceCodeReset(_ message: String) {
        codeResetNotice = message
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                if self?.codeResetNotice == message {
                    self?.codeResetNotice = nil
                }
            }
        }
    }

    func addManualTestCase() {
        testCases.append(TestCase(input: "", expectedOutput: ""))
    }

    func updateTestCaseInput(at index: Int, input: String) {
        guard testCases.indices.contains(index) else { return }
        testCases[index] = TestCase(input: input, expectedOutput: testCases[index].expectedOutput)
    }

    func updateTestCaseExpectedOutput(at index: Int, output: String) {
        guard testCases.indices.contains(index) else { return }
        testCases[index] = TestCase(input: testCases[index].input, expectedOutput: output)
    }

    func removeTestCase(at index: Int) {
        guard testCases.indices.contains(index) else { return }
        testCases.remove(at: index)
    }
}
