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
}
