@testable import FocusApp
import XCTest

struct ProblemLocation {
    let problem: Problem
    let dayId: Int
    let index: Int
}

func problemWithSlug(
    _ slug: String,
    file: StaticString = #file,
    line: UInt = #line
) -> Problem {
    for day in dsaPlan {
        for problem in day.problems where LeetCodeSlugExtractor.extractSlug(from: problem.url) == slug {
            return problem
        }
    }
    XCTFail("Missing problem for slug \(slug)", file: file, line: line)
    return dsaPlan.first?.problems.first ?? Problem(
        name: slug,
        difficulty: .easy,
        url: "https://leetcode.com/problems/\(slug)/"
    )
}

func problemLocation(
    for slug: String,
    file: StaticString = #file,
    line: UInt = #line
) -> ProblemLocation {
    for day in dsaPlan {
        if let index = day.problems.firstIndex(
            where: { LeetCodeSlugExtractor.extractSlug(from: $0.url) == slug }
        ) {
            return ProblemLocation(problem: day.problems[index], dayId: day.id, index: index)
        }
    }
    XCTFail("Missing problem location for slug \(slug)", file: file, line: line)
    let fallback = problemWithSlug(slug, file: file, line: line)
    return ProblemLocation(problem: fallback, dayId: 1, index: 0)
}
