import FocusDomain
import Foundation

public struct LeetCodeSyncResult: Equatable, Sendable {
    public let newlyCompleted: Set<ProblemKey>
    public let totalMatched: Int

    public init(newlyCompleted: Set<ProblemKey>, totalMatched: Int) {
        self.newlyCompleted = newlyCompleted
        self.totalMatched = totalMatched
    }

    public var syncedCount: Int {
        newlyCompleted.count
    }
}

public struct LeetCodeProgressSynchronizer: Sendable {
    public init() {}

    public func sync(
        solvedSlugs: Set<String>,
        plan: [StudyDay],
        existingCompleted: Set<ProblemKey>
    ) -> LeetCodeSyncResult {
        var newlyCompleted: Set<ProblemKey> = []
        var totalMatched = 0

        for day in plan {
            for (index, problem) in day.problems.enumerated() {
                guard let slug = LeetCodeSlugParser.extractSlug(from: problem.url),
                      solvedSlugs.contains(slug) else {
                    continue
                }

                totalMatched += 1

                let key = ProblemKey(dayID: day.id, problemIndex: index)
                if !existingCompleted.contains(key) {
                    newlyCompleted.insert(key)
                }
            }
        }

        return LeetCodeSyncResult(newlyCompleted: newlyCompleted, totalMatched: totalMatched)
    }

    public func mergedCompletionSet(
        solvedSlugs: Set<String>,
        plan: [StudyDay],
        existingCompleted: Set<ProblemKey>
    ) -> Set<ProblemKey> {
        let result = sync(
            solvedSlugs: solvedSlugs,
            plan: plan,
            existingCompleted: existingCompleted
        )
        return existingCompleted.union(result.newlyCompleted)
    }
}
