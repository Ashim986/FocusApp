import Foundation

enum Tab: Hashable {
    case plan
    case today
    case stats
    case focus
    case coding

    /// Tabs shown in the macOS segmented control header.
    static let macTabs: [Tab] = [.plan, .today, .stats]

    /// Tabs shown in the iOS bottom tab bar / iPad sidebar.
    static let iOSTabs: [Tab] = [.today, .plan, .stats, .focus, .coding]

    var icon: String {
        switch self {
        case .plan: return "list.bullet.clipboard"
        case .today: return "sun.max.fill"
        case .stats: return "chart.bar.fill"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var activeIcon: String {
        switch self {
        case .today: return "house.fill"
        case .plan: return "calendar"
        case .stats: return "chart.bar.fill"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var title: String {
        switch self {
        case .plan: return L10n.Tab.plan
        case .today: return L10n.Tab.today
        case .stats: return L10n.Tab.stats
        case .focus: return "Focus"
        case .coding: return "Coding"
        }
    }

    var id: String {
        switch self {
        case .plan: return "plan"
        case .today: return "today"
        case .stats: return "stats"
        case .focus: return "focus"
        case .coding: return "coding"
        }
    }
}
