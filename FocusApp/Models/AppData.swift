import FocusData

typealias AppData = FocusData.AppData
typealias CodeSubmission = FocusData.CodeSubmission

extension AppData {
    // AppData in FocusData stays plan-agnostic; app-level plan counting remains here.
    func completedTopicsCount() -> Int {
        var count = 0
        for day in dsaPlan
        where completedProblemsCount(day: day.id, totalProblems: day.problems.count) == day.problems.count {
            count += 1
        }
        return count
    }
}
