import AppKit

extension CodeEditorView.Coordinator {
    func handleNewLine(textView: NSTextView, range: NSRange, text: String) {
        let nsText = text as NSString
        let lineStart = nsText.lineRange(for: NSRange(location: range.location, length: 0)).location
        let lineUpToCursor = nsText.substring(with: NSRange(location: lineStart, length: range.location - lineStart))

        var indentation = ""
        for char in lineUpToCursor {
            if char == " " {
                indentation += " "
            } else if char == "\t" {
                indentation += indentUnit
            } else {
                break
            }
        }

        let trimmedLine = lineUpToCursor.trimmingCharacters(in: .whitespaces)
        var shouldIncreaseIndent = false
        var shouldAddClosingBrace = false

        if trimmedLine.hasSuffix("{") || trimmedLine.hasSuffix("(") || trimmedLine.hasSuffix("[") {
            shouldIncreaseIndent = true
        }

        if trimmedLine.hasSuffix("{") {
            let openCount = trimmedLine.filter { $0 == "{" }.count
            let closeCount = trimmedLine.filter { $0 == "}" }.count
            if openCount > closeCount {
                if range.location < nsText.length {
                    let nextChar = nsText.substring(with: NSRange(location: range.location, length: 1))
                    if nextChar == "}" {
                        shouldAddClosingBrace = true
                    }
                }
            }
        } else if language == .python && (trimmedLine.hasSuffix(":") || trimmedLine.hasSuffix("(") || trimmedLine.hasSuffix("[")) {
            shouldIncreaseIndent = true
        }

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
