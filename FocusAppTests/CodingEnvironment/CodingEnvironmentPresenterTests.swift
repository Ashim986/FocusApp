@testable import FocusApp
import XCTest

final class CodingEnvironmentPresenterTests: XCTestCase {
    @MainActor
    func testSelectProblemLoadsSnippetWhenNoUserCode() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let snippet = "class Solution { }"
        client.contentBySlug["reverse-linked-list"] = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": snippet, "python3": "def solve():\n    pass"],
            metaData: nil
        )
        let executor = FakeCodeExecutor()
        let solutionStore = FakeSolutionStore()
        let interactor = CodingEnvironmentInteractor(appStore: store, leetCodeClient: client, executionService: executor, solutionStore: solutionStore)
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        let location = problemLocation(for: "reverse-linked-list")
        presenter.selectProblem(location.problem, at: location.index, day: location.dayId)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.code, snippet)
    }

    @MainActor
    func testSelectProblemKeepsSavedCode() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.contentBySlug["reverse-linked-list"] = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution { }"],
            metaData: nil
        )
        let executor = FakeCodeExecutor()
        let solutionStore = FakeSolutionStore()
        let interactor = CodingEnvironmentInteractor(appStore: store, leetCodeClient: client, executionService: executor, solutionStore: solutionStore)
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        let location = problemLocation(for: "reverse-linked-list")
        let problem = location.problem
        let key = presenter.solutionKey(for: problem, language: ProgrammingLanguage.swift)
        store.saveSolution(code: "print(\"hi\")", for: key)

        presenter.selectProblem(problem, at: location.index, day: location.dayId)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.code, "print(\"hi\")")
    }
}

final class CodingEnvironmentExecutionTests: XCTestCase {
    @MainActor
    func testRunCodeWrapsAndUsesExecutionResult() async {
        let harness = makeHarness()
        let presenter = harness.presenter
        let executor = harness.executor
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem

        let meta = functionMetaJSON(
            name: "twoSum",
            params: [("nums", "integer[]"), ("target", "integer")],
            returnType: "integer[]"
        )
        presenter.problemContent = QuestionContent(
            title: "Two Sum",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: meta
        )
        presenter.setCode("class Solution { func twoSum(_ nums: [Int], _ target: Int) -> [Int] { return [] } }")
        executor.results = [ExecutionResult(output: "OK", error: "", exitCode: 0, timedOut: false, wasCancelled: false)]

        presenter.runCode()

        let finished = await waitFor { !presenter.isRunning }
        XCTAssertTrue(finished)
        XCTAssertEqual(presenter.compilationOutput, "OK")
        XCTAssertTrue(executor.requests.first?.code.contains("FocusApp LeetCode Runner") == true)
    }

    @MainActor
    func testRunTestsAllPassedShowsSubmissionPrompt() async {
        let harness = makeHarness()
        let presenter = harness.presenter
        let executor = harness.executor
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem

        let meta = functionMetaJSON(
            name: "sum",
            params: [("value", "integer")],
            returnType: "integer"
        )
        presenter.problemContent = QuestionContent(
            title: "Sum",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: meta
        )
        presenter.setCode("class Solution { func sum(_ value: Int) -> Int { return value } }")
        presenter.testCases = [
            TestCase(input: "1", expectedOutput: "1"),
            TestCase(input: "2", expectedOutput: "2")
        ]
        executor.results = [
            ExecutionResult(output: "1", error: "", exitCode: 0, timedOut: false, wasCancelled: false),
            ExecutionResult(output: "2", error: "", exitCode: 0, timedOut: false, wasCancelled: false)
        ]

        presenter.runTests()

        let finished = await waitFor { !presenter.isRunning }
        XCTAssertTrue(finished)
        XCTAssertTrue(presenter.showSubmissionTagPrompt)
        XCTAssertEqual(presenter.testCases.filter { $0.passed == true }.count, 2)
    }

    @MainActor
    func testConfirmSubmissionTagSavesSubmission() {
        let harness = makeHarness()
        let presenter = harness.presenter
        let store = harness.store
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem
        presenter.pendingSubmission = CodingEnvironmentPresenter.PendingSubmission(
            problem: problem,
            code: "class Solution {}",
            language: .swift
        )
        presenter.submissionTagInput = "Two pointers"
        presenter.showSubmissionTagPrompt = true

        presenter.confirmSubmissionTag(saveWithTag: true)

        let submissions = store.submissions(for: presenter.submissionKey(for: problem))
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(submissions.first?.algorithmTag, "Two pointers")
        XCTAssertFalse(presenter.showSubmissionTagPrompt)
        XCTAssertNil(presenter.pendingSubmission)
        XCTAssertEqual(presenter.submissionTagInput, "")
    }

