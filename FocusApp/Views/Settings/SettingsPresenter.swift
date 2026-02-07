import Combine
import Foundation

enum UsernameValidationState {
    case none
    case valid
    case invalid
}

@MainActor
final class SettingsPresenter: ObservableObject {
    @Published var settings: NotificationSettings
    @Published var notificationsAuthorized: Bool = false
    @Published var leetCodeUsername: String
    @Published var isValidatingUsername: Bool = false
    @Published var usernameValidationState: UsernameValidationState = .none
    @Published var planStartDate: Date
    @Published var aiProviderKind: AIProviderKind
    @Published var aiProviderApiKey: String
    @Published var aiProviderModel: String
    @Published var leetCodeAuth: LeetCodeAuthSession?
    @Published var aiTestCaseSummary: AITestCaseStoreSummary

    private let interactor: SettingsInteractor

    init(interactor: SettingsInteractor) {
        self.interactor = interactor
        self.settings = interactor.loadSettings()
        self.leetCodeUsername = interactor.currentUsername()
        self.planStartDate = interactor.currentPlanStartDate()
        self.aiProviderKind = interactor.currentAIProviderKind()
        self.aiProviderApiKey = interactor.currentAIProviderApiKey()
        self.aiProviderModel = interactor.currentAIProviderModel()
        self.leetCodeAuth = interactor.currentLeetCodeAuth()
        self.aiTestCaseSummary = interactor.aiTestCaseSummary()
    }

    func onAppear() {
        planStartDate = interactor.currentPlanStartDate()
        aiTestCaseSummary = interactor.aiTestCaseSummary()
        Task {
            let authorized = await interactor.checkAuthorizationStatus()
            notificationsAuthorized = authorized
            await interactor.updateReminders(settings: settings, authorized: authorized)
        }
    }

    func requestAuthorization() {
        Task {
            let authorized = await interactor.requestAuthorization()
            notificationsAuthorized = authorized
            await interactor.updateReminders(settings: settings, authorized: authorized)
        }
    }

    func updateSettings(_ update: (inout NotificationSettings) -> Void) {
        var updated = settings
        update(&updated)
        settings = updated
        interactor.saveSettings(updated)
        Task {
            await interactor.updateReminders(settings: updated, authorized: notificationsAuthorized)
        }
    }

    func validateAndSaveUsername() {
        Task {
            isValidatingUsername = true
            let isValid = await interactor.validateAndSaveUsername(leetCodeUsername)
            isValidatingUsername = false
            usernameValidationState = isValid ? .valid : .invalid
            scheduleValidationReset()
        }
    }

    func resetValidationState() {
        usernameValidationState = .none
    }

    func updatePlanStartDate(_ date: Date) {
        planStartDate = date
        interactor.updatePlanStartDate(date)
    }

    func resetPlanStartDateToToday() {
        let today = Date()
        planStartDate = today
        interactor.updatePlanStartDate(today)
    }

    func updateAIProvider(kind: AIProviderKind) {
        aiProviderKind = kind
        if aiProviderModel.isEmpty || !kind.modelOptions.contains(aiProviderModel) {
            aiProviderModel = kind.defaultModel
        }
        saveAIProviderSettings()
    }

    func saveAIProviderSettings() {
        interactor.updateAIProviderSettings(
            kind: aiProviderKind,
            apiKey: aiProviderApiKey,
            model: aiProviderModel
        )
    }

    func updateLeetCodeAuth(_ auth: LeetCodeAuthSession) {
        interactor.updateLeetCodeAuth(auth)
        leetCodeAuth = auth
    }

    func clearLeetCodeAuth() {
        interactor.clearLeetCodeAuth()
        leetCodeAuth = nil
    }

    func aiTestCaseRawJSON() -> String? {
        interactor.aiTestCaseRawJSON()
    }

    func aiTestCaseFileURL() -> URL {
        interactor.aiTestCaseFileURL()
    }

    func aiTestCaseUpdatedText() -> String? {
        guard let updatedAt = aiTestCaseSummary.updatedAt else { return nil }
        let formatter = SettingsPresenter.aiTestCaseDateFormatter
        if let date = ISO8601DateFormatter().date(from: updatedAt) {
            return formatter.string(from: date)
        }
        return updatedAt
    }

    private func scheduleValidationReset() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            usernameValidationState = .none
        }
    }

    private static let aiTestCaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
