import Foundation

struct AppNotice {
    let title: String
    let body: String
}

enum AppNotices {
    static var studyReminder: AppNotice {
        AppNotice(
            title: L10n.Notification.Study.title,
            body: L10n.Notification.Study.body
        )
    }

    static var habitReminder: AppNotice {
        AppNotice(
            title: L10n.Notification.Habits.title,
            body: L10n.Notification.Habits.body
        )
    }

    static func topicComplete(_ topic: String) -> AppNotice {
        AppNotice(
            title: L10n.Notification.TopicComplete.title,
            body: L10n.Notification.TopicComplete.bodyFormat(topic)
        )
    }

    static var habitsComplete: AppNotice {
        AppNotice(
            title: L10n.Notification.HabitsComplete.title,
            body: L10n.Notification.HabitsComplete.body
        )
    }
}

enum AppUserMessage {
    case unsupportedLanguage(String)
    case failedToWriteSource(String)
    case failedToRunProcess(String)
    case executionStopped
    case outputLimitExceeded

    var text: String {
        switch self {
        case .unsupportedLanguage(let language):
            return L10n.Error.unsupportedLanguageFormat(language)
        case .failedToWriteSource(let details):
            return L10n.Error.failedToWriteSourceFormat(details)
        case .failedToRunProcess(let details):
            return L10n.Error.failedToRunProcessFormat(details)
        case .executionStopped:
            return L10n.Error.executionStopped
        case .outputLimitExceeded:
            return L10n.Error.outputLimitExceeded
        }
    }
}
