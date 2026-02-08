import Foundation

/// Source-level auto-instrumentation that inserts `Trace.step()` / `_Trace.step()`
/// calls into user code at loop bodies and recursive function entries.
///
/// This provides trace data automatically without requiring the user to manually
/// call `Trace.step()`. It is disabled (returns code unchanged) when the user
/// has already written any manual `Trace.step` or `_Trace.step` calls.
enum AutoInstrumenter { // swiftlint:disable:this type_body_length

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
        paramNames: [String],
        entryPointName: String? = nil
    ) -> String {
        switch language {
        case .swift:
            return instrumentSwift(code: code, entryPointName: entryPointName, paramNames: paramNames)
        case .python:
            return instrumentPython(code: code, entryPointName: entryPointName, paramNames: paramNames)
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
        "curr", "prev", "current", "next", "node", "head", "tail", "root", "dummy",
        "stack", "queue", "count", "sum", "total",
        "dp", "memo", "visited", "seen",
        "temp", "val", "key", "num",
        "fast", "slow", "first", "second", "pointer", "ptr"
    ]

    private static let commonPythonVars = [
        "result", "ans", "res", "output",
        "i", "j", "k", "idx", "index",
        "left", "right", "mid", "lo", "hi",
        "curr", "prev", "current", "next", "node", "head", "tail", "root", "dummy",
        "stack", "queue", "count", "total",
        "dp", "memo", "visited", "seen",
        "temp", "val", "key", "num",
        "fast", "slow", "first", "second", "pointer", "ptr"
    ]

    // MARK: - Swift Instrumentation

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func instrumentSwift(
        code: String,
        entryPointName: String?,
        paramNames: [String]
    ) -> String {
        let hasManualTraceCalls = hasManualTrace(code: code, language: .swift)

        let lines = code.components(separatedBy: "\n")
        var result: [String] = []
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        let strippedLines = stripped.components(separatedBy: "\n")
        let resolvedEntryPointName = entryPointName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entryPoint = (resolvedEntryPointName?.isEmpty == false)
            ? resolvedEntryPointName
            : detectSwiftEntryPointName(stripped: stripped)
        var entryParamNames = paramNames

        var braceDepth = 0
        var solutionDepth: Int?
        var isPendingSolutionOpen = false

        var entryDepth: Int?
        var isPendingEntryOpen = false
        var isInEntryPoint = false
        var entryFuncLevelDecls: [VarDecl] = []

        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let strippedLine = strippedLines.indices.contains(lineIndex) ? strippedLines[lineIndex] : line
            let strippedTrimmed = strippedLine.trimmingCharacters(in: .whitespaces)
            let braceDepthBefore = braceDepth
            let openBraces = countOccurrences(of: "{", in: strippedLine)
            let closeBraces = countOccurrences(of: "}", in: strippedLine)

            if solutionDepth == nil, isSwiftSolutionClassOpening(line: strippedTrimmed) {
                isPendingSolutionOpen = true
            }

            if isPendingSolutionOpen, solutionDepth == nil, openBraces > 0 {
                solutionDepth = braceDepthBefore + 1
                isPendingSolutionOpen = false
            }

            let isInSolution = solutionDepth.map { braceDepthBefore >= $0 } ?? false

            if isInSolution, entryDepth == nil, let entryPoint {
                if !isPendingEntryOpen, isSwiftEntryPointSignature(line: strippedTrimmed, name: entryPoint) {
                    let parsedParams = swiftParamNamesFromSignature(
                        strippedLines: strippedLines,
                        signatureStartLineIndex: lineIndex
                    )
                    if !parsedParams.isEmpty {
                        entryParamNames = parsedParams
                    }
                    if openBraces > 0 {
                        entryDepth = braceDepthBefore + 1
                        isInEntryPoint = true
                        entryFuncLevelDecls = []
                    } else {
                        isPendingEntryOpen = true
                    }
                } else if isPendingEntryOpen, openBraces > 0 {
                    entryDepth = braceDepthBefore + 1
                    isInEntryPoint = true
                    isPendingEntryOpen = false
                    entryFuncLevelDecls = []
                }
            }

            let visibleVars: [String]
            if isInEntryPoint, let entryDepth {
                if braceDepthBefore == entryDepth, let decl = parseSwiftVarDecl(from: strippedTrimmed) {
                    entryFuncLevelDecls.append(VarDecl(name: decl, line: lineIndex))
                }
                visibleVars = entryFuncLevelDecls
                    .filter { $0.line < lineIndex }
                    .map(\.name)
            } else {
                visibleVars = []
            }

            var instrumentedLine = line
            if isInEntryPoint {
                let captureDict = swiftScopedCapture(
                    paramNames: entryParamNames,
                    funcLevelVars: visibleVars,
                    loopVars: []
                )
                instrumentedLine = injectSwiftReturnTrace(into: line, captureDict: captureDict)
            }
            result.append(instrumentedLine)

            // Detect loop openings: for...{, while...{, repeat {
            if isInEntryPoint,
               hasManualTraceCalls == false,
               isSwiftLoopOpening(trimmed: trimmed, stripped: stripped, line: line) {
                let indent = leadingWhitespace(line) + "    "
                let loopVars = extractSwiftLoopVars(trimmed: trimmed)
                let captureDict = swiftScopedCapture(
                    paramNames: entryParamNames,
                    funcLevelVars: visibleVars,
                    loopVars: loopVars
                )
                result.append("\(indent)Trace.step(\"loop\", \(captureDict))")
            }

            braceDepth = max(0, braceDepthBefore + openBraces - closeBraces)

            if let currentEntryDepth = entryDepth, isInEntryPoint, braceDepth < currentEntryDepth {
                isInEntryPoint = false
                entryDepth = nil
                entryFuncLevelDecls = []
            }

            if let currentSolutionDepth = solutionDepth, braceDepth < currentSolutionDepth {
                solutionDepth = nil
            }
        }

        return result.joined(separator: "\n")
    }

    private static func swiftParamNamesFromSignature(
        strippedLines: [String],
        signatureStartLineIndex: Int
    ) -> [String] {
        let signature = swiftSignatureString(
            strippedLines: strippedLines,
            signatureStartLineIndex: signatureStartLineIndex
        )
        return parseSwiftParamNames(fromSignature: signature)
    }

    private static func swiftSignatureString(
        strippedLines: [String],
        signatureStartLineIndex: Int
    ) -> String {
        var signature = ""
        var index = signatureStartLineIndex
        while index < strippedLines.count {
            let line = strippedLines[index]
            signature += (signature.isEmpty ? "" : "\n") + line
            if line.contains("{") {
                break
            }
            index += 1
        }
        return signature
    }

    private static func parseSwiftParamNames(fromSignature signature: String) -> [String] {
        guard let open = signature.firstIndex(of: "(") else { return [] }
        var depth = 0
        var close: String.Index?
        var index = open
        while index < signature.endIndex {
            let char = signature[index]
            if char == "(" {
                depth += 1
            } else if char == ")" {
                depth = max(0, depth - 1)
                if depth == 0 {
                    close = index
                    break
                }
            }
            index = signature.index(after: index)
        }
        guard let close else { return [] }
        let paramsRaw = String(signature[signature.index(after: open)..<close])
        let pieces = splitSwiftParamsForSignature(paramsRaw)

        return pieces.compactMap { piece in
            let trimmed = piece.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let colonIndex = firstTopLevelColon(in: trimmed) else { return nil }
            let namePart = trimmed[..<colonIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let tokens = namePart.split(whereSeparator: { $0.isWhitespace })
            guard let last = tokens.last else { return nil }
            let rawName = String(last)
            return rawName == "_" ? nil : rawName
        }
    }

    private static func splitSwiftParamsForSignature(_ raw: String) -> [String] {
        var results: [String] = []
        var current = ""
        var depth = 0
        for char in raw {
            if char == "<" || char == "[" || char == "(" {
                depth += 1
            } else if char == ">" || char == "]" || char == ")" {
                depth = max(0, depth - 1)
            }
            if char == "," && depth == 0 {
                results.append(current)
                current = ""
                continue
            }
            current.append(char)
        }
        if !current.isEmpty {
            results.append(current)
        }
        return results
    }

    private static func firstTopLevelColon(in raw: String) -> String.Index? {
        var depth = 0
        for (offset, char) in raw.enumerated() {
            if char == "<" || char == "[" || char == "(" {
                depth += 1
            } else if char == ">" || char == "]" || char == ")" {
                depth = max(0, depth - 1)
            }
            if char == ":" && depth == 0 {
                return raw.index(raw.startIndex, offsetBy: offset)
            }
        }
        return nil
    }

    private static func isSwiftSolutionClassOpening(line: String) -> Bool {
        let pattern = "\\b(class|struct)\\s+Solution\\b"
        return line.range(of: pattern, options: .regularExpression) != nil
    }

    private static func isSwiftEntryPointSignature(line: String, name: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        let pattern = "\\bfunc\\s+`?\(escaped)`?\\s*\\("
        return line.range(of: pattern, options: .regularExpression) != nil
    }

    private static func detectSwiftEntryPointName(stripped: String) -> String? {
        let pattern = "\\bfunc\\s+`?([a-zA-Z_][a-zA-Z0-9_]*)`?\\s*\\("
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(stripped.startIndex..., in: stripped)
        guard let match = regex.firstMatch(in: stripped, options: [], range: range),
              let nameRange = Range(match.range(at: 1), in: stripped) else {
            return nil
        }
        return String(stripped[nameRange])
    }

    private static func parseSwiftVarDecl(from strippedTrimmedLine: String) -> String? {
        let pattern = "^(var|let)\\s+(\\w+)\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: strippedTrimmedLine,
                range: NSRange(strippedTrimmedLine.startIndex..., in: strippedTrimmedLine)
              ),
              let nameRange = Range(match.range(at: 2), in: strippedTrimmedLine) else {
            return nil
        }
        return String(strippedTrimmedLine[nameRange])
    }

    private static func injectSwiftReturnTrace(into line: String, captureDict: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\breturn\\b") else { return line }
        let (codePart, commentPart) = splitLineComment(line)
        let replacement = "Trace.step(\"return\", \(captureDict)); return"
        let range = NSRange(codePart.startIndex..., in: codePart)
        let replaced = regex.stringByReplacingMatches(
            in: codePart,
            options: [],
            range: range,
            withTemplate: replacement
        )
        return replaced + commentPart
    }

    private static func splitLineComment(_ line: String) -> (code: String, comment: String) {
        guard let range = line.range(of: "//") else { return (line, "") }
        return (String(line[..<range.lowerBound]), String(line[range.lowerBound...]))
    }

    private static func countOccurrences(of needle: Character, in haystack: String) -> Int {
        haystack.reduce(0) { $0 + ($1 == needle ? 1 : 0) }
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

    /// Builds a capture dictionary using only variables provably in scope:
    /// function parameters, function-level `var`/`let` declarations, and
    /// the current loop's binding variables.
    private static func swiftScopedCapture(
        paramNames: [String],
        funcLevelVars: [String],
        loopVars: [String]
    ) -> String {
        let allVars = (paramNames + loopVars + funcLevelVars)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { isValidSwiftIdentifier($0) }
            .uniqued()
        let pairs = allVars.prefix(20).map { name in
            "\"\(name)\": \(name) as Any"
        }
        return "[\(pairs.joined(separator: ", "))]"
    }

    // MARK: - Python Instrumentation

    private static func instrumentPython(
        code: String,
        entryPointName: String?,
        paramNames: [String]
    ) -> String {
        let hasManualTraceCalls = hasManualTrace(code: code, language: .python)

        let lines = code.components(separatedBy: "\n")
        var result: [String] = []
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        let assignedVars = extractPythonAssignedVars(lines: lines)
        let resolvedEntryPointName = entryPointName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entryPoint = (resolvedEntryPointName?.isEmpty == false)
            ? resolvedEntryPointName
            : detectPythonEntryPointName(stripped: stripped)
        var entryParamNames = paramNames

        var solutionIndent: Int?
        var entryIndent: Int?
        var nestedDefIndents: [Int] = []

        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indentCount = leadingWhitespace(line).count

            if solutionIndent == nil, trimmed.range(of: "^class\\s+Solution\\b", options: .regularExpression) != nil {
                solutionIndent = indentCount
            }

            if let currentSolutionIndent = solutionIndent,
               indentCount <= currentSolutionIndent,
               trimmed.hasPrefix("class ") == false {
                // Left the Solution class.
                solutionIndent = nil
                entryIndent = nil
                nestedDefIndents = []
            }

            let isInSolution = solutionIndent.map { indentCount > $0 } ?? false
            if isInSolution,
               entryIndent == nil,
               let entryPoint,
               isPythonEntryPointSignature(trimmed: trimmed, name: entryPoint) {
                entryIndent = indentCount
                nestedDefIndents = []
                let parsedParams = pythonParamNamesFromSignature(trimmedSignatureLine: trimmed)
                if !parsedParams.isEmpty {
                    entryParamNames = parsedParams
                }
            }

            if let currentEntryIndent = entryIndent,
               indentCount <= currentEntryIndent,
               isInSolution,
               trimmed.hasPrefix("def ") == false {
                // Left the entry point method.
                entryIndent = nil
                nestedDefIndents = []
            }

            while let last = nestedDefIndents.last, indentCount <= last {
                nestedDefIndents.removeLast()
            }

            let isInEntryPoint = entryIndent.map { indentCount > $0 } ?? false
            if isInEntryPoint, trimmed.hasPrefix("def ") {
                nestedDefIndents.append(indentCount)
            }

            let canInstrument = isInEntryPoint && nestedDefIndents.isEmpty
            let captureDict = pythonCaptureExpression(
                paramNames: entryParamNames,
                assignedVars: assignedVars,
                loopVars: [],
                stripped: stripped
            )
            let lineWithReturnTrace = canInstrument
                ? injectPythonReturnTrace(into: line, captureDict: captureDict)
                : line

            result.append(lineWithReturnTrace)

            // Detect loop openings: for...:, while...:
            if canInstrument, hasManualTraceCalls == false, isPythonLoopOpening(trimmed: trimmed) {
                let bodyIndent = leadingWhitespace(line) + "    "
                let loopVars = extractPythonLoopVars(trimmed: trimmed)
                let loopCapture = pythonCaptureExpression(
                    paramNames: entryParamNames,
                    assignedVars: assignedVars,
                    loopVars: loopVars,
                    stripped: stripped
                )
                // Insert a try/except around trace so variable
                // not-yet-defined errors don't crash the program
                let traceCall = "_Trace.step(\"loop\", \(loopCapture))"
                result.append("\(bodyIndent)try: \(traceCall)")
                result.append("\(bodyIndent)except: pass")
            }
        }

        return result.joined(separator: "\n")
    }

    private static func pythonParamNamesFromSignature(trimmedSignatureLine: String) -> [String] {
        let pattern = "^def\\s+\\w+\\s*\\(([^)]*)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(trimmedSignatureLine.startIndex..., in: trimmedSignatureLine)
        guard let match = regex.firstMatch(in: trimmedSignatureLine, options: [], range: range),
              let argsRange = Range(match.range(at: 1), in: trimmedSignatureLine) else {
            return []
        }
        let argsRaw = String(trimmedSignatureLine[argsRange])
        let pieces = argsRaw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return pieces
            .compactMap { piece in
                let namePart = piece.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).first
                let name = namePart.map(String.init)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !name.isEmpty else { return nil }
                guard name != "self", name != "cls" else { return nil }
                return name
            }
    }

    private static func isPythonEntryPointSignature(trimmed: String, name: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        let pattern = "^def\\s+\(escaped)\\s*\\("
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private static func detectPythonEntryPointName(stripped: String) -> String? {
        let pattern = "^\\s*def\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\("
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else {
            return nil
        }
        let range = NSRange(stripped.startIndex..., in: stripped)
        guard let match = regex.firstMatch(in: stripped, options: [], range: range),
              let nameRange = Range(match.range(at: 1), in: stripped) else {
            return nil
        }
        return String(stripped[nameRange])
    }

    private static func injectPythonReturnTrace(into line: String, captureDict: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\breturn\\b") else { return line }
        let (codePart, commentPart) = splitPythonLineComment(line)
        let replacement = "_Trace.step(\"return\", \(captureDict)); return"
        let range = NSRange(codePart.startIndex..., in: codePart)
        let replaced = regex.stringByReplacingMatches(
            in: codePart,
            options: [],
            range: range,
            withTemplate: replacement
        )
        return replaced + commentPart
    }

    private static func splitPythonLineComment(_ line: String) -> (code: String, comment: String) {
        guard let range = line.range(of: "#") else { return (line, "") }
        return (String(line[..<range.lowerBound]), String(line[range.lowerBound...]))
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
        assignedVars: [String],
        loopVars: [String],
        stripped: String
    ) -> String {
        let presentCommonVars = commonPythonVars.filter { name in
            variableExistsInCode(name: name, stripped: stripped)
        }
        let allVars = (paramNames + loopVars + assignedVars + presentCommonVars)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { isValidPythonIdentifier($0) && !$0.hasPrefix("_") && $0 != "self" && $0 != "cls" }
            .uniqued()
        let pairs = allVars.prefix(24).map { name in
            "\"\(name)\": (locals().get(\"\(name)\") if \"\(name)\" in locals() else globals().get(\"\(name)\"))"
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

extension AutoInstrumenter {
    fileprivate static func extractPythonAssignedVars(lines: [String]) -> [String] {
        let assignmentPattern =
            "^([a-zA-Z_][a-zA-Z0-9_]*(?:\\s*,\\s*[a-zA-Z_][a-zA-Z0-9_]*)*)\\s*" +
            "(?:=|\\+=|-=|\\*=|/=|//=|%=|\\|=|&=|\\^=)"
        let annotatedAssignmentPattern = "^([a-zA-Z_][a-zA-Z0-9_]*)\\s*:[^=]+="
        guard let assignmentRegex = try? NSRegularExpression(pattern: assignmentPattern),
              let annotatedRegex = try? NSRegularExpression(pattern: annotatedAssignmentPattern) else {
            return []
        }

        var names: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.hasPrefix("#") else { continue }

            if let match = assignmentRegex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
            ),
            let range = Range(match.range(at: 1), in: trimmed) {
                let lhs = String(trimmed[range])
                names.append(contentsOf: lhs
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                )
            } else if let match = annotatedRegex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
            ),
            let range = Range(match.range(at: 1), in: trimmed) {
                names.append(String(trimmed[range]))
            }

            names.append(contentsOf: extractPythonLoopVars(trimmed: trimmed))
        }

        return names
            .filter { isValidPythonIdentifier($0) && !$0.hasPrefix("_") && $0 != "self" && $0 != "cls" }
            .uniqued()
    }

    fileprivate static func extractPythonLoopVars(trimmed: String) -> [String] {
        let pattern = "^for\\s+(.+?)\\s+in\\s+"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
              ),
              let bindingRange = Range(match.range(at: 1), in: trimmed) else {
            return []
        }
        let binding = String(trimmed[bindingRange])
        let identPattern = "\\b([a-zA-Z_]\\w*)\\b"
        guard let identRegex = try? NSRegularExpression(pattern: identPattern) else {
            return []
        }
        let matches = identRegex.matches(
            in: binding,
            range: NSRange(binding.startIndex..., in: binding)
        )
        let skip: Set<String> = ["_"]
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: binding) else { return nil }
            let name = String(binding[range])
            if skip.contains(name) { return nil }
            return name
        }
    }

    fileprivate static func isValidPythonIdentifier(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        let pattern = "^[a-zA-Z_][a-zA-Z0-9_]*$"
        return name.range(of: pattern, options: .regularExpression) != nil
    }

    fileprivate static func isValidSwiftIdentifier(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        let pattern = "^[a-zA-Z_][a-zA-Z0-9_]*$"
        return name.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Swift Scope Helpers

extension AutoInstrumenter {
    struct VarDecl {
        let name: String
        let line: Int
    }

    /// Extracts variable names declared at the function body level with their
    /// line positions. Only variables declared BEFORE a given insertion point
    /// should be captured in Trace.step() calls.
    static func extractFunctionLevelDecls(lines: [String]) -> [VarDecl] {
        var funcBodyIndent: Int?
        var decls: [VarDecl] = []
        let declPattern = "^(var|let)\\s+(\\w+)"

        for (lineIndex, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if funcBodyIndent == nil {
                if trimmed.hasPrefix("var ") || trimmed.hasPrefix("let ")
                    || trimmed.hasPrefix("return ") || trimmed.hasPrefix("guard ") {
                    let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count
                    if indent > 0 { funcBodyIndent = indent }
                }
            }

            guard let bodyIndent = funcBodyIndent else { continue }
            let lineIndent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

            guard lineIndent == bodyIndent else { continue }
            guard let regex = try? NSRegularExpression(pattern: declPattern),
                  let match = regex.firstMatch(
                    in: trimmed,
                    range: NSRange(trimmed.startIndex..., in: trimmed)
                  ),
                  let nameRange = Range(match.range(at: 2), in: trimmed) else {
                continue
            }
            let name = String(trimmed[nameRange])
            if isValidSwiftIdentifier(name) {
                decls.append(VarDecl(name: name, line: lineIndex))
            }
        }
        return decls
    }

    /// Extracts binding variable names from a Swift `for` loop header.
    /// Handles: `for x in ...`, `for (x, y) in ...`, `for (_, y) in ...`
    static func extractSwiftLoopVars(trimmed: String) -> [String] {
        let pattern = "^for\\s+(.+?)\\s+in\\s+"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
              ),
              let bindingRange = Range(match.range(at: 1), in: trimmed) else {
            return []
        }
        let binding = String(trimmed[bindingRange])
        let identPattern = "\\b([a-zA-Z_]\\w*)\\b"
        guard let identRegex = try? NSRegularExpression(pattern: identPattern) else {
            return []
        }
        let matches = identRegex.matches(
            in: binding,
            range: NSRange(binding.startIndex..., in: binding)
        )
        let skip: Set<String> = ["_", "var", "let"]
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: binding) else { return nil }
            let name = String(binding[range])
            if skip.contains(name) { return nil }
            return name
        }
    }
}

// MARK: - Array Uniqued Extension

extension Array where Element: Hashable {
    fileprivate func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