    @MainActor
    func testStopExecutionCancelsAndSetsError() {
        let harness = makeHarness()
        let presenter = harness.presenter
        let executor = harness.executor
        presenter.isRunning = true
        presenter.runTask = Task { try? await Task.sleep(nanoseconds: 1_000_000_000) }

        presenter.stopExecution()

        XCTAssertTrue(executor.cancelCalled)
        XCTAssertFalse(presenter.isRunning)
        XCTAssertNil(presenter.runTask)
        XCTAssertEqual(presenter.errorOutput, "Execution stopped by user.")
    }

    @MainActor
    func testRunCodePopulatesSwiftDiagnostics() async {
        let harness = makeHarness()
        let presenter = harness.presenter
        let executor = harness.executor
        presenter.setCode("class Solution {\n}\n")
        executor.results = [
            ExecutionResult(
                output: "",
                error: "Solution.swift:10:7: error: cannot find 'x' in scope",
                exitCode: 1,
                timedOut: false,
                wasCancelled: false
            )
        ]

        presenter.runCode()

        let finished = await waitFor { !presenter.isRunning }
        XCTAssertTrue(finished)
        XCTAssertEqual(presenter.errorDiagnostics.first?.line, 3)
        XCTAssertEqual(presenter.errorDiagnostics.first?.column, 7)
    }

    @MainActor
    func testRunCodeUsesFallbackDiagnosticsWhenNoSwiftLineInfo() async {
        let harness = makeHarness()
        let presenter = harness.presenter
        let executor = harness.executor
        presenter.setCode("line1\nline2\nline3\n")
        executor.results = [
            ExecutionResult(
                output: "",
                error: "error: something bad\n 3 | return x",
                exitCode: 1,
                timedOut: false,
                wasCancelled: false
            )
        ]

        presenter.runCode()

        let finished = await waitFor { !presenter.isRunning }
        XCTAssertTrue(finished)
        XCTAssertEqual(presenter.errorDiagnostics.first?.line, 3)
    }

    @MainActor
    func testRunCodeParsesPythonDiagnostics() async {
        let harness = makeHarness()
        let presenter = harness.presenter
        let executor = harness.executor
        presenter.language = .python
        presenter.setCode("print('hi')\nprint(x)\n")
        executor.results = [
            ExecutionResult(
                output: "",
                error: """
                Traceback (most recent call last):
                  File "Solution.py", line 2, in <module>
                    print(x)
                          ^
                NameError: name 'x' is not defined
                """,
                exitCode: 1,
                timedOut: false,
                wasCancelled: false
            )
        ]

        presenter.runCode()

        let finished = await waitFor { !presenter.isRunning }
        XCTAssertTrue(finished)
        XCTAssertEqual(presenter.errorDiagnostics.first?.line, 2)
        XCTAssertEqual(presenter.errorDiagnostics.first?.message, "NameError: name 'x' is not defined")
    }

    @MainActor
    func testNormalizeOutputForComparisonHandlesTrailingLines() {
        let harness = makeHarness()
        let presenter = harness.presenter

        let normalized = presenter.normalizeOutputForComparison("Answer\n5", expected: "5")

        XCTAssertEqual(normalized, "5")
    }
}

final class CodingEnvironmentProblemLoadingTests: XCTestCase {
    @MainActor
    func testLoadProblemContentUsesCache() async {
        let logger = DebugLogStore()
        let harness = makeHarness(logger: logger)
        let presenter = harness.presenter
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem

        let cached = QuestionContent(
            title: "Reverse Linked List",
            content: "<strong>Output:</strong> [5,4,3,2,1]",
            exampleTestcases: "[1,2,3,4,5]",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution {}"],
            metaData: functionMetaJSON(
                name: "reverseList",
                params: [("head", "ListNode")],
                returnType: "ListNode"
            )
        )
        presenter.problemContentCache["reverse-linked-list"] = cached
        presenter.setCode("")

        await presenter.loadProblemContent(for: problem)

        XCTAssertEqual(presenter.problemContent?.title, "Reverse Linked List")
        XCTAssertFalse(presenter.testCases.isEmpty)
        XCTAssertEqual(presenter.code, "class Solution {}")
    }

    @MainActor
    func testLoadProblemContentFetchesAndCaches() async {
        let logger = DebugLogStore()
        let client = FakeLeetCodeClient()
        let harness = makeHarness(client: client, logger: logger)
        let presenter = harness.presenter
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem

        let content = QuestionContent(
            title: "Reverse Linked List",
            content: "<strong>Output:</strong> [5,4,3,2,1]",
            exampleTestcases: "[1,2,3,4,5]",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: nil
        )
        client.contentBySlug["reverse-linked-list"] = content

        await presenter.loadProblemContent(for: problem)

        XCTAssertEqual(presenter.problemContent?.title, "Reverse Linked List")
        XCTAssertEqual(presenter.problemContentCache["reverse-linked-list"]?.title, "Reverse Linked List")
        XCTAssertFalse(presenter.isLoadingProblem)
    }

