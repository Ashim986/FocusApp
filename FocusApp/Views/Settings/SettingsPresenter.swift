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

    private let interactor: SettingsInteractor

    init(interactor: SettingsInteractor) {
        self.interactor = interactor
        self.settings = interactor.loadSettings()
        self.leetCodeUsername = interactor.currentUsername()
        self.planStartDate = interactor.currentPlanStartDate()
        self.aiProviderKind = interactor.currentAIProviderKind()
        self.aiProviderApiKey = interactor.currentAIProviderApiKey()
        self.aiProviderModel = interactor.currentAIProviderModel()
    }

    func onAppear() {
        planStartDate = interactor.currentPlanStartDate()
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

    private func scheduleValidationReset() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            usernameValidationState = .none
        }
    }
}
