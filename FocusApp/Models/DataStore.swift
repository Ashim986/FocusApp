import Foundation

protocol DateProviding {
    func now() -> Date
}

struct SystemDateProvider: DateProviding {
    func now() -> Date { Date() }
}

@MainActor
final class AppStateStore: ObservableObject {
    @Published private(set) var data: AppData

    private let storage: AppStorage
    private let calendar: Calendar
    private let dateProvider: DateProviding

    init(
        storage: AppStorage,
        calendar: Calendar = Calendar.current,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.storage = storage
        self.calendar = calendar
        self.dateProvider = dateProvider
        self.data = storage.load()
    }

    convenience init(
        storage: AppStorage,
        calendar: PlanCalendar,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.init(storage: storage, calendar: calendar.calendar, dateProvider: dateProvider)
        data.planStartDate = calendar.startDate
    }

    func reload() {
        data = storage.load()
    }

    func save() {
        storage.save(data)
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        let currentDay = currentDayNumber()
        let key = "\(day)-\(problemIndex)"
        let wasCompleted = data.progress[key] ?? false
        if !wasCompleted && day > currentDay {
            guard canCompleteFutureDay(day, currentDay: currentDay) else { return }
        }
        data.progress[key] = !wasCompleted
        if !wasCompleted {
            advanceOffsetIfAhead()
        }
        save()
    }

    func toggleHabit(_ habit: String) {
        let today = AppData.todayString()
        if data.habits[today] == nil {
            data.habits[today] = [:]
        }
        let wasCompleted = data.habits[today]?[habit] ?? false
        data.habits[today]?[habit] = !wasCompleted
        save()
    }

    func isProblemCompleted(day: Int, problemIndex: Int) -> Bool {
        data.isProblemCompleted(day: day, problemIndex: problemIndex)
    }

    func isHabitDone(_ habit: String) -> Bool {
        data.getHabitStatus(habit: habit)
    }

    func updateLeetCodeUsername(_ username: String) {
        data.leetCodeUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    func solutionCode(for key: String) -> String? {
        data.savedSolutions[key]
    }

    func saveSolution(code: String, for key: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            data.savedSolutions.removeValue(forKey: key)
        } else {
            data.savedSolutions[key] = code
        }
        save()
    }

    func submissions(for key: String) -> [CodeSubmission] {
        let entries = data.submissions[key] ?? []
        return entries.sorted { $0.createdAt > $1.createdAt }
    }

    func addSubmission(code: String, language: ProgrammingLanguage, algorithmTag: String?, for key: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let normalized = normalizeCode(trimmed, language: language)
        var entries = data.submissions[key] ?? []
        entries.removeAll { entry in
            entry.languageSlug == language.langSlug &&
            normalizeCode(entry.code, language: language) == normalized
        }
        let submission = CodeSubmission(
            id: UUID(),
            languageSlug: language.langSlug,
            code: code,
            createdAt: Date(),
            algorithmTag: algorithmTag?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
                ? nil
                : algorithmTag
        )
        entries.insert(submission, at: 0)
        data.submissions[key] = entries
        save()
    }

    func advanceToNextDay() {
        let currentDay = currentDayNumber()
        guard currentDay < 13 else { return }
        data.dayOffset += 1
        save()
    }

    func currentDayNumber() -> Int {
        let planCalendar = PlanCalendar(calendar: calendar, startDate: data.planStartDate)
        return planCalendar.currentDayNumber(today: dateProvider.now(), offset: data.dayOffset)
    }

    func planStartDate() -> Date {
        data.planStartDate
    }

    func updatePlanStartDate(_ date: Date) {
        data.planStartDate = calendar.startOfDay(for: date)
        data.dayOffset = 0
        save()
    }

    func todaysTopic() -> String {
        let dayNum = currentDayNumber()
        return dsaPlan.first(where: { $0.id == dayNum })?.topic ?? "Linked List"
    }

    @discardableResult
    func applySolvedSlugs(_ solvedSlugs: Set<String>) -> (syncedCount: Int, totalMatched: Int) {
        var syncedCount = 0
        var totalMatched = 0

        for day in dsaPlan {
            for (index, problem) in day.problems.enumerated() {
                if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
                   solvedSlugs.contains(slug) {
                    totalMatched += 1
                    if !isProblemCompleted(day: day.id, problemIndex: index) {
                        data.progress["\(day.id)-\(index)"] = true
                        syncedCount += 1
                    }
                }
            }
        }

        let didAdvance = advanceOffsetIfAhead()
        if syncedCount > 0 || didAdvance {
            save()
        }

        return (syncedCount, totalMatched)
    }

    private func canCompleteFutureDay(_ day: Int, currentDay: Int) -> Bool {
        guard day == currentDay + 1 else { return false }
        return isDayCompleted(currentDay)
    }

    private func isDayCompleted(_ day: Int) -> Bool {
        guard let dayData = dsaPlan.first(where: { $0.id == day }) else { return false }
        let completedCount = data.completedProblemsCount(day: day, totalProblems: dayData.problems.count)
        return completedCount == dayData.problems.count
    }

    @discardableResult
    private func advanceOffsetIfAhead() -> Bool {
        var didAdvance = false
        var currentDay = currentDayNumber()
        while currentDay < dsaPlan.count {
            guard isDayCompleted(currentDay) else { break }
            let nextDay = currentDay + 1
            guard nextDay <= dsaPlan.count else { break }
            guard isDayCompleted(nextDay) else { break }
            data.dayOffset += 1
            currentDay += 1
            didAdvance = true
        }
        return didAdvance
    }

    private func normalizeCode(_ code: String, language: ProgrammingLanguage) -> String {
        var cleaned = code
        let commentPatterns: [String]
        switch language {
        case .swift:
            commentPatterns = [
                "//.*",
                "/\\*([\\s\\S]*?)\\*/"
            ]
        case .python:
            commentPatterns = [
                "#.*"
            ]
        }
        for pattern in commentPatterns {
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        return cleaned
    }
}
