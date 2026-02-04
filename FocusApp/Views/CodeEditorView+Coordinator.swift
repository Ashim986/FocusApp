import AppKit
import SwiftUI

extension CodeEditorView {
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeEditorView
        weak var textView: NSTextView?
        var isEditing = false
        var language: ProgrammingLanguage = .swift
        var isInsertingMatchingBracket = false
        let indentUnit = "    "

        let colors = SyntaxColors()

        var bracketPairs: [Character: Character] {
            var pairs: [Character: Character] = [
                "{": "}",
                "(": ")",
                "[": "]",
                "\"": "\"",
                "'": "'"
            ]

            if language == .swift {
                pairs["<"] = ">"
            }

            return pairs
        }

        var closingBrackets: Set<Character> {
            var set: Set<Character> = ["}", ")", "]", "\"", "'"]
            if language == .swift {
                set.insert(">")
            }
            return set
        }

        var openingBrackets: Set<Character> {
            var set: Set<Character> = ["{", "(", "["]
            if language == .swift {
                set.insert("<")
            }
            return set
        }

        struct SyntaxColors {
            let keyword = NSColor(Color.appPurple)
            let type = NSColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 1.0)
            let function = NSColor(red: 0.98, green: 0.78, blue: 0.35, alpha: 1.0)
            let string = NSColor(Color.appGreen)
            let number = NSColor(Color.appAmber)
            let comment = NSColor(Color.appGray500)
            let `default` = NSColor.white
        }

        init(_ parent: CodeEditorView) {
            self.parent = parent
        }

        func textDidBeginEditing(_ notification: Notification) {
            isEditing = true
        }

        func textDidEndEditing(_ notification: Notification) {
            isEditing = false
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.code = textView.string
            applySyntaxHighlighting()
        }
    }
}
