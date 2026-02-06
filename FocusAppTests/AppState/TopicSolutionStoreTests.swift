import XCTest
@testable import FocusApp

final class TopicSolutionStoreTests: XCTestCase {
    // MARK: - Bundle Integration Tests

    func testTopicSolutionStoreLoadsFromBundle() {
        let store = TopicSolutionStore()

        XCTAssertGreaterThan(store.solutionCount, 0)
    }

    func testSolutionForKnownSlugReturnsResult() {
        let store = TopicSolutionStore()

        let solution = store.solution(for: "reverse-linked-list")
        XCTAssertNotNil(solution)
        XCTAssertEqual(solution?.problemSlug, "reverse-linked-list")
    }

    func testSolutionForUnknownSlugReturnsNil() {
        let store = TopicSolutionStore()

        XCTAssertNil(store.solution(for: "nonexistent-problem-slug"))
    }

    func testSolutionForTwoSumReturnsResult() {
        let store = TopicSolutionStore()

        let solution = store.solution(for: "two-sum")
        XCTAssertNotNil(solution)
        XCTAssertEqual(solution?.problemSlug, "two-sum")
        XCTAssertFalse(solution?.summary.isEmpty ?? true)
    }

    func testAllSolutionsReturnsAll() {
        let store = TopicSolutionStore()

        let all = store.allSolutions()
        XCTAssertEqual(all.count, store.solutionCount)
        XCTAssertGreaterThan(all.count, 100)
    }

    func testAvailableTopics() {
        let store = TopicSolutionStore()

        let topics = store.availableTopics
        XCTAssertGreaterThan(topics.count, 10)

        let topicIds = topics.map(\.id)
        XCTAssertTrue(topicIds.contains("linked-list"))
        XCTAssertTrue(topicIds.contains("trees"))
        XCTAssertTrue(topicIds.contains("dynamic-programming"))
        XCTAssertTrue(topicIds.contains("arrays-hashing"))
    }

    func testSolutionsForTopic() {
        let store = TopicSolutionStore()

        let linkedListSolutions = store.solutions(for: "linked-list")
        XCTAssertGreaterThan(linkedListSolutions.count, 0)

        for solution in linkedListSolutions {
            XCTAssertFalse(solution.problemSlug.isEmpty)
        }
    }

    func testSolutionsForUnknownTopicReturnsEmpty() {
        let store = TopicSolutionStore()

        let solutions = store.solutions(for: "nonexistent-topic")
        XCTAssertTrue(solutions.isEmpty)
    }

    func testHasSolutionForKnownSlug() {
        let store = TopicSolutionStore()

        XCTAssertTrue(store.hasSolution(for: "two-sum"))
        XCTAssertTrue(store.hasSolution(for: "reverse-linked-list"))
    }

    func testHasSolutionForUnknownSlug() {
        let store = TopicSolutionStore()

        XCTAssertFalse(store.hasSolution(for: "nonexistent-slug"))
    }

    func testVersionIsSet() {
        let store = TopicSolutionStore()

        XCTAssertEqual(store.version, "2.0.0")
    }

    // MARK: - SolutionProviding Protocol Conformance

    func testConformsToSolutionProviding() {
        let store: SolutionProviding = TopicSolutionStore()

        XCTAssertGreaterThan(store.solutionCount, 0)
        XCTAssertNotNil(store.solution(for: "two-sum"))
        XCTAssertFalse(store.allSolutions().isEmpty)
    }

    // MARK: - Topic Problem Count Consistency

    func testTopicProblemCountsMatchActualSolutions() {
        let store = TopicSolutionStore()

        for topic in store.availableTopics {
            let solutions = store.solutions(for: topic.id)
            XCTAssertEqual(
                solutions.count,
                topic.problemCount,
                "Topic '\(topic.name)' claims \(topic.problemCount) problems but has \(solutions.count)"
            )
        }
    }
}
