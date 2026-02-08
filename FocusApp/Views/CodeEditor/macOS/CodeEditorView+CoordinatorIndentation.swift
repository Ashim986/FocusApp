#if os(macOS)
import AppKit

extension CodeEditorView.Coordinator {
    func handleNewLine(textView: NSTextView, range: NSRange, text: String) {
        let nsText = text as NSString
        let lineStart = nsText.lineRange(for: NSRange(location: range.location, length: 0)).location
        let lineRange = NSRange(location: lineStart, length: range.location - lineStart)
        let lineUpToCursor = nsText.substring(with: lineRange)

        let indentation = leadingIndentation(in: lineUpToCursor)

        let trimmedLine = lineUpToCursor.trimmingCharacters(in: .whitespaces)
        let shouldIncreaseIndent = shouldIncreaseIndent(for: trimmedLine)
        let shouldAddClosingBrace = shouldAddClosingBrace(for: trimmedLine, in: nsText, at: range.location)

        var newText = "\n" + indentation
        if shouldIncreaseIndent {
            newText += indentUnit
        }

        if shouldAddClosingBrace {
            newText += "\n" + indentation
            insertText(newText, in: textView, at: range)
            let cursorPos = range.location + 1 + indentation.count + indentUnit.count
            textView.setSelectedRange(NSRange(location: cursorPos, length: 0))
        } else {
            insertText(newText, in: textView, at: range)
        }
    }

    func leadingIndentation(in line: String) -> String {
        var indentation = ""
        for char in line {
            if char == " " {
                indentation += " "
            } else if char == "\t" {
                indentation += indentUnit
            } else {
                break
            }
        }
        return indentation
    }

    private func shouldIncreaseIndent(for trimmedLine: String) -> Bool {
        if trimmedLine.hasSuffix("{") || trimmedLine.hasSuffix("(") || trimmedLine.hasSuffix("[") {
            return true
        }

        if language == .python &&
            (trimmedLine.hasSuffix(":") || trimmedLine.hasSuffix("(") || trimmedLine.hasSuffix("[")) {
            return true
        }

        return false
    }

    private func shouldAddClosingBrace(for trimmedLine: String, in text: NSString, at location: Int) -> Bool {
        guard trimmedLine.hasSuffix("{") else { return false }
        let openCount = trimmedLine.filter { $0 == "{" }.count
        let closeCount = trimmedLine.filter { $0 == "}" }.count
        guard openCount > closeCount else { return false }
        guard location < text.length else { return false }
        let nextChar = text.substring(with: NSRange(location: location, length: 1))
        return nextChar == "}"
    }

    func indentSelection(in textView: NSTextView) {
        let selection = textView.selectedRange()
        if selection.length == 0 {
            insertText(indentUnit, in: textView, at: selection)
            return
        }

        let nsText = textView.string as NSString
        let lineRange = nsText.lineRange(for: selection)
        let selectedText = nsText.substring(with: lineRange)
        let lines = selectedText.components(separatedBy: "\n")
        let indented = lines.map { indentUnit + $0 }.joined(separator: "\n")
        textView.textStorage?.replaceCharacters(in: lineRange, with: indented)
        textView.setSelectedRange(NSRange(location: lineRange.location, length: (indented as NSString).length))
    }

    func outdentSelection(in textView: NSTextView) {
        let selection = textView.selectedRange()
        if selection.length == 0 {
            _ = handleBackspace(in: textView)
            return
        }

        let nsText = textView.string as NSString
        let lineRange = nsText.lineRange(for: selection)
        let selectedText = nsText.substring(with: lineRange)
        let lines = selectedText.components(separatedBy: "\n")

        let outdented = lines.map { line -> String in
            if line.hasPrefix(indentUnit) {
                return String(line.dropFirst(indentUnit.count))
            }
            if line.hasPrefix("\t") {
                return String(line.dropFirst())
            }
            let leadingSpaces = line.prefix { $0 == " " }.count
            if leadingSpaces > 0 {
                let remove = min(leadingSpaces, indentUnit.count)
                return String(line.dropFirst(remove))
            }
            return line
        }.joined(separator: "\n")

        textView.textStorage?.replaceCharacters(in: lineRange, with: outdented)
        let newLength = max(0, (outdented as NSString).length)
        textView.setSelectedRange(NSRange(location: lineRange.location, length: newLength))
    }

    func handleBackspace(in textView: NSTextView) -> Bool {
        let selection = textView.selectedRange()
        guard selection.length == 0 else { return false }

        let nsText = textView.string as NSString
        let lineStart = nsText.lineRange(for: NSRange(location: selection.location, length: 0)).location
        let prefixLength = selection.location - lineStart
        guard prefixLength > 0 else { return false }

        let prefixRange = NSRange(location: lineStart, length: prefixLength)
        let prefixText = nsText.substring(with: prefixRange)
        guard prefixText.trimmingCharacters(in: .whitespaces).isEmpty else { return false }

        let removeCount = min(indentUnit.count, prefixLength)
        let removeRange = NSRange(location: selection.location - removeCount, length: removeCount)
        textView.textStorage?.replaceCharacters(in: removeRange, with: "")
        textView.setSelectedRange(NSRange(location: selection.location - removeCount, length: 0))
        return true
    }
}
#endif
