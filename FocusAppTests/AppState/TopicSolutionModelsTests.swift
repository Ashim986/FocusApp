import XCTest
@testable import FocusApp

final class TopicSolutionModelsTests: XCTestCase {
    // MARK: - SolutionIndexTopic Tests

    func testSolutionIndexTopicEncoding() throws {
        let topic = SolutionIndexTopic(
            id: "linked-list",
            name: "Linked List",
            file: "linked-list.json",
            problemCount: 14,
            difficulties: ["easy": 5, "medium": 9]
        )

        let data = try JSONEncoder().encode(topic)
        let decoded = try JSONDecoder().decode(SolutionIndexTopic.self, from: data)

        XCTAssertEqual(decoded.id, "linked-list")
        XCTAssertEqual(decoded.name, "Linked List")
        XCTAssertEqual(decoded.file, "linked-list.json")
        XCTAssertEqual(decoded.problemCount, 14)
        XCTAssertEqual(decoded.difficulties["easy"], 5)
        XCTAssertEqual(decoded.difficulties["medium"], 9)
    }

    func testSolutionIndexTopicEquatable() {
        let t1 = SolutionIndexTopic(
            id: "trees",
            name: "Trees",
            file: "trees.json",
            problemCount: 18,
            difficulties: ["easy": 6, "medium": 12]
        )
        let t2 = SolutionIndexTopic(
            id: "trees",
            name: "Trees",
            file: "trees.json",
            problemCount: 18,
            difficulties: ["easy": 6, "medium": 12]
        )
        let t3 = SolutionIndexTopic(
            id: "graphs",
            name: "Graphs",
            file: "graphs.json",
            problemCount: 19,
            difficulties: ["medium": 19]
        )

        XCTAssertEqual(t1, t2)
        XCTAssertNotEqual(t1, t3)
    }

    func testSolutionIndexTopicIdentifiable() {
        let topic = SolutionIndexTopic(
            id: "stack",
            name: "Stack",
            file: "stack.json",
            problemCount: 4,
            difficulties: [:]
        )

        XCTAssertEqual(topic.id, "stack")
    }

    // MARK: - SolutionIndexEntry Tests

    func testSolutionIndexEntryEncoding() throws {
        let entry = SolutionIndexEntry(
            topic: "arrays-hashing",
            number: 1,
            difficulty: "easy"
        )

        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(SolutionIndexEntry.self, from: data)

        XCTAssertEqual(decoded.topic, "arrays-hashing")
        XCTAssertEqual(decoded.number, 1)
        XCTAssertEqual(decoded.difficulty, "easy")
    }

    func testSolutionIndexEntryWithNilFields() throws {
        let entry = SolutionIndexEntry(topic: "misc", number: nil, difficulty: nil)

        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(SolutionIndexEntry.self, from: data)

        XCTAssertEqual(decoded.topic, "misc")
        XCTAssertNil(decoded.number)
        XCTAssertNil(decoded.difficulty)
    }

    func testSolutionIndexEntryEquatable() {
        let e1 = SolutionIndexEntry(topic: "trees", number: 226, difficulty: "easy")
        let e2 = SolutionIndexEntry(topic: "trees", number: 226, difficulty: "easy")
        let e3 = SolutionIndexEntry(topic: "graphs", number: 200, difficulty: "medium")

        XCTAssertEqual(e1, e2)
        XCTAssertNotEqual(e1, e3)
    }

    // MARK: - SolutionIndex Tests

    func testSolutionIndexEncoding() throws {
        let index = SolutionIndex(
            version: "2.0.0",
            lastUpdated: "2026-02-06",
            totalProblems: 2,
            topics: [
                SolutionIndexTopic(
                    id: "linked-list",
                    name: "Linked List",
                    file: "linked-list.json",
                    problemCount: 1,
                    difficulties: ["easy": 1]
                ),
            ],
            problemIndex: [
                "reverse-linked-list": SolutionIndexEntry(
                    topic: "linked-list",
                    number: 206,
                    difficulty: "easy"
                ),
                "two-sum": SolutionIndexEntry(
                    topic: "arrays-hashing",
                    number: 1,
                    difficulty: "easy"
                ),
            ]
        )

        let data = try JSONEncoder().encode(index)
        let decoded = try JSONDecoder().decode(SolutionIndex.self, from: data)

        XCTAssertEqual(decoded.version, "2.0.0")
        XCTAssertEqual(decoded.lastUpdated, "2026-02-06")
        XCTAssertEqual(decoded.totalProblems, 2)
        XCTAssertEqual(decoded.topics.count, 1)
        XCTAssertEqual(decoded.problemIndex.count, 2)
        XCTAssertEqual(decoded.problemIndex["two-sum"]?.topic, "arrays-hashing")
        XCTAssertEqual(decoded.problemIndex["reverse-linked-list"]?.number, 206)
    }

    // MARK: - TopicSolutionsBundle Tests

    func testTopicSolutionsBundleEncoding() throws {
        let bundle = TopicSolutionsBundle(
            topic: "linked-list",
            version: "2.0.0",
            solutions: [
                ProblemSolution(
                    problemSlug: "reverse-linked-list",
                    summary: "Reverse pointers",
                    approaches: []
                ),
            ]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(bundle)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TopicSolutionsBundle.self, from: data)

        XCTAssertEqual(decoded.topic, "linked-list")
        XCTAssertEqual(decoded.version, "2.0.0")
        XCTAssertEqual(decoded.solutions.count, 1)
        XCTAssertEqual(decoded.solutions[0].problemSlug, "reverse-linked-list")
    }
}