    @MainActor
    func testLoadProblemContentLogsWhenSlugMissing() async {
        let logger = DebugLogStore()
        let harness = makeHarness(logger: logger)
        let presenter = harness.presenter
        let problem = Problem(name: "Invalid", difficulty: .easy, url: "not-a-url")

        await presenter.loadProblemContent(for: problem)

        let logged = await waitFor { !logger.entries.isEmpty }
        XCTAssertTrue(logged)
        XCTAssertEqual(logger.entries.first?.category, .app)
        XCTAssertEqual(logger.entries.first?.level, .warning)
    }

    @MainActor
    func testLoadProblemContentLogsWhenContentMissing() async {
        let logger = DebugLogStore()
        let harness = makeHarness(logger: logger)
        let presenter = harness.presenter
        let problem = problemWithSlug("reverse-linked-list")

        await presenter.loadProblemContent(for: problem)

        let logged = await waitFor { !logger.entries.isEmpty }
        XCTAssertTrue(logged)
        XCTAssertEqual(logger.entries.first?.category, .network)
        XCTAssertEqual(logger.entries.first?.level, .warning)
    }

    @MainActor
    func testLoadProblemContentLogsOnError() async {
        let logger = DebugLogStore()
        let client = ThrowingLeetCodeClient()
        let harness = makeHarness(client: client, logger: logger)
        let presenter = harness.presenter
        let problem = problemWithSlug("reverse-linked-list")

        await presenter.loadProblemContent(for: problem)

        let logged = await waitFor { !logger.entries.isEmpty }
        XCTAssertTrue(logged)
        XCTAssertEqual(logger.entries.first?.category, .network)
        XCTAssertEqual(logger.entries.first?.level, .error)
    }

    @MainActor
    func testParseTestCasesGroupsInputsUsingMetadata() {
        let harness = makeHarness()
        let presenter = harness.presenter

        let meta = functionMetaJSON(
            name: "twoSum",
            params: [("nums", "integer[]"), ("target", "integer")],
            returnType: "integer[]"
        )
        let content = QuestionContent(
            title: "Two Sum",
            content: "<strong>Output:</strong> [0,1]\n<strong>Output:</strong> [1,2]",
            exampleTestcases: "[2,7,11,15]\n9\n[3,2,4]\n6",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: meta
        )

        presenter.parseTestCases(from: content)

        XCTAssertEqual(presenter.testCases.count, 2)
        XCTAssertEqual(presenter.testCases[0].input, "[2,7,11,15]\n9")
        XCTAssertEqual(presenter.testCases[0].expectedOutput, "[0,1]")
        XCTAssertEqual(presenter.testCases[1].input, "[3,2,4]\n6")
        XCTAssertEqual(presenter.testCases[1].expectedOutput, "[1,2]")
    }

    @MainActor
    func testParseTestCasesUsesSampleWhenEmpty() {
        let harness = makeHarness()
        let presenter = harness.presenter
        let content = QuestionContent(
            title: "Sample",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "1\n2\n3",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: nil
        )

        presenter.parseTestCases(from: content)

        XCTAssertEqual(presenter.testCases.count, 1)
        XCTAssertEqual(presenter.testCases.first?.input, "1\n2\n3")
        XCTAssertEqual(presenter.testCases.first?.expectedOutput, "Expected output")
    }

    @MainActor
    func testParseOutputsFromHTMLExtractsValues() {
        let harness = makeHarness()
        let presenter = harness.presenter

        let outputs = presenter.parseOutputsFromHTML(
            "<p><strong>Output:</strong> 1</p><strong>Output:</strong> [2,3]"
        )

        XCTAssertEqual(outputs, ["1", "[2,3]"])
    }
}

final class CodingEnvironmentPresenterStateTests: XCTestCase {
    @MainActor
    func testEnsureProblemSelectionSelectsTodayProblem() {
        let harness = makeHarness()
        let presenter = harness.presenter

        presenter.ensureProblemSelection()

        XCTAssertNotNil(presenter.selectedProblem)
        XCTAssertEqual(presenter.viewState, .coding)
    }

    @MainActor
    func testChangeLanguageWithoutProblemClearsCode() {
        let harness = makeHarness()
        let presenter = harness.presenter
        presenter.setCode("print(\"hi\")")

        presenter.changeLanguage(.python)

        XCTAssertEqual(presenter.code, "")
        XCTAssertEqual(presenter.language, .python)
    }

    @MainActor
    func testChangeLanguageLoadsSnippetForProblem() {
        let harness = makeHarness()
        let presenter = harness.presenter
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem
        presenter.problemContentCache["reverse-linked-list"] = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["python3": "def solve():\n    pass"],
            metaData: nil
        )
        presenter.setCode("print(\"old\")")

