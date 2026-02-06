@testable import FocusApp
import XCTest

final class SolutionStoreTests: XCTestCase {
    // MARK: - InMemorySolutionStore Tests

    func testInMemorySolutionStoreEmpty() {
        let store = InMemorySolutionStore()

        XCTAssertEqual(store.solutionCount, 0)
        XCTAssertNil(store.solution(for: "two-sum"))
        XCTAssertTrue(store.allSolutions().isEmpty)
    }

    func testInMemorySolutionStoreWithInitialSolutions() {
        let solution = ProblemSolution(
            problemSlug: "two-sum",
            summary: "Find two numbers",
            approaches: []
        )
        let store = InMemorySolutionStore(solutions: [solution])

        XCTAssertEqual(store.solutionCount, 1)
        XCTAssertNotNil(store.solution(for: "two-sum"))
        XCTAssertNil(store.solution(for: "three-sum"))
    }

    func testInMemorySolutionStoreAddSolution() {
        let store = InMemorySolutionStore()

        let solution = ProblemSolution(
            problemSlug: "reverse-linked-list",
            summary: "Reverse pointers",
            approaches: []
        )
        store.addSolution(solution)

        XCTAssertEqual(store.solutionCount, 1)
        XCTAssertNotNil(store.solution(for: "reverse-linked-list"))
    }

    func testInMemorySolutionStoreUpdateSolution() {
        let store = InMemorySolutionStore()

        let original = ProblemSolution(
            problemSlug: "test",
            summary: "Original",
            approaches: []
        )
        store.addSolution(original)

        let updated = ProblemSolution(
            problemSlug: "test",
            summary: "Updated",
            approaches: []
        )
        store.addSolution(updated)

        XCTAssertEqual(store.solutionCount, 1)
        XCTAssertEqual(store.solution(for: "test")?.summary, "Updated")
    }

    func testInMemorySolutionStoreMultipleSolutions() {
        let store = InMemorySolutionStore()

        let solution1 = ProblemSolution(problemSlug: "a", summary: "A", approaches: [])
        let solution2 = ProblemSolution(problemSlug: "b", summary: "B", approaches: [])
        let solution3 = ProblemSolution(problemSlug: "c", summary: "C", approaches: [])

        store.addSolution(solution1)
        store.addSolution(solution2)
        store.addSolution(solution3)

        XCTAssertEqual(store.solutionCount, 3)
        XCTAssertEqual(store.allSolutions().count, 3)
    }

    // MARK: - SolutionProviding Protocol Tests

    func testSolutionProvidingProtocol() {
        let store: SolutionProviding = InMemorySolutionStore(solutions: [
            ProblemSolution(problemSlug: "test", summary: "Test", approaches: [])
        ])

        XCTAssertEqual(store.solutionCount, 1)
        XCTAssertNotNil(store.solution(for: "test"))
    }

    // MARK: - BundledSolutionStore Tests

    func testBundledSolutionStoreLoadsFromBundle() {
        // This test verifies that BundledSolutionStore can be instantiated
        // and can load bundled solutions.
        let store = BundledSolutionStore()

        XCTAssertGreaterThan(store.solutionCount, 0)
        XCTAssertNotNil(store.solution(for: "reverse-linked-list"))
    }

    // MARK: - TopicSolutionStore Tests

    func testTopicSolutionStoreLoadsFromBundle() {
        let store = TopicSolutionStore()

        XCTAssertGreaterThan(store.solutionCount, 0)
        XCTAssertNotNil(store.solution(for: "reverse-linked-list"))
        XCTAssertNotNil(store.solution(for: "two-sum"))
    }
}
