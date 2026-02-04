import AppKit

extension CodeEditorView.Coordinator {
    func insertMatchingBracket(opening: Character, closing: Character, in textView: NSTextView, at range: NSRange) {
        isInsertingMatchingBracket = true
        let insertString = String(opening) + String(closing)
        insertText(insertString, in: textView, at: range)
        textView.setSelectedRange(NSRange(location: range.location + 1, length: 0))
        isInsertingMatchingBracket = false
    }

    func insertText(_ text: String, in textView: NSTextView, at range: NSRange) {
        isInsertingMatchingBracket = true
        textView.insertText(text, replacementRange: range)
        isInsertingMatchingBracket = false
    }

    func wrapSelection(opening: Character, closing: Character, in textView: NSTextView, at range: NSRange) {
        let selectedText = (textView.string as NSString).substring(with: range)
        let wrapped = String(opening) + selectedText + String(closing)
        insertText(wrapped, in: textView, at: range)
        textView.setSelectedRange(NSRange(location: range.location + 1, length: selectedText.count))
    }

    func shouldAlignClosingBracket(_ char: Character, in textView: NSTextView, at range: NSRange) -> Bool {
        guard char == "}" || char == ")" || char == "]" else { return false }

        let nsText = textView.string as NSString
        let lineStart = nsText.lineRange(for: NSRange(location: range.location, length: 0)).location
        let linePrefixRange = NSRange(location: lineStart, length: range.location - lineStart)
        let linePrefix = nsText.substring(with: linePrefixRange)

        guard linePrefix.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard let targetIndent = indentationForMatchingBracket(char, in: textView.string, upTo: range.location) else {
            return false
        }

        let replacement = targetIndent + String(char)
        let replaceRange = NSRange(location: lineStart, length: range.location - lineStart)
        insertText(replacement, in: textView, at: replaceRange)
        textView.setSelectedRange(NSRange(location: lineStart + targetIndent.count + 1, length: 0))
        return true
    }

    private func indentationForMatchingBracket(_ closing: Character, in text: String, upTo location: Int) -> String? {
        let nsText = text as NSString
        guard location <= nsText.length else { return nil }

        let opening = matchingOpeningBracket(for: closing)
        var stack: [Character] = []
        var positions: [Int] = []

        var inString: Character?
        var inLineComment = false
        var inBlockComment = false

        var i = 0
        while i < location {
            let ch = Character(UnicodeScalar(nsText.character(at: i))!)
            let next: Character? = i + 1 < location ? Character(UnicodeScalar(nsText.character(at: i + 1))!) : nil

            if inLineComment {
                if ch == "\n" { inLineComment = false }
                i += 1
                continue
            }

            if inBlockComment {
                if ch == "*" && next == "/" {
                    inBlockComment = false
                    i += 2
                    continue
                }
                i += 1
                continue
            }

            if let stringDelimiter = inString {
                if ch == "\\" {
                    i += 2
                    continue
                }
                if ch == stringDelimiter {
                    inString = nil
                }
                i += 1
                continue
            }

            if ch == "/" && next == "/" {
                inLineComment = true
                i += 2
                continue
            }

            if ch == "/" && next == "*" {
                inBlockComment = true
                i += 2
                continue
            }

            if ch == "\"" || ch == "'" {
                inString = ch
                i += 1
                continue
            }

            if openingBrackets.contains(ch) {
                stack.append(ch)
                positions.append(i)
            } else if closingBrackets.contains(ch) {
                if let last = stack.last, matchingClosingBracket(for: last) == ch {
                    _ = stack.popLast()
                    _ = positions.popLast()
                }
            }

            i += 1
        }

        guard let matchIndex = stack.lastIndex(of: opening) else { return nil }
        let openingPosition = positions[matchIndex]
        let lineStart = nsText.lineRange(for: NSRange(location: openingPosition, length: 0)).location
        let linePrefix = nsText.substring(with: NSRange(location: lineStart, length: openingPosition - lineStart))
        let whitespacePrefix = String(linePrefix.prefix { $0 == " " || $0 == "\t" })
        return whitespacePrefix.replacingOccurrences(of: "\t", with: indentUnit)
    }

    private func matchingOpeningBracket(for closing: Character) -> Character {
        switch closing {
        case "}": return "{"
        case ")": return "("
        case "]": return "["
        case ">": return "<"
        default: return closing
        }
    }

    private func matchingClosingBracket(for opening: Character) -> Character {
        switch opening {
        case "{": return "}"
        case "(": return ")"
        case "[": return "]"
        case "<": return ">"
        default: return opening
        }
    }
}
