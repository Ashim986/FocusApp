import AppKit
import SwiftUI

extension CodeEditorView.Coordinator {
    func highlightKeywords(_ keywords: [String], in textStorage: NSTextStorage, text: String, color: NSColor) {
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            highlightPattern(pattern, in: textStorage, text: text, color: color)
        }
    }

    func highlightPattern(
        _ pattern: String,
        in textStorage: NSTextStorage,
        text: String,
        color: NSColor,
        options: NSRegularExpression.Options = []
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }

        let range = NSRange(location: 0, length: (text as NSString).length)
        let matches = regex.matches(in: text, options: [], range: range)
        for match in matches {
            textStorage.addAttribute(.foregroundColor, value: color, range: match.range)
        }
    }

    func highlightStrings(pattern: String, in textStorage: NSTextStorage, text: String) {
        highlightPattern(pattern, in: textStorage, text: text, color: colors.string, options: [])
    }

    func highlightMultilineStrings(in textStorage: NSTextStorage, text: String) {
        let pattern = "\"\"\"|[\\s\\S]*?\"\"\""
        highlightPattern(
            pattern,
            in: textStorage,
            text: text,
            color: colors.string,
            options: [.dotMatchesLineSeparators]
        )
    }

    func highlightPythonMultilineStrings(in textStorage: NSTextStorage, text: String) {
        let patterns = ["\"\"\"[\\s\\S]*?\"\"\"", "'''[\\s\\S]*?'''"]
        for pattern in patterns {
            highlightPattern(
                pattern,
                in: textStorage,
                text: text,
                color: colors.string,
                options: [.dotMatchesLineSeparators]
            )
        }
    }

    func highlightNumbers(in textStorage: NSTextStorage, text: String) {
        let pattern = "\\b(0x[0-9a-fA-F]+|0b[01]+|0o[0-7]+|\\d+\\.\\d+|\\d+)\\b"
        highlightPattern(pattern, in: textStorage, text: text, color: colors.number)
    }

    func highlightComments(patterns: [String], in textStorage: NSTextStorage, text: String) {
        for pattern in patterns {
            highlightPattern(pattern, in: textStorage, text: text, color: colors.comment, options: [.anchorsMatchLines])
        }
    }
}
