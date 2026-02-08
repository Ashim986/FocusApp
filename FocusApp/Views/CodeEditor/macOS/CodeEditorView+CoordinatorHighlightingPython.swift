#if os(macOS)
import AppKit
import SwiftUI

extension CodeEditorView.Coordinator {
    func highlightPython(textStorage: NSTextStorage, text: String) {
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
#endif
