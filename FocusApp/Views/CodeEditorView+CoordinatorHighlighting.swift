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

    private func highlightSwift(textStorage: NSTextStorage, text: String) {
        let keywords = [
            "func", "var", "let", "if", "else", "for", "while", "return",
            "import", "struct", "class", "enum", "case", "switch", "guard",
            "defer", "true", "false", "nil", "self", "Self", "init", "deinit",
            "static", "private", "public", "internal", "fileprivate", "open",
            "override", "mutating", "throws", "throw", "try", "catch", "async",
            "await", "in", "where", "extension", "protocol", "typealias",
            "associatedtype", "inout", "break", "continue", "fallthrough",
            "default", "do", "repeat", "is", "as", "super", "convenience",
            "required", "final", "lazy", "weak", "unowned", "optional", "some", "any"
        ]

        let types = [
            "String", "Int", "Double", "Float", "Bool", "Array", "Dictionary",
            "Set", "Optional", "Any", "AnyObject", "Void", "Never", "Error",
            "Result", "UUID", "Data", "Date", "URL", "Character", "Substring",
            "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32",
            "UInt64",
            "CGFloat", "CGPoint", "CGSize", "CGRect", "NSRange"
        ]

        let keywordSet = Set(keywords)
        let typeSet = Set(types)

        highlightKeywords(keywords, in: textStorage, text: text, color: colors.keyword)
        highlightKeywords(types, in: textStorage, text: text, color: colors.type)
        highlightSwiftTypeAnnotations(
            in: textStorage,
            text: text,
            keywords: keywordSet,
            builtinTypes: typeSet
        )
        highlightSwiftDeclarations(in: textStorage, text: text)
        highlightFunctions(in: textStorage, text: text)
        highlightStrings(
            pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"",
            in: textStorage,
            text: text
        )
        highlightMultilineStrings(in: textStorage, text: text)
        highlightNumbers(in: textStorage, text: text)
        highlightComments(patterns: ["//.*$", "/\\*[\\s\\S]*?\\*/"], in: textStorage, text: text)
    }

    private func highlightPython(textStorage: NSTextStorage, text: String) {
        let keywords = [
            "def", "class", "if", "elif", "else", "for", "while", "return",
            "import", "from", "as", "try", "except", "finally", "raise", "with",
            "pass", "break", "continue", "True", "False", "None", "and", "or",
            "not", "in", "is", "lambda", "global", "nonlocal", "yield", "async",
            "await", "assert", "del", "print", "self", "super"
        ]

        let types = [
            "str", "int", "float", "bool", "list", "dict", "set", "tuple",
            "None", "type", "object", "Exception", "List", "Dict", "Set",
            "Tuple", "Optional", "Union", "Any", "Callable", "Iterator",
            "Iterable", "Generator", "Sequence", "Mapping"
        ]

        highlightKeywords(keywords, in: textStorage, text: text, color: colors.keyword)
        highlightKeywords(types, in: textStorage, text: text, color: colors.type)
        highlightPythonDeclarations(in: textStorage, text: text)
        highlightPythonFunctions(in: textStorage, text: text)
        highlightStrings(
            pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'",
            in: textStorage,
            text: text
        )
        highlightPythonMultilineStrings(in: textStorage, text: text)
        highlightNumbers(in: textStorage, text: text)
        highlightComments(patterns: ["#.*$"], in: textStorage, text: text)
        highlightDecorators(in: textStorage, text: text)
    }

    private func highlightKeywords(_ keywords: [String], in textStorage: NSTextStorage, text: String, color: NSColor) {
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            highlightPattern(pattern, in: textStorage, text: text, color: color)
        }
    }

    private func highlightPattern(
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

    private func highlightFunctions(in textStorage: NSTextStorage, text: String) {
        let funcPattern = "(?<=func\\s)\\w+"
        highlightPattern(funcPattern, in: textStorage, text: text, color: colors.function)

        let callPattern = "\\b([a-zA-Z_][a-zA-Z0-9_]*)(?=\\s*\\()"
        if let regex = try? NSRegularExpression(pattern: callPattern, options: []) {
            let range = NSRange(location: 0, length: (text as NSString).length)
            let matches = regex.matches(in: text, options: [], range: range)
            for match in matches where match.numberOfRanges > 1 {
                textStorage.addAttribute(.foregroundColor, value: colors.function, range: match.range(at: 1))
            }
        }
    }

    private func highlightPythonFunctions(in textStorage: NSTextStorage, text: String) {
        let defPattern = "(?<=def\\s)\\w+"
        highlightPattern(defPattern, in: textStorage, text: text, color: colors.function)

        let callPattern = "\\b([a-zA-Z_][a-zA-Z0-9_]*)(?=\\s*\\()"
        if let regex = try? NSRegularExpression(pattern: callPattern, options: []) {
            let range = NSRange(location: 0, length: (text as NSString).length)
            let matches = regex.matches(in: text, options: [], range: range)
            for match in matches where match.numberOfRanges > 1 {
                textStorage.addAttribute(.foregroundColor, value: colors.function, range: match.range(at: 1))
            }
        }
    }

    private func highlightStrings(pattern: String, in textStorage: NSTextStorage, text: String) {
        highlightPattern(pattern, in: textStorage, text: text, color: colors.string, options: [])
    }

    private func highlightMultilineStrings(in textStorage: NSTextStorage, text: String) {
        let pattern = "\"\"\"|[\\s\\S]*?\"\"\""
        highlightPattern(
            pattern,
            in: textStorage,
            text: text,
            color: colors.string,
            options: [.dotMatchesLineSeparators]
        )
    }

    private func highlightPythonMultilineStrings(in textStorage: NSTextStorage, text: String) {
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

    private func highlightNumbers(in textStorage: NSTextStorage, text: String) {
        let pattern = "\\b(0x[0-9a-fA-F]+|0b[01]+|0o[0-7]+|\\d+\\.\\d+|\\d+)\\b"
        highlightPattern(pattern, in: textStorage, text: text, color: colors.number)
    }

    private func highlightComments(patterns: [String], in textStorage: NSTextStorage, text: String) {
        for pattern in patterns {
            highlightPattern(pattern, in: textStorage, text: text, color: colors.comment, options: [.anchorsMatchLines])
        }
    }

    private func highlightSwiftDeclarations(in textStorage: NSTextStorage, text: String) {
        highlightPattern(
            "\\b(func|let|var|class|struct|enum|protocol|actor|extension|typealias|associatedtype)\\b",
            in: textStorage,
            text: text,
            color: colors.declaration
        )
        highlightPattern("(?<=\\bclass\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bstruct\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\benum\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bprotocol\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bactor\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bextension\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\btypealias\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bassociatedtype\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\blet\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bvar\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
    }

    private func highlightSwiftTypeAnnotations(
        in textStorage: NSTextStorage,
        text: String,
        keywords: Set<String>,
        builtinTypes: Set<String>
    ) {
        let patterns: [(pattern: String, group: Int)] = [
            ("\\b(let|var)\\s+\\w+\\s*:\\s*([^=\\n]+)", 2),
            ("\\bfunc\\s+\\w+\\s*\\(([^\\)]*)\\)", 1),
            ("->\\s*([^\\{\\n]+)", 1),
            ("\\btypealias\\s+\\w+\\s*=\\s*([^\\n]+)", 1)
        ]

        for entry in patterns {
            guard let regex = try? NSRegularExpression(pattern: entry.pattern, options: []) else { continue }
            let range = NSRange(location: 0, length: (text as NSString).length)
            let matches = regex.matches(in: text, options: [], range: range)
            for match in matches {
                guard match.numberOfRanges > entry.group else { continue }
                let typeRange = match.range(at: entry.group)
                guard typeRange.length > 0 else { continue }
                highlightTypeIdentifiers(
                    in: textStorage,
                    text: text,
                    range: typeRange,
                    keywords: keywords,
                    builtinTypes: builtinTypes
                )
            }
        }
    }

    private func highlightTypeIdentifiers(
        in textStorage: NSTextStorage,
        text: String,
        range: NSRange,
        keywords: Set<String>,
        builtinTypes: Set<String>
    ) {
        guard let regex = try? NSRegularExpression(pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b", options: []) else {
            return
        }

        let substring = (text as NSString).substring(with: range)
        let matches = regex.matches(
            in: substring,
            options: [],
            range: NSRange(location: 0, length: (substring as NSString).length)
        )

        for match in matches {
            let token = (substring as NSString).substring(with: match.range)
            if keywords.contains(token) { continue }

            let isBuiltin = builtinTypes.contains(token)
            let isUppercase = token.unicodeScalars.first?.properties.isUppercase == true
            if token == "Self" || isBuiltin || isUppercase {
                let globalRange = NSRange(location: range.location + match.range.location, length: match.range.length)
                textStorage.addAttribute(.foregroundColor, value: colors.type, range: globalRange)
            }
        }
    }

    private func highlightPythonDeclarations(in textStorage: NSTextStorage, text: String) {
        highlightPattern("\\b(def|class)\\b", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bdef\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
        highlightPattern("(?<=\\bclass\\s)\\w+", in: textStorage, text: text, color: colors.declaration)
    }

    private func highlightDecorators(in textStorage: NSTextStorage, text: String) {
        let pattern = "@\\w+"
        highlightPattern(pattern, in: textStorage, text: text, color: colors.function)
    }
}
