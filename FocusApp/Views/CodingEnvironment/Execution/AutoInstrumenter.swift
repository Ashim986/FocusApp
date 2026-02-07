import Foundation

/// Source-level auto-instrumentation that inserts `Trace.step()` / `_Trace.step()`
/// calls into user code at loop bodies and recursive function entries.
///
/// This provides trace data automatically without requiring the user to manually
/// call `Trace.step()`. It is disabled (returns code unchanged) when the user
/// has already written any manual `Trace.step` or `_Trace.step` calls.
enum AutoInstrumenter {

    // MARK: - Public API

    /// Instruments user code by inserting trace calls at loop bodies
    /// and recursive function entries.
    ///
    /// - Parameters:
    ///   - code: The user's source code.
    ///   - language: The programming language (`.swift` or `.python`).
    ///   - paramNames: Parameter names from the LeetCode metadata (for capture).
    /// - Returns: The instrumented code, or the original if instrumentation
    ///            is not applicable (e.g., user already has trace calls).
    static func instrument(
        code: String,
        language: ProgrammingLanguage,
        paramNames: [String]
    ) -> String {
        switch language {
        case .swift:
            return instrumentSwift(code: code, paramNames: paramNames)
        case .python:
            return instrumentPython(code: code, paramNames: paramNames)
        }
    }

    // MARK: - Opt-out Detection

    /// Returns true if the code already contains manual trace calls.
    static func hasManualTrace(code: String, language: ProgrammingLanguage) -> Bool {
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        switch language {
        case .swift:
            return stripped.contains("Trace.step")
        case .python:
            return stripped.contains("_Trace.step")
        }
    }

    // MARK: - Common Variables

    /// Common variable names to capture in trace steps.
    private static let commonSwiftVars = [
        "result", "ans", "res", "output",
        "i", "j", "k", "idx", "index",
        "left", "right", "mid", "lo", "hi",
        "curr", "prev", "node", "head", "tail", "root",
        "stack", "queue", "count", "sum", "total",
        "dp", "memo", "visited", "seen",
        "temp", "val", "key", "num"
    ]

    private static let commonPythonVars = [
        "result", "ans", "res", "output",
        "i", "j", "k", "idx", "index",
        "left", "right", "mid", "lo", "hi",
        "curr", "prev", "node", "head", "tail", "root",
        "stack", "queue", "count", "total",
        "dp", "memo", "visited", "seen",
        "temp", "val", "key", "num"
    ]

    // MARK: - Swift Instrumentation

    private static func instrumentSwift(
        code: String,
        paramNames: [String]
    ) -> String {
        guard !hasManualTrace(code: code, language: .swift) else { return code }

        let lines = code.components(separatedBy: "\n")
        var result: [String] = []
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        let isRecursive = detectSwiftRecursion(stripped: stripped)
        var didInstrumentRecursion = false

        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex]
            result.append(line)

            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Detect loop openings: for...{, while...{, repeat {
            if isSwiftLoopOpening(trimmed: trimmed, stripped: stripped, line: line) {
                let indent = leadingWhitespace(line) + "    "
                let captureDict = swiftCaptureExpression(
                    paramNames: paramNames,
                    lineIndex: lineIndex,
                    stripped: stripped
                )
                result.append("\(indent)Trace.step(\"loop\", \(captureDict))")
            }

            // Detect recursive function entry: func <methodName>(...) {
            if isRecursive && !didInstrumentRecursion
                && isSwiftFuncOpening(trimmed: trimmed) {
                let indent = leadingWhitespace(line) + "    "
                let captureDict = swiftCaptureExpression(
                    paramNames: paramNames,
                    lineIndex: lineIndex,
                    stripped: stripped
                )
                result.append("\(indent)Trace.step(\"recurse\", \(captureDict))")
                didInstrumentRecursion = true
            }
        }

        return result.joined(separator: "\n")
    }

    private static func isSwiftLoopOpening(
        trimmed: String,
        stripped: String,
        line: String
    ) -> Bool {
        let loopPatterns = [
            "^for\\s+.*\\{\\s*$",
            "^while\\s+.*\\{\\s*$",
            "^repeat\\s*\\{\\s*$"
        ]
        for pattern in loopPatterns where trimmed.range(of: pattern, options: .regularExpression) != nil {
            return true
        }
        return false
    }

    private static func isSwiftFuncOpening(trimmed: String) -> Bool {
        let pattern = "^(func|private\\s+func|static\\s+func)\\s+\\w+.*\\{\\s*$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private static func detectSwiftRecursion(stripped: String) -> Bool {
        // Extract method name from Solution class
        let funcPattern = "func\\s+(\\w+)\\s*\\("
        guard let regex = try? NSRegularExpression(pattern: funcPattern),
              let match = regex.firstMatch(
                in: stripped,
                range: NSRange(stripped.startIndex..., in: stripped)
              ),
              let nameRange = Range(match.range(at: 1), in: stripped) else {
            return false
        }
        let methodName = String(stripped[nameRange])
        // Check if the method name appears more than once (call site)
        let callPattern = "\\b\(NSRegularExpression.escapedPattern(for: methodName))\\s*\\("
        guard let callRegex = try? NSRegularExpression(pattern: callPattern) else {
            return false
        }
        let matches = callRegex.numberOfMatches(
            in: stripped,
            range: NSRange(stripped.startIndex..., in: stripped)
        )
        return matches >= 2
    }

    private static func swiftCaptureExpression(
        paramNames: [String],
        lineIndex: Int,
        stripped: String
    ) -> String {
        let presentCommonVars = commonSwiftVars.filter { name in
            variableExistsInCode(name: name, stripped: stripped)
        }
        let allVars = (paramNames + presentCommonVars).uniqued()
        let pairs = allVars.prefix(12).map { name in
            "\"\(name)\": \(name) as Any"
        }
        return "[\(pairs.joined(separator: ", "))]"
    }

    // MARK: - Python Instrumentation

    private static func instrumentPython(
        code: String,
        paramNames: [String]
    ) -> String {
        guard !hasManualTrace(code: code, language: .python) else { return code }

        let lines = code.components(separatedBy: "\n")
        var result: [String] = []
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        let isRecursive = detectPythonRecursion(stripped: stripped)
        var didInstrumentRecursion = false

        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex]
            result.append(line)

            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Detect loop openings: for...:, while...:
            if isPythonLoopOpening(trimmed: trimmed) {
                let bodyIndent = leadingWhitespace(line) + "    "
                let captureDict = pythonCaptureExpression(
                    paramNames: paramNames,
                    stripped: stripped
                )
                // Insert a try/except around trace so variable
                // not-yet-defined errors don't crash the program
                let traceCall = "_Trace.step(\"loop\", \(captureDict))"
                result.append("\(bodyIndent)try: \(traceCall)")
                result.append("\(bodyIndent)except: pass")
            }

            // Detect recursive function def
            if isRecursive && !didInstrumentRecursion
                && isPythonDefOpening(trimmed: trimmed) {
                let bodyIndent = leadingWhitespace(line) + "    "
                let captureDict = pythonCaptureExpression(
                    paramNames: paramNames,
                    stripped: stripped
                )
                let traceCall = "_Trace.step(\"recurse\", \(captureDict))"
                result.append("\(bodyIndent)try: \(traceCall)")
                result.append("\(bodyIndent)except: pass")
                didInstrumentRecursion = true
            }
        }

