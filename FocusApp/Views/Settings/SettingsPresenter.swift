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

    private let interactor: SettingsInteractor

    init(interactor: SettingsInteractor) {
        self.interactor = interactor
        self.settings = interactor.loadSettings()
        self.leetCodeUsername = interactor.currentUsername()
    }

    func onAppear() {
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

    private func scheduleValidationReset() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            usernameValidationState = .none
        }
    }
}
