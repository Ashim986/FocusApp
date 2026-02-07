import Foundation

@MainActor
final class SettingsInteractor {
    private let notificationManager: NotificationManaging
    private let appStore: AppStateStore
    private let leetCodeSync: LeetCodeSyncInteractor
    private let aiTestCaseStore: AITestCaseStore

    init(
        notificationManager: NotificationManaging,
        appStore: AppStateStore,
        leetCodeSync: LeetCodeSyncInteractor,
        aiTestCaseStore: AITestCaseStore = AITestCaseStore()
    ) {
        self.notificationManager = notificationManager
        self.appStore = appStore
        self.leetCodeSync = leetCodeSync
        self.aiTestCaseStore = aiTestCaseStore
    }

    func loadSettings() -> NotificationSettings {
        notificationManager.loadSettings()
    }

    func saveSettings(_ settings: NotificationSettings) {
        notificationManager.saveSettings(settings)
    }

    func requestAuthorization() async -> Bool {
        await notificationManager.requestAuthorization()
    }

    func checkAuthorizationStatus() async -> Bool {
        await notificationManager.checkAuthorizationStatus()
    }

    func updateReminders(settings: NotificationSettings, authorized: Bool) async {
        await notificationManager.updateAllReminders(settings: settings, authorized: authorized)
    }

    func currentUsername() -> String {
        appStore.data.leetCodeUsername
    }

    func validateAndSaveUsername(_ username: String) async -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let isValid = await leetCodeSync.validateUsername(trimmed)
        guard isValid else { return false }
        appStore.updateLeetCodeUsername(trimmed)
        _ = await leetCodeSync.syncSolvedProblems(username: trimmed, limit: LeetCodeConstants.recentSubmissionsLimit)
        return true
    }

    func currentPlanStartDate() -> Date {
        appStore.planStartDate()
    }

    func updatePlanStartDate(_ date: Date) {
        appStore.updatePlanStartDate(date)
    }

    func currentAIProviderKind() -> AIProviderKind {
        AIProviderKind(rawValue: appStore.data.aiProviderKind) ?? .groq
    }

    func currentAIProviderApiKey() -> String {
        appStore.data.aiProviderApiKey
    }

    func currentAIProviderModel() -> String {
        appStore.data.aiProviderModel
    }

    func updateAIProviderSettings(kind: AIProviderKind, apiKey: String, model: String) {
        appStore.updateAIProviderSettings(kind: kind.rawValue, apiKey: apiKey, model: model)
    }

    func currentLeetCodeAuth() -> LeetCodeAuthSession? {
        appStore.leetCodeAuth()
    }

    func updateLeetCodeAuth(_ auth: LeetCodeAuthSession) {
        appStore.updateLeetCodeAuth(auth)
    }

    func clearLeetCodeAuth() {
        appStore.clearLeetCodeAuth()
    }

    func aiTestCaseSummary() -> AITestCaseStoreSummary {
        aiTestCaseStore.summary()
    }

    func aiTestCaseRawJSON() -> String? {
        aiTestCaseStore.rawJSONString()
    }

    func aiTestCaseFileURL() -> URL {
        aiTestCaseStore.locationURL
    }
}
