import AppKit
import SwiftUI

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

    // swiftlint:disable cyclomatic_complexity
    private func indentationForMatchingBracket(_ closing: Character, in text: String, upTo location: Int) -> String? {
        let nsText = text as NSString
        guard location <= nsText.length else { return nil }

        let opening = matchingOpeningBracket(for: closing)
        var stack: [Character] = []
        var positions: [Int] = []

        var inString: Character?
        var inLineComment = false
        var inBlockComment = false

        func scalarCharacter(at index: Int) -> Character? {
            guard index < nsText.length else { return nil }
            let codeUnit = nsText.character(at: index)
            guard let scalar = UnicodeScalar(codeUnit) else { return nil }
            return Character(scalar)
        }

        var index = 0
        while index < location {
            guard let ch = scalarCharacter(at: index) else {
                index += 1
                continue
            }
            let next: Character? = index + 1 < location ? scalarCharacter(at: index + 1) : nil

            if inLineComment {
                if ch == "\n" { inLineComment = false }
                index += 1
                continue
            }

            if inBlockComment {
                if ch == "*" && next == "/" {
                    inBlockComment = false
                    index += 2
                    continue
                }
                index += 1
                continue
            }

            if let stringDelimiter = inString {
                if ch == "\\" {
                    index += 2
                    continue
                }
                if ch == stringDelimiter {
                    inString = nil
                }
                index += 1
                continue
            }

            if ch == "/" && next == "/" {
                inLineComment = true
                index += 2
                continue
            }

            if ch == "/" && next == "*" {
                inBlockComment = true
                index += 2
                continue
            }

            if ch == "\"" || ch == "'" {
                inString = ch
                index += 1
                continue
            }

            if openingBrackets.contains(ch) {
                stack.append(ch)
                positions.append(index)
            } else if closingBrackets.contains(ch) {
                if let last = stack.last, matchingClosingBracket(for: last) == ch {
                    _ = stack.popLast()
                    _ = positions.popLast()
                }
            }

            index += 1
        }

        guard let matchIndex = stack.lastIndex(of: opening) else { return nil }
        let openingPosition = positions[matchIndex]
        let lineStart = nsText.lineRange(for: NSRange(location: openingPosition, length: 0)).location
        let linePrefix = nsText.substring(with: NSRange(location: lineStart, length: openingPosition - lineStart))
        return leadingIndentation(in: linePrefix)
    }
    // swiftlint:enable cyclomatic_complexity

    private func matchingOpeningBracket(for closing: Character) -> Character {
        switch closing {
        case "}": return "{"
        case ")": return "("
        case "]": return "["
        default: return closing
        }
    }

    private func matchingClosingBracket(for opening: Character) -> Character {
        switch opening {
        case "{": return "}"
        case "(": return ")"
        case "[": return "]"
        default: return opening
        }
    }

    func updateBracketHighlights(in textView: NSTextView) {
        clearBracketHighlights(in: textView)
        guard let match = bracketMatch(in: textView) else { return }

        let ranges = [
            NSRange(location: match.open, length: 1),
            NSRange(location: match.close, length: 1)
        ]
        applyBracketHighlights(ranges, in: textView)
    }

    private func bracketMatch(in textView: NSTextView) -> (open: Int, close: Int)? {
        let nsText = textView.string as NSString
        let length = nsText.length
        let selection = textView.selectedRange()

        if selection.length > 0 {
            let before = selection.location - 1
            let after = selection.location + selection.length
            if before >= 0, after < length,
               let openChar = character(at: before, in: nsText),
               let closeChar = character(at: after, in: nsText),
               structuralOpeningBrackets.contains(openChar),
               structuralClosingBrackets.contains(closeChar),
               matchingClosingBracket(for: openChar) == closeChar {
                return (open: before, close: after)
            }
        }

        let caret = selection.location
        let candidateIndices = [caret, caret - 1].filter { $0 >= 0 && $0 < length }
        for index in candidateIndices {
            guard let bracket = character(at: index, in: nsText) else { continue }
            if structuralOpeningBrackets.contains(bracket) {
                if let closeIndex = matchClosingBracket(
                    from: index,
                    opening: bracket,
                    closing: matchingClosingBracket(for: bracket),
                    in: nsText
                ) {
                    return (open: index, close: closeIndex)
                }
            } else if structuralClosingBrackets.contains(bracket) {
                if let openIndex = matchOpeningBracket(
                    for: bracket,
                    upTo: index,
                    in: nsText
                ) {
                    return (open: openIndex, close: index)
                }
            }
        }

        return nil
    }

    private var structuralOpeningBrackets: Set<Character> {
        ["{", "(", "["]
    }

    private var structuralClosingBrackets: Set<Character> {
        ["}", ")", "]"]
    }

    private func character(at index: Int, in text: NSString) -> Character? {
        guard index >= 0, index < text.length else { return nil }
        let codeUnit = text.character(at: index)
        guard let scalar = UnicodeScalar(codeUnit) else { return nil }
        return Character(scalar)
    }

    // swiftlint:disable cyclomatic_complexity
    private func matchClosingBracket(
        from index: Int,
        opening: Character,
        closing: Character,
        in text: NSString
    ) -> Int? {
        var depth = 0
        var inString: Character?
        var inLineComment = false
        var inBlockComment = false
        var scanIndex = index + 1

        while scanIndex < text.length {
            guard let ch = character(at: scanIndex, in: text) else {
                scanIndex += 1
                continue
            }
            let next = character(at: scanIndex + 1, in: text)

            if inLineComment {
                if ch == "\n" { inLineComment = false }
                scanIndex += 1
                continue
            }

            if inBlockComment {
                if ch == "*" && next == "/" {
                    inBlockComment = false
                    scanIndex += 2
                    continue
                }
                scanIndex += 1
                continue
            }

            if let stringDelimiter = inString {
                if ch == "\\" {
                    scanIndex += 2
                    continue
                }
                if ch == stringDelimiter {
                    inString = nil
                }
                scanIndex += 1
                continue
            }

            if ch == "/" && next == "/" {
                inLineComment = true
                scanIndex += 2
                continue
            }

            if ch == "/" && next == "*" {
                inBlockComment = true
                scanIndex += 2
                continue
            }

            if ch == "\"" || ch == "'" {
                inString = ch
                scanIndex += 1
                continue
            }

            if ch == opening {
                depth += 1
            } else if ch == closing {
                if depth == 0 {
                    return scanIndex
                }
                depth -= 1
            }
            scanIndex += 1
        }
        return nil
    }

    private func matchOpeningBracket(
        for closing: Character,
        upTo location: Int,
        in text: NSString
    ) -> Int? {
        let opening = matchingOpeningBracket(for: closing)
        var stack: [Character] = []
        var positions: [Int] = []

        var inString: Character?
        var inLineComment = false
        var inBlockComment = false
        var index = 0

        while index <= location, index < text.length {
            guard let ch = character(at: index, in: text) else {
                index += 1
                continue
            }
            let next = character(at: index + 1, in: text)

            if inLineComment {
                if ch == "\n" { inLineComment = false }
                index += 1
                continue
            }

            if inBlockComment {
                if ch == "*" && next == "/" {
                    inBlockComment = false
                    index += 2
                    continue
                }
                index += 1
                continue
            }

            if let stringDelimiter = inString {
                if ch == "\\" {
                    index += 2
                    continue
                }
                if ch == stringDelimiter {
                    inString = nil
                }
                index += 1
                continue
            }

            if ch == "/" && next == "/" {
                inLineComment = true
                index += 2
                continue
            }

            if ch == "/" && next == "*" {
                inBlockComment = true
                index += 2
                continue
            }

            if ch == "\"" || ch == "'" {
                inString = ch
                index += 1
                continue
            }

            if structuralOpeningBrackets.contains(ch) {
                stack.append(ch)
                positions.append(index)
            } else if structuralClosingBrackets.contains(ch) {
                if let last = stack.last, matchingClosingBracket(for: last) == ch {
                    if index == location, ch == closing {
                        return positions.last
                    }
                    _ = stack.popLast()
                    _ = positions.popLast()
                }
            }

            index += 1
        }

        guard let matchIndex = stack.lastIndex(of: opening) else { return nil }
        return positions[matchIndex]
    }
    // swiftlint:enable cyclomatic_complexity

    private func applyBracketHighlights(_ ranges: [NSRange], in textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        let highlightColor = editorColors.execution.withAlphaComponent(0.25)
        let underlineColor = editorColors.execution
        for range in ranges {
            textStorage.addAttribute(.backgroundColor, value: highlightColor, range: range)
            textStorage.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
            textStorage.addAttribute(.underlineColor, value: underlineColor, range: range)
        }
        bracketHighlightRanges = ranges
    }

    private func clearBracketHighlights(in textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        for range in bracketHighlightRanges {
            textStorage.removeAttribute(.backgroundColor, range: range)
            textStorage.removeAttribute(.underlineStyle, range: range)
            textStorage.removeAttribute(.underlineColor, range: range)
        }
        bracketHighlightRanges = []
    }

    func handleBracketDoubleClick(at point: NSPoint, in textView: NSTextView) -> Bool {
        guard let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return false }
        let index = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        let nsText = textView.string as NSString
        let length = nsText.length
        guard length > 0 else { return false }

        let candidateIndices = [index, index - 1].filter { $0 >= 0 && $0 < length }
        for candidate in candidateIndices {
            guard let bracket = character(at: candidate, in: nsText) else { continue }
            if structuralOpeningBrackets.contains(bracket),
               let closeIndex = matchClosingBracket(
                    from: candidate,
                    opening: bracket,
                    closing: matchingClosingBracket(for: bracket),
                    in: nsText
               ) {
                let start = candidate + 1
                let length = max(0, closeIndex - start)
                textView.setSelectedRange(NSRange(location: start, length: length))
                updateBracketHighlights(in: textView)
                return true
            }
            if structuralClosingBrackets.contains(bracket),
               let openIndex = matchOpeningBracket(for: bracket, upTo: candidate, in: nsText) {
                let start = openIndex + 1
                let length = max(0, candidate - start)
                textView.setSelectedRange(NSRange(location: start, length: length))
                updateBracketHighlights(in: textView)
                return true
            }
        }
        return false
    }
}
