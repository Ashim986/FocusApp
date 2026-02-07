import FocusData
import FocusDomain
import XCTest

final class LeetCodeProgressSynchronizerTests: XCTestCase {
    private let synchronizer = LeetCodeProgressSynchronizer()

    func testExtractSlugParsesValidLeetCodeURL() {
        let slug = LeetCodeSlugParser.extractSlug(from: "https://leetcode.com/problems/reverse-linked-list/")
        XCTAssertEqual(slug, "reverse-linked-list")
    }

    func testExtractSlugReturnsNilForInvalidURL() {
        let slug = LeetCodeSlugParser.extractSlug(from: "https://example.com/problems/two-sum/")
        XCTAssertNil(slug)
    }

    func testSyncReturnsNewlyCompletedProblemsOnly() {
        let plan = makePlan()
        let solvedSlugs: Set<String> = ["two-sum", "reverse-linked-list"]
        let existing: Set<ProblemKey> = [ProblemKey(dayID: 1, problemIndex: 0)]

        let result = synchronizer.sync(
            solvedSlugs: solvedSlugs,
            plan: plan,
            existingCompleted: existing
        )

        XCTAssertEqual(result.totalMatched, 2)
        XCTAssertEqual(result.syncedCount, 1)
        XCTAssertTrue(result.newlyCompleted.contains(ProblemKey(dayID: 1, problemIndex: 1)))
    }

    func testMergedCompletionSetIncludesExistingAndNewMatches() {
        let plan = makePlan()
        let solvedSlugs: Set<String> = ["two-sum", "reverse-linked-list"]
        let existing: Set<ProblemKey> = [ProblemKey(dayID: 1, problemIndex: 0)]

        let merged = synchronizer.mergedCompletionSet(
            solvedSlugs: solvedSlugs,
            plan: plan,
            existingCompleted: existing
        )

        XCTAssertEqual(merged.count, 2)
        XCTAssertTrue(merged.contains(ProblemKey(dayID: 1, problemIndex: 0)))
        XCTAssertTrue(merged.contains(ProblemKey(dayID: 1, problemIndex: 1)))
    }

    private func makePlan() -> [StudyDay] {
        [
            StudyDay(
                id: 1,
                date: "Feb 6",
                topic: "Priority Sprint I",
                problems: [
                    Problem(
                        name: "Two Sum",
                        difficulty: .easy,
                        url: "https://leetcode.com/problems/two-sum/",
                        leetcodeNumber: 1
                    ),
                    Problem(
                        name: "Reverse Linked List",
                        difficulty: .easy,
                        url: "https://leetcode.com/problems/reverse-linked-list/",
                        leetcodeNumber: 206
                    ),
                    Problem(
                        name: "Custom Question",
                        difficulty: .medium,
                        url: "https://example.com/custom-question/"
                    )
                ]
            )
        ]
    }
}
