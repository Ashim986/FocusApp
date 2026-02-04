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
    @Published var showSubmissionTagPrompt: Bool = false
    @Published var submissionTagInput: String = ""
    @Published var errorDiagnostics: [CodeEditorDiagnostic] = []
    @Published var currentSolution: ProblemSolution?

    let interactor: CodingEnvironmentInteractor
    var problemContentCache: [String: QuestionContent] = [:]
    var codeSaveTask: Task<Void, Never>?
    var isApplyingExternalCode: Bool = false
    var runTask: Task<Void, Never>?
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

        return dsaPlan.filter { $0.id <= normalizedDay }.compactMap { day in
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

    init(interactor: CodingEnvironmentInteractor) {
        self.interactor = interactor
        self.code = ""
    }

    func isProblemCompleted(day: Int, index: Int) -> Bool {
        interactor.isProblemCompleted(day: day, problemIndex: index)
    }

    func selectProblem(_ problem: Problem, at index: Int, day: Int) {
        persistCurrentCode()

        selectedProblem = problem
        selectedProblemIndex = index
        selectedProblemDay = day
        setCode(initialCode(for: problem, language: language))
        testCases = []
        compilationOutput = ""
        errorOutput = ""
        problemContent = nil
        viewState = .coding

        // Fetch problem content and solution
        Task {
            await loadProblemContent(for: problem)
        }
        loadSolution(for: problem)
    }

    func loadSolution(for problem: Problem) {
        currentSolution = interactor.solution(for: problem)
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