        return result.joined(separator: "\n")
    }

    private static func isPythonLoopOpening(trimmed: String) -> Bool {
        let loopPatterns = [
            "^for\\s+.*:\\s*$",
            "^while\\s+.*:\\s*$"
        ]
        for pattern in loopPatterns where trimmed.range(of: pattern, options: .regularExpression) != nil {
            return true
        }
        return false
    }

    private static func isPythonDefOpening(trimmed: String) -> Bool {
        let pattern = "^def\\s+\\w+\\s*\\(.*\\).*:\\s*$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private static func detectPythonRecursion(stripped: String) -> Bool {
        let defPattern = "def\\s+(\\w+)\\s*\\("
        guard let regex = try? NSRegularExpression(pattern: defPattern),
              let match = regex.firstMatch(
                in: stripped,
                range: NSRange(stripped.startIndex..., in: stripped)
              ),
              let nameRange = Range(match.range(at: 1), in: stripped) else {
            return false
        }
        let methodName = String(stripped[nameRange])
        // Exclude __init__ and common non-recursive helpers
        let nonRecursive: Set<String> = ["__init__", "solve", "main"]
        if nonRecursive.contains(methodName) {
            // For "solve", still check — it's often recursive
            if methodName != "solve" { return false }
        }
        let callPattern = "\\b\(NSRegularExpression.escapedPattern(for: methodName))\\s*\\("
        guard let callRegex = try? NSRegularExpression(pattern: callPattern) else {
            return false
        }
        let matches = callRegex.numberOfMatches(
            in: stripped,
            range: NSRange(stripped.startIndex..., in: stripped)
        )
        return matches >= 2
    }

    private static func pythonCaptureExpression(
        paramNames: [String],
        stripped: String
    ) -> String {
        let presentCommonVars = commonPythonVars.filter { name in
            variableExistsInCode(name: name, stripped: stripped)
        }
        let allVars = (paramNames + presentCommonVars).uniqued()
        let pairs = allVars.prefix(12).map { name in
            "\"\(name)\": \(name)"
        }
        return "{\(pairs.joined(separator: ", "))}"
    }

    // MARK: - Helpers

    /// Checks whether a variable name appears as an identifier in the stripped
    /// code (comments and strings already removed). Uses a word-boundary regex
    /// so that e.g. "i" doesn't match inside "if" or "while".
    private static func variableExistsInCode(name: String, stripped: String) -> Bool {
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: name))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        return regex.firstMatch(
            in: stripped,
            range: NSRange(stripped.startIndex..., in: stripped)
        ) != nil
    }

    private static func leadingWhitespace(_ line: String) -> String {
        var spaces = ""
        for char in line {
            if char == " " || char == "\t" {
                spaces.append(char)
            } else {
                break
            }
        }
        return spaces
    }
}

// MARK: - Array Uniqued Extension

extension Array where Element: Hashable {
    fileprivate func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
