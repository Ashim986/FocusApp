import Combine
import Foundation

@MainActor
final class ToolbarWidgetPresenter: ObservableObject {
    @Published private(set) var data: AppData
    @Published var isSyncing: Bool = false
    @Published var lastSyncResult: String = ""
    @Published var isValidatingUsername: Bool = false
    @Published var usernameValidationState: UsernameValidationState = .none
    @Published var editingUsername: String

    private let interactor: ToolbarWidgetInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: ToolbarWidgetInteractor) {
        self.interactor = interactor
        self.data = interactor.currentData
        self.editingUsername = interactor.currentUsername()
        bind()
    }

    var totalProblems: Int {
        dsaPlan.reduce(0) { $0 + $1.problems.count }
    }

    var solvedProblems: Int {
        data.totalCompletedProblems()
    }

    var progressPercentage: Double {
        guard totalProblems > 0 else { return 0 }
        return Double(solvedProblems) / Double(totalProblems) * 100
    }

    var currentDayNumber: Int {
        interactor.currentDayNumber()
    }

    var todaysTopic: String {
        interactor.todaysTopic()
    }

    var todaysProblems: [Problem] {
        guard let dayData = dsaPlan.first(where: { $0.id == currentDayNumber }) else { return [] }
        return dayData.problems
    }

    var habitsCompletedToday: Int {
        data.todayHabitsCount()
    }

    var tomorrowDayNumber: Int {
        min(currentDayNumber + 1, dsaPlan.count)
    }

    var tomorrowsTopic: String {
        guard let dayData = dsaPlan.first(where: { $0.id == tomorrowDayNumber }) else { return "Complete!" }
        return dayData.topic
    }

    var tomorrowsProblems: [Problem] {
        guard let dayData = dsaPlan.first(where: { $0.id == tomorrowDayNumber }) else { return [] }
        return dayData.problems
    }

    var carryoverProblems: [(index: Int, problem: Problem)] {
        todaysProblems.enumerated().compactMap { index, problem in
            data.isProblemCompleted(day: currentDayNumber, problemIndex: index) ? nil : (index, problem)
        }
    }

    var hasTomorrow: Bool {
        currentDayNumber < dsaPlan.count
    }

    var allTodaysSolved: Bool {
        guard !todaysProblems.isEmpty else { return false }
        return todaysProblems.indices.allSatisfy { index in
            data.isProblemCompleted(day: currentDayNumber, problemIndex: index)
        }
    }

    func beginEditingUsername() {
        editingUsername = interactor.currentUsername()
    }

    func resetValidationState() {
        usernameValidationState = .none
    }

    func validateAndSaveUsername() {
        Task {
            isValidatingUsername = true
            let isValid = await interactor.validateAndSaveUsername(editingUsername)
            isValidatingUsername = false
            usernameValidationState = isValid ? .valid : .invalid
            scheduleValidationReset()
        }
    }

    func syncNow() {
        guard !isSyncing else { return }
        let username = data.leetCodeUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !username.isEmpty else {
            lastSyncResult = "Set username in Settings"
            return
        }

        isSyncing = true
        lastSyncResult = "Syncing..."
        Task {
            let result = await interactor.syncSolvedProblems(username: username)
            if result.syncedCount > 0 {
                lastSyncResult = "Synced \(result.syncedCount) new problems"
            } else if result.totalMatched > 0 {
                lastSyncResult = "\(result.totalMatched) problems up to date"
            } else {
                lastSyncResult = "Sync complete"
            }
            isSyncing = false
            scheduleSyncMessageClear()
        }
    }

    func toggleHabit(_ habit: String) {
        interactor.toggleHabit(habit)
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        interactor.toggleProblem(day: day, problemIndex: problemIndex)
    }

    func advanceToNextDay() {
        interactor.advanceToNextDay()
    }

    private func bind() {
        interactor.dataPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.data = data
            }
            .store(in: &cancellables)
    }

    private func scheduleSyncMessageClear() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            lastSyncResult = ""
        }
    }

    private func scheduleValidationReset() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            usernameValidationState = .none
        }
    }
}
