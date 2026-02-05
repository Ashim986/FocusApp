import AppKit
import SwiftUI

extension CodeEditorView.Coordinator {
    func applySyntaxHighlighting() {
        guard let textView = textView,
              let textStorage = textView.textStorage else { return }

        let text = textView.string
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        let selectedRange = textView.selectedRange()

        textStorage.beginEditing()

        let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textStorage.setAttributes([
            .font: font,
            .foregroundColor: colors.default
        ], range: fullRange)

        switch language {
        case .swift:
            highlightSwift(textStorage: textStorage, text: text)
        case .python:
            highlightPython(textStorage: textStorage, text: text)
        }

        textStorage.endEditing()

        if selectedRange.location <= (text as NSString).length {
            textView.setSelectedRange(selectedRange)
        }

        applyErrorHighlights()
    }

    func applyErrorHighlights() {
        guard let textView = textView,
              let textStorage = textView.textStorage else { return }
        let text = textView.string as NSString
        let fullRange = NSRange(location: 0, length: text.length)
        textStorage.removeAttribute(.backgroundColor, range: fullRange)
        textStorage.removeAttribute(.underlineStyle, range: fullRange)
        textStorage.removeAttribute(.underlineColor, range: fullRange)

        var lineNumber = 1
        var index = 0
        var lineRanges: [Int: NSRange] = [:]
        while index < text.length {
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))
            lineRanges[lineNumber] = lineRange
            index = NSMaxRange(lineRange)
            lineNumber += 1
        }

        if let executionLine, let lineRange = lineRanges[executionLine] {
            textStorage.addAttribute(
                .backgroundColor,
                value: colors.executionHighlight,
                range: lineRange
            )
        }

        guard !diagnostics.isEmpty else { return }

        let underlineColor = NSColor(Color.appRed)
        let lineBackground = NSColor(Color.appRed).withAlphaComponent(0.12)

        for diagnostic in diagnostics {
            guard let lineRange = lineRanges[diagnostic.line] else { continue }
            textStorage.addAttribute(.backgroundColor, value: lineBackground, range: lineRange)
            if let underlineRange = underlineRange(for: diagnostic, in: text, lineRange: lineRange) {
                textStorage.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: underlineRange
                )
                textStorage.addAttribute(.underlineColor, value: underlineColor, range: underlineRange)
            }
        }
    }

    private func underlineRange(
        for diagnostic: CodeEditorDiagnostic,
        in text: NSString,
        lineRange: NSRange
    ) -> NSRange? {
        guard lineRange.length > 0 else { return nil }
        guard let column = diagnostic.column, column > 0 else {
            return lineRange
        }

        let clampedColumn = min(column, max(1, lineRange.length))
        let columnOffset = clampedColumn - 1
        let start = lineRange.location + columnOffset
        let maxLength = max(1, lineRange.length - columnOffset)

        let lineString = text.substring(with: lineRange) as NSString
        let safeOffset = min(columnOffset, max(0, lineString.length - 1))
        let remaining = lineString.substring(from: safeOffset)

        if let match = try? NSRegularExpression(pattern: "^[A-Za-z0-9_]+", options: []),
           let first = match.firstMatch(
            in: remaining,
            options: [],
            range: NSRange(location: 0, length: (remaining as NSString).length)
           ) {
            let length = min(first.range.length, maxLength)
            return NSRange(location: start, length: max(1, length))
        }

        return NSRange(location: start, length: max(1, min(1, maxLength)))
    }

}
