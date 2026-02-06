import SwiftUI

extension SettingsView {
    var studyReminderEnabled: Binding<Bool> {
        Binding(
            get: { presenter.settings.studyReminderEnabled },
            set: { value in
                presenter.updateSettings { $0.studyReminderEnabled = value }
            }
        )
    }

    var studyReminderTime: Binding<Date> {
        Binding(
            get: { presenter.settings.studyReminderTime },
            set: { value in
                presenter.updateSettings { $0.studyReminderTime = value }
            }
        )
    }

    var habitReminderEnabled: Binding<Bool> {
        Binding(
            get: { presenter.settings.habitReminderEnabled },
            set: { value in
                presenter.updateSettings { $0.habitReminderEnabled = value }
            }
        )
    }

    var habitReminderTime: Binding<Date> {
        Binding(
            get: { presenter.settings.habitReminderTime },
            set: { value in
                presenter.updateSettings { $0.habitReminderTime = value }
            }
        )
    }

    var planStartDate: Binding<Date> {
        Binding(
            get: { presenter.planStartDate },
            set: { value in
                presenter.updatePlanStartDate(value)
            }
        )
    }

    var aiProviderKind: Binding<AIProviderKind> {
        Binding(
            get: { presenter.aiProviderKind },
            set: { value in
                presenter.updateAIProvider(kind: value)
            }
        )
    }

    var aiProviderModel: Binding<String> {
        Binding(
            get: { presenter.aiProviderModel },
            set: { value in
                presenter.aiProviderModel = value
                presenter.saveAIProviderSettings()
            }
        )
    }
}
