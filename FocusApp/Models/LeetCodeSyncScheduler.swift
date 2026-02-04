import Combine
import Foundation

protocol LeetCodeSyncing {
    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult
}

extension LeetCodeSyncInteractor: LeetCodeSyncing { }

@MainActor
final class LeetCodeSyncScheduler {
    enum Trigger: String {
        case hourly
        case dayStart
        case usernameChanged
    }

    private let appStore: AppStateStore
    private let syncer: LeetCodeSyncing
    private var hourlyTimer: Timer?
    private var dayTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var isRunning = false
    private var isSyncing = false

    init(appStore: AppStateStore, syncer: LeetCodeSyncing) {
        self.appStore = appStore
        self.syncer = syncer
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleHourlySync()
        scheduleDayStartSync()
        observeUsernameChanges()
    }

    func stop() {
        hourlyTimer?.invalidate()
        dayTimer?.invalidate()
        hourlyTimer = nil
        dayTimer = nil
        cancellables.removeAll()
        isRunning = false
    }

    func syncNow(trigger: Trigger) async {
        guard !isSyncing else { return }
        let username = appStore.data.leetCodeUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !username.isEmpty else { return }
        isSyncing = true
        defer { isSyncing = false }
        _ = await syncer.syncSolvedProblems(
            username: username,
            limit: LeetCodeConstants.recentSubmissionsLimit
        )
    }

    func handleUsernameChange(_ username: String) {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task { [weak self] in
            await self?.syncNow(trigger: .usernameChanged)
        }
    }

    private func observeUsernameChanges() {
        appStore.$data
            .map { $0.leetCodeUsername }
            .removeDuplicates()
            .sink { [weak self] username in
                self?.handleUsernameChange(username)
            }
            .store(in: &cancellables)
    }

    private func scheduleHourlySync() {
        hourlyTimer?.invalidate()
        hourlyTimer = Timer.scheduledTimer(withTimeInterval: LeetCodeConstants.syncInterval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.syncNow(trigger: .hourly)
            }
        }
    }

    private func scheduleDayStartSync() {
        dayTimer?.invalidate()
        let now = Date()
        let calendar = Calendar.current
        let nextMidnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86_400)

        let timer = Timer(fire: nextMidnight, interval: 0, repeats: false) { [weak self] _ in
            Task { [weak self] in
                await self?.syncNow(trigger: .dayStart)
            }
            self?.scheduleDayStartSync()
        }
        RunLoop.main.add(timer, forMode: .common)
        dayTimer = timer
    }
}