        presenter.changeLanguage(.python)

        XCTAssertEqual(presenter.code, "def solve():\n    pass")
        XCTAssertEqual(presenter.language, .python)
    }

    @MainActor
    func testBackToProblemSelectionResetsState() {
        let harness = makeHarness()
        let presenter = harness.presenter
        presenter.selectedProblem = problemWithSlug("reverse-linked-list")
        presenter.testCases = [TestCase(input: "1", expectedOutput: "1")]
        presenter.compilationOutput = "output"
        presenter.errorOutput = "error"
        presenter.problemContent = QuestionContent(
            title: "Title",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: nil
        )

        presenter.backToProblemSelection()

        XCTAssertNil(presenter.selectedProblem)
        XCTAssertEqual(presenter.viewState, .problemSelection)
        XCTAssertTrue(presenter.testCases.isEmpty)
        XCTAssertEqual(presenter.compilationOutput, "")
        XCTAssertEqual(presenter.errorOutput, "")
        XCTAssertNil(presenter.problemContent)
    }

    @MainActor
    func testAddUpdateRemoveTestCase() {
        let harness = makeHarness()
        let presenter = harness.presenter

        presenter.addManualTestCase()
        XCTAssertEqual(presenter.testCases.count, 1)

        presenter.updateTestCaseInput(at: 0, input: "1")
        presenter.updateTestCaseExpectedOutput(at: 0, output: "2")
        XCTAssertEqual(presenter.testCases[0].input, "1")
        XCTAssertEqual(presenter.testCases[0].expectedOutput, "2")

        presenter.removeTestCase(at: 0)
        XCTAssertTrue(presenter.testCases.isEmpty)
    }

    @MainActor
    func testScheduleCodeSavePersistsAfterDelay() async {
        let harness = makeHarness()
        let presenter = harness.presenter
        let store = harness.store
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem

        presenter.code = "print(\"saved\")"

        let saved = await waitFor({
            store.solutionCode(for: presenter.solutionKey(for: problem, language: presenter.language)) == "print(\"saved\")"
        }, timeout: 1.5)
        XCTAssertTrue(saved)
    }

    @MainActor
    func testSetCodeDoesNotClearDiagnostics() {
        let harness = makeHarness()
        let presenter = harness.presenter
        presenter.errorDiagnostics = [CodeEditorDiagnostic(line: 1, column: nil, message: "Error")]

        presenter.setCode("print(\"hi\")")

        XCTAssertFalse(presenter.errorDiagnostics.isEmpty)
    }

    @MainActor
    func testProblemSectionsExcludeCompletedFromPastDays() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        store.advanceToNextDay()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: FakeLeetCodeClient(),
            executionService: QueueCodeExecutor(),
            solutionStore: FakeSolutionStore()
        )
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        store.toggleProblem(day: 1, problemIndex: 0)
        let sections = presenter.problemSections

        let dayOne = sections.first { $0.dayId == 1 }
        XCTAssertNotNil(dayOne)
        XCTAssertFalse(dayOne?.problems.contains(where: { $0.index == 0 }) ?? true)
    }
}

// MARK: - Helpers

private final class QueueCodeExecutor: CodeExecuting {
    var requests: [(code: String, language: ProgrammingLanguage, input: String)] = []
    var results: [ExecutionResult] = []
    var cancelCalled = false

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        requests.append((code, language, input))
        if results.isEmpty {
            return ExecutionResult.failure("Not configured")
        }
        return results.removeFirst()
    }

    func cancelExecution() {
        cancelCalled = true
    }
}

private struct ThrowingLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }

    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        throw TestError()
    }
}

@MainActor
private func makeHarness(
    executor: QueueCodeExecutor = QueueCodeExecutor(),
    client: LeetCodeClientProtocol = FakeLeetCodeClient(),
    logger: DebugLogStore? = nil
) -> (presenter: CodingEnvironmentPresenter, store: AppStateStore, executor: QueueCodeExecutor) {
    let start = makeDate(year: 2026, month: 2, day: 3)
    let store = AppStateStore(
        storage: InMemoryAppStorage(),
        calendar: PlanCalendar(startDate: start),
        dateProvider: FixedDateProvider(date: start)
    )
    let interactor = CodingEnvironmentInteractor(
        appStore: store,
        leetCodeClient: client,
        executionService: executor,
        solutionStore: FakeSolutionStore()
    )
    let presenter = CodingEnvironmentPresenter(interactor: interactor, logger: logger)
    return (presenter, store, executor)
}

@MainActor
private func waitFor(_ condition: @escaping () -> Bool, timeout: TimeInterval = 1.0) async -> Bool {
    let start = Date()
    while Date().timeIntervalSince(start) < timeout {
        if condition() { return true }
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
    return condition()
}
