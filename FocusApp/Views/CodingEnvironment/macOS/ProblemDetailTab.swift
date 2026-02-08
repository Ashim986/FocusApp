import Foundation

enum ProblemDetailTab: CaseIterable {
    case description
    case editorial
    case solution
    case submissions
    case debug

    var icon: String {
        switch self {
        case .description:
            return "doc.text"
        case .editorial:
            return "lightbulb"
        case .solution:
            return "checkmark.seal"
        case .submissions:
            return "clock.arrow.circlepath"
        case .debug:
            return "ladybug"
        }
    }

    var title: String {
        switch self {
        case .description:
            return L10n.Coding.tabDescription
        case .editorial:
            return L10n.Coding.tabEditorial
        case .solution:
            return L10n.Coding.tabSolution
        case .submissions:
            return L10n.Coding.tabSubmissions
        case .debug:
            return L10n.Coding.tabDebug
        }
    }
}
