import AppKit
import FocusDesignSystem
import SwiftUI

extension CodeEditorView {
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeEditorView
        weak var textView: NSTextView?
        var editorColors: CodeEditorThemeColors
        var themeKind: DSThemeKind
        var isEditing = false
        var language: ProgrammingLanguage = .swift
        var isInsertingMatchingBracket = false
        var indentUnit: String {
            language == .swift ? "  " : "    "
        }
        var diagnostics: [CodeEditorDiagnostic] = []
        var executionLine: Int?
        var bracketHighlightRanges: [NSRange] = []

        let colors = SyntaxColors()

        var bracketPairs: [Character: Character] {
            [
                "{": "}",
                "(": ")",
                "[": "]",
                "\"": "\"",
                "'": "'"
            ]
        }

        var closingBrackets: Set<Character> {
            ["}", ")", "]", "\"", "'"]
        }

        var openingBrackets: Set<Character> {
            ["{", "(", "["]
        }

        struct SyntaxColors {
            // Xcode Default (Dark) theme values.
            let keyword = NSColor(calibratedRed: 0.988394, green: 0.37355, blue: 0.638329, alpha: 1.0)
            let type = NSColor(calibratedRed: 0.621449, green: 0.943864, blue: 0.868194, alpha: 1.0)
            let function = NSColor(calibratedRed: 0.403922, green: 0.717647, blue: 0.643137, alpha: 1.0)
            let variable = NSColor(calibratedRed: 0.405383, green: 0.717051, blue: 0.642088, alpha: 1.0)
            let declaration = NSColor(calibratedRed: 0.988394, green: 0.37355, blue: 0.638329, alpha: 1.0)
            let string = NSColor(calibratedRed: 0.989117, green: 0.41558, blue: 0.365684, alpha: 1.0)
            let number = NSColor(calibratedRed: 0.814983, green: 0.749393, blue: 0.412334, alpha: 1.0)
            let comment = NSColor(calibratedRed: 0.423943, green: 0.474618, blue: 0.525183, alpha: 1.0)
            let `default` = NSColor(white: 1.0, alpha: 0.85)
            let executionHighlight = NSColor(calibratedRed: 0.138526, green: 0.146864, blue: 0.169283, alpha: 1.0)
        }

        init(_ parent: CodeEditorView, editorColors: CodeEditorThemeColors, themeKind: DSThemeKind) {
            self.parent = parent
            self.editorColors = editorColors
            self.themeKind = themeKind
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
            textView.enclosingScrollView?.verticalRulerView?.needsDisplay = true
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            updateBracketHighlights(in: textView)
        }
    }
}
