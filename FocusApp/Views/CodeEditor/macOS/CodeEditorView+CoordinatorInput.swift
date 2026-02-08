#if os(macOS)
import AppKit

extension CodeEditorView.Coordinator {
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            handleNewLine(textView: textView, range: textView.selectedRange(), text: textView.string)
            return true
        case #selector(NSResponder.insertTab(_:)):
            indentSelection(in: textView)
            return true
        case #selector(NSResponder.insertBacktab(_:)):
            outdentSelection(in: textView)
            return true
        case #selector(NSResponder.deleteBackward(_:)):
            return handleBackspace(in: textView)
        default:
            return false
        }
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        guard let replacementString = replacementString else { return true }
        if isInsertingMatchingBracket { return true }
        let nsText = textView.string as NSString
        if replacementString.count == 1, let char = replacementString.first {
            if let handled = handleSingleCharacterInsertion(
                char,
                in: textView,
                range: affectedCharRange,
                text: nsText
            ) {
                return handled
            }
        }

        return true
    }

    private func handleSingleCharacterInsertion(
        _ char: Character,
        in textView: NSTextView,
        range: NSRange,
        text: NSString
    ) -> Bool? {
        if let closingChar = bracketPairs[char] {
            if range.length > 0 {
                wrapSelection(opening: char, closing: closingChar, in: textView, at: range)
                return false
            }

            if isQuote(char), shouldSkipExisting(char, in: text, at: range.location) {
                textView.setSelectedRange(NSRange(location: range.location + 1, length: 0))
                return false
            }

            insertMatchingBracket(opening: char, closing: closingChar, in: textView, at: range)
            return false
        }

        if closingBrackets.contains(char) {
            if shouldSkipExisting(char, in: text, at: range.location) {
                textView.setSelectedRange(NSRange(location: range.location + 1, length: 0))
                return false
            }

            if shouldAlignClosingBracket(char, in: textView, at: range) {
                return false
            }
        }

        return nil
    }

    private func isQuote(_ char: Character) -> Bool {
        char == "\"" || char == "'"
    }

    private func shouldSkipExisting(_ char: Character, in text: NSString, at location: Int) -> Bool {
        guard location < text.length else { return false }
        let nextChar = text.substring(with: NSRange(location: location, length: 1))
        return nextChar == String(char)
    }

    func toggleComment(in textView: NSTextView) {
        let selection = textView.selectedRange()
        let nsText = textView.string as NSString
        let lineRange = nsText.lineRange(for: selection)
        let selectedText = nsText.substring(with: lineRange)
        let lines = selectedText.components(separatedBy: "\n")
        let prefix = language == .python ? "#" : "//"

        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let shouldUncomment = !nonEmptyLines.isEmpty && nonEmptyLines.allSatisfy { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix(prefix)
        }

        let updated = lines.map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return line }
            let leading = line.prefix { $0 == " " || $0 == "\t" }
            let rest = line.dropFirst(leading.count)
            if shouldUncomment, rest.hasPrefix(prefix) {
                var remainder = rest.dropFirst(prefix.count)
                if remainder.first == " " {
                    remainder = remainder.dropFirst()
                }
                return String(leading) + remainder
            }
            return String(leading) + prefix + " " + rest
        }

        let replacement = updated.joined(separator: "\n")
        textView.textStorage?.replaceCharacters(in: lineRange, with: replacement)
        textView.setSelectedRange(NSRange(location: lineRange.location, length: (replacement as NSString).length))
    }

    func insertTraceSnippet(in textView: NSTextView) {
        let snippet: String
        switch language {
        case .swift:
            snippet = "Trace.step(\"label\", [\"key\": value])"
        case .python:
            snippet = "# Trace.step(\"label\", {\"key\": value})"
        }
        insertText(snippet, in: textView, at: textView.selectedRange())
    }
}
#endif
