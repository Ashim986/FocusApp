import Foundation

struct CodingProblemItem: Identifiable {
    let id: UUID
    let dayId: Int
    let index: Int
    let problem: Problem
    let isCompleted: Bool
    let isToday: Bool
}

struct CodingProblemSection: Identifiable {
    let id: Int
    let dayId: Int
    let topic: String
    let isToday: Bool
    let problems: [CodingProblemItem]
    let completedCount: Int
    let totalCount: Int
}
