@testable import FocusApp
import XCTest

@MainActor
struct CodingEnvironmentApp {
    let presenter: CodingEnvironmentPresenter

    func problemSelection() -> ProblemSelectionPage {
        ProblemSelectionPage(presenter: presenter)
    }
}

@MainActor
struct ProblemSelectionPage {
    let presenter: CodingEnvironmentPresenter

    func openFromToday(slug: String, file: StaticString = #file, line: UInt = #line) -> CodeEditorPage {
        return openProblem(slug: slug, file: file, line: line)
    }

    func openFromPlan(slug: String, file: StaticString = #file, line: UInt = #line) -> CodeEditorPage {
        return openProblem(slug: slug, file: file, line: line)
    }

    func openFromSelection(slug: String, file: StaticString = #file, line: UInt = #line) -> CodeEditorPage {
        return openProblem(slug: slug, file: file, line: line)
    }

    private func openProblem(slug: String, file: StaticString, line: UInt) -> CodeEditorPage {
        let location = problemLocation(for: slug, file: file, line: line)
        presenter.selectProblem(location.problem, at: location.index, day: location.dayId)
        return CodeEditorPage(presenter: presenter)
    }
}

@MainActor
struct CodeEditorPage {
    let presenter: CodingEnvironmentPresenter

    func selectProblem(slug: String, file: StaticString = #file, line: UInt = #line) -> CodeEditorPage {
        let location = problemLocation(for: slug, file: file, line: line)
        presenter.selectProblem(location.problem, at: location.index, day: location.dayId)
        return self
    }

    func backToSelection() {
        presenter.backToProblemSelection()
    }

    func waitForContent(slug: String, timeout: TimeInterval = 1.0) async -> QuestionContent? {
        let success = await waitForCondition(timeout: timeout) {
            guard let selected = presenter.selectedProblem,
                  LeetCodeSlugExtractor.extractSlug(from: selected.url) == slug else {
                return false
            }
            return presenter.problemContent != nil
        }
        return success ? presenter.problemContent : nil
    }

    func assertSelectedProblem(slug: String, file: StaticString = #file, line: UInt = #line) {
        guard let selected = presenter.selectedProblem else {
            XCTFail("Expected selected problem for slug \(slug)", file: file, line: line)
            return
        }
        XCTAssertEqual(LeetCodeSlugExtractor.extractSlug(from: selected.url), slug, file: file, line: line)
    }

    func assertCodeContains(_ snippet: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(presenter.code.contains(snippet), file: file, line: line)
    }
}

@MainActor
private func waitForCondition(
    timeout: TimeInterval = 1.0,
    interval: TimeInterval = 0.02,
    condition: @escaping () -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
    }
    return condition()
}
