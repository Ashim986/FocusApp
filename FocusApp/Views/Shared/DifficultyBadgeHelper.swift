import FocusDesignSystem

enum DifficultyBadgeHelper {
    static func badgeStyle(for difficulty: Difficulty) -> DSBadgeStyle {
        switch difficulty {
        case .easy: return .success
        case .medium: return .warning
        case .hard: return .danger
        }
    }
}
