import Foundation

enum DebugLogLevelFilter: CaseIterable {
    case all
    case info
    case warning
    case error

    var title: String {
        switch self {
        case .all: return L10n.Debug.levelAll
        case .info: return DebugLogLevel.info.rawValue
        case .warning: return DebugLogLevel.warning.rawValue
        case .error: return DebugLogLevel.error.rawValue
        }
    }

    var level: DebugLogLevel? {
        switch self {
        case .all: return nil
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}

enum DebugLogCategoryFilter: CaseIterable {
    case all
    case network
    case sync
    case execution
    case app

    var title: String {
        switch self {
        case .all: return L10n.Debug.categoryAll
        case .network: return DebugLogCategory.network.rawValue
        case .sync: return DebugLogCategory.sync.rawValue
        case .execution: return DebugLogCategory.execution.rawValue
        case .app: return DebugLogCategory.app.rawValue
        }
    }

    var category: DebugLogCategory? {
        switch self {
        case .all: return nil
        case .network: return .network
        case .sync: return .sync
        case .execution: return .execution
        case .app: return .app
        }
    }
}

struct DebugLogCounts {
    let total: Int
    let info: Int
    let warning: Int
    let error: Int
}
