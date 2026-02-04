import Foundation

enum AppStrings {
    static func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    static func format(_ key: String, _ args: CVarArg...) -> String {
        String(format: NSLocalizedString(key, comment: ""), locale: .current, arguments: args)
    }
}
