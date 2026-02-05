import AppKit
import SwiftUI

extension CodeEditorView.Coordinator {
    func highlightSwift(textStorage: NSTextStorage, text: String) {
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

    private func highlightSwiftDeclarations(in textStorage: NSTextStorage, text: String) {
        highlightPattern(
            "\\b(func|let|var|class|struct|enum|protocol|actor|extension|typealias|associatedtype)\\b",
            in: textStorage,
            text: text,
            color: colors.keyword
        )
        highlightPattern("(?<=\\bclass\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\bstruct\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\benum\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\bprotocol\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\bactor\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\bextension\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\btypealias\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\bassociatedtype\\s)\\w+", in: textStorage, text: text, color: colors.type)
        highlightPattern("(?<=\\blet\\s)\\w+", in: textStorage, text: text, color: colors.variable)
        highlightPattern("(?<=\\bvar\\s)\\w+", in: textStorage, text: text, color: colors.variable)
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
}
