import Foundation

extension L10n.Output {
    static func lineCount(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("output.line_count", comment: "Console output line count"),
            count
        )
    }
}

extension L10n.Coding.Output {
    static func testsPassed(_ passed: Int, _ total: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("coding.output.tests_passed", comment: "Test cases passed summary"),
            passed,
            total
        )
    }
}

extension L10n.Widget {
    static func tomorrowProblemCount(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("widget.tomorrow_problem_count", comment: "Tomorrow problem count"),
            count
        )
    }

    static func tomorrowCarryoverCount(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("widget.tomorrow_carryover_count", comment: "Carryover problem count"),
            count
        )
    }
}
