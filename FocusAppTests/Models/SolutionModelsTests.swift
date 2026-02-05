import XCTest
@testable import FocusApp

final class SolutionModelsTests: XCTestCase {
    // MARK: - ComplexityAnalysis Tests

    func testComplexityAnalysisEncoding() throws {
        let complexity = ComplexityAnalysis(
            time: "O(n)",
            space: "O(1)",
            timeExplanation: "Linear scan",
            spaceExplanation: "Constant extra space"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(complexity)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ComplexityAnalysis.self, from: data)

        XCTAssertEqual(decoded.time, "O(n)")
        XCTAssertEqual(decoded.space, "O(1)")
        XCTAssertEqual(decoded.timeExplanation, "Linear scan")
        XCTAssertEqual(decoded.spaceExplanation, "Constant extra space")
    }

    func testComplexityAnalysisWithoutExplanations() throws {
        let complexity = ComplexityAnalysis(
            time: "O(n log n)",
            space: "O(n)"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(complexity)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ComplexityAnalysis.self, from: data)

        XCTAssertEqual(decoded.time, "O(n log n)")
        XCTAssertEqual(decoded.space, "O(n)")
        XCTAssertNil(decoded.timeExplanation)
        XCTAssertNil(decoded.spaceExplanation)
    }

    // MARK: - SolutionTestCase Tests

    func testSolutionTestCaseEncoding() throws {
        let testCase = SolutionTestCase(
            input: "[1,2,3]",
            expectedOutput: "[3,2,1]",
            explanation: "Reverse the array"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(testCase)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SolutionTestCase.self, from: data)

        XCTAssertEqual(decoded.input, "[1,2,3]")
        XCTAssertEqual(decoded.expectedOutput, "[3,2,1]")
        XCTAssertEqual(decoded.explanation, "Reverse the array")
    }

    func testSolutionTestCaseIdentifiable() {
        let testCase1 = SolutionTestCase(input: "a", expectedOutput: "b")
        let testCase2 = SolutionTestCase(input: "a", expectedOutput: "b")

        XCTAssertNotEqual(testCase1.id, testCase2.id)
    }

    // MARK: - SolutionApproach Tests

    func testSolutionApproachEncoding() throws {
        let approach = SolutionApproach(
            name: "Two Pointers",
            order: 1,
            intuition: "Use two pointers from start and end",
            approach: "1. Initialize pointers\n2. Move towards center",
            explanation: "Detailed explanation here",
            code: "func twoSum(_ nums: [Int]) -> [Int] { return [] }",
            complexity: ComplexityAnalysis(time: "O(n)", space: "O(1)"),
            testCases: [
                SolutionTestCase(input: "[1,2]", expectedOutput: "[0,1]"),
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(approach)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SolutionApproach.self, from: data)

        XCTAssertEqual(decoded.name, "Two Pointers")
        XCTAssertEqual(decoded.order, 1)
        XCTAssertEqual(decoded.intuition, "Use two pointers from start and end")
        XCTAssertEqual(decoded.complexity.time, "O(n)")
        XCTAssertEqual(decoded.testCases.count, 1)
    }

    func testSolutionApproachEmptyTestCases() throws {
        let approach = SolutionApproach(
            name: "Brute Force",
            order: 1,
            intuition: "Check all pairs",
            approach: "Nested loops",
            explanation: "Simple but slow",
            code: "// code",
            complexity: ComplexityAnalysis(time: "O(n^2)", space: "O(1)")
        )

        XCTAssertTrue(approach.testCases.isEmpty)
    }

    // MARK: - ProblemSolution Tests

    func testProblemSolutionEncoding() throws {
        let solution = ProblemSolution(
            problemSlug: "two-sum",
            summary: "Find two numbers that add up to target",
            approaches: [
                SolutionApproach(
                    name: "Hash Map",
                    order: 1,
                    intuition: "Store seen values",
                    approach: "Use dictionary",
                    explanation: "O(n) solution",
                    code: "func twoSum() {}",
                    complexity: ComplexityAnalysis(time: "O(n)", space: "O(n)")
                ),
            ],
            relatedProblems: ["three-sum", "four-sum"]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(solution)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ProblemSolution.self, from: data)

        XCTAssertEqual(decoded.problemSlug, "two-sum")
        XCTAssertEqual(decoded.summary, "Find two numbers that add up to target")
        XCTAssertEqual(decoded.approaches.count, 1)
        XCTAssertEqual(decoded.relatedProblems?.count, 2)
    }

    func testProblemSolutionSortedApproaches() {
        let solution = ProblemSolution(
            problemSlug: "test",
            summary: "Test",
            approaches: [
                SolutionApproach(
                    name: "Third",
                    order: 3,
                    intuition: "",
                    approach: "",
                    explanation: "",
                    code: "",
                    complexity: ComplexityAnalysis(time: "O(1)", space: "O(1)")
                ),
                SolutionApproach(
                    name: "First",
                    order: 1,
                    intuition: "",
                    approach: "",
                    explanation: "",
                    code: "",
                    complexity: ComplexityAnalysis(time: "O(1)", space: "O(1)")
                ),
                SolutionApproach(
                    name: "Second",
                    order: 2,
                    intuition: "",
                    approach: "",
                    explanation: "",
                    code: "",
                    complexity: ComplexityAnalysis(time: "O(1)", space: "O(1)")
                ),
            ]
        )

        let sorted = solution.sortedApproaches
        XCTAssertEqual(sorted[0].name, "First")
        XCTAssertEqual(sorted[1].name, "Second")
        XCTAssertEqual(sorted[2].name, "Third")
    }

    // MARK: - SolutionsBundle Tests

    func testSolutionsBundleEncoding() throws {
        let bundle = SolutionsBundle(
            version: "1.0.0",
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
        let decoded = try decoder.decode(SolutionsBundle.self, from: data)

        XCTAssertEqual(decoded.version, "1.0.0")
        XCTAssertEqual(decoded.solutions.count, 1)
        XCTAssertEqual(decoded.solutions[0].problemSlug, "reverse-linked-list")
    }

    // MARK: - Equatable Tests

    func testComplexityAnalysisEquatable() {
        let c1 = ComplexityAnalysis(time: "O(n)", space: "O(1)")
        let c2 = ComplexityAnalysis(time: "O(n)", space: "O(1)")
        let c3 = ComplexityAnalysis(time: "O(n^2)", space: "O(1)")

        XCTAssertEqual(c1, c2)
        XCTAssertNotEqual(c1, c3)
    }

    func testSolutionTestCaseEquatable() {
        let id = UUID()
        let t1 = SolutionTestCase(id: id, input: "a", expectedOutput: "b")
        let t2 = SolutionTestCase(id: id, input: "a", expectedOutput: "b")
        let t3 = SolutionTestCase(id: id, input: "x", expectedOutput: "b")

        XCTAssertEqual(t1, t2)
        XCTAssertNotEqual(t1, t3)
    }
}
