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
}

// MARK: - Swift Instrumentation

extension AutoInstrumenter {
    private struct SwiftLineInfo {
        let lineIndex: Int
        let strippedTrimmed: String
        let braceDepthBefore: Int
        let openBraces: Int
        let closeBraces: Int
    }

    private struct SwiftInstrumentationState {
        var braceDepth = 0
        var solutionDepth: Int?
        var isPendingSolutionOpen = false

        var entryDepth: Int?
        var isPendingEntryOpen = false
        var isInEntryPoint = false

        // Return/loop instrumentation should only apply to the main LeetCode entry function.
        // We track nested closures/local functions inside the entry function and avoid
        // instrumenting inside them to prevent exclusivity violations (e.g. `array.sort { return ... }`).
        var closureDepths: [Int] = []
        var localFuncDepths: [Int] = []

        var entryParamNames: [String]
        var entryFuncLevelDecls: [VarDecl] = []

        init(entryParamNames: [String]) {
            self.entryParamNames = entryParamNames
        }
    }

    private static func instrumentSwift(
        code: String,
        entryPointName: String?,
        paramNames: [String]
    ) -> String {
        let hasManualTraceCalls = hasManualTrace(code: code, language: .swift)
        let lines = code.components(separatedBy: "\n")
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        let strippedLines = stripped.components(separatedBy: "\n")

        let resolvedEntryPointName = entryPointName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entryPoint = (resolvedEntryPointName?.isEmpty == false)
            ? resolvedEntryPointName
            : detectSwiftEntryPointName(stripped: stripped)

        var state = SwiftInstrumentationState(entryParamNames: paramNames)
        var result: [String] = []
        result.reserveCapacity(lines.count)

        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let strippedLine = strippedLines.indices.contains(lineIndex) ? strippedLines[lineIndex] : line
            let strippedTrimmed = strippedLine.trimmingCharacters(in: .whitespaces)

            let braceDepthBefore = state.braceDepth
            let openBraces = countOccurrences(of: "{", in: strippedLine)
            let closeBraces = countOccurrences(of: "}", in: strippedLine)

            let info = SwiftLineInfo(
                lineIndex: lineIndex,
                strippedTrimmed: strippedTrimmed,
                braceDepthBefore: braceDepthBefore,
                openBraces: openBraces,
                closeBraces: closeBraces
            )

            updateSolutionState(info: info, state: &state)
            let isInSolution = state.solutionDepth.map { braceDepthBefore >= $0 } ?? false

            updateEntryPointState(
                info: info,
                strippedLines: strippedLines,
                entryPoint: entryPoint,
                isInSolution: isInSolution,
                state: &state
            )

            updateNestedScopes(info: info, entryPoint: entryPoint, state: &state)
            let isInsideNestedScope = !state.closureDepths.isEmpty || !state.localFuncDepths.isEmpty

            let visibleVars = visibleSwiftVars(info: info, state: &state)

            if state.isInEntryPoint,
               isInsideNestedScope == false,
               hasManualTraceCalls == false,
               isSwiftStandaloneReturnLine(strippedTrimmed: strippedTrimmed) {
                let captureVars = swiftCaptureVars(
                    paramNames: state.entryParamNames,
                    funcLevelVars: visibleVars,
                    loopVars: []
                )
                result.append(
                    contentsOf: swiftTraceLines(
                        label: "return",
                        captureVars: captureVars,
                        indent: leadingWhitespace(line),
                        uniqueSuffix: lineIndex
                    )
                )
            }

            result.append(line)

            if state.isInEntryPoint,
               isInsideNestedScope == false,
               hasManualTraceCalls == false,
               isSwiftLoopOpening(trimmed: trimmed) {
                let indent = leadingWhitespace(line) + "    "
                let loopVars = extractSwiftLoopVars(trimmed: trimmed)
                let captureVars = swiftCaptureVars(
                    paramNames: state.entryParamNames,
                    funcLevelVars: visibleVars,
                    loopVars: loopVars
                )
                result.append(
                    contentsOf: swiftTraceLines(
                        label: "loop",
                        captureVars: captureVars,
                        indent: indent,
                        uniqueSuffix: lineIndex
                    )
                )
            }

            closeScopesAfterLine(info: info, state: &state)
        }

        return result.joined(separator: "\n")
    }

    private static func updateNestedScopes(
        info: SwiftLineInfo,
        entryPoint: String?,
        state: inout SwiftInstrumentationState
    ) {
        guard state.isInEntryPoint, info.openBraces > 0 else { return }

        if isSwiftNestedFunctionSignature(line: info.strippedTrimmed, entryPoint: entryPoint) {
            state.localFuncDepths.append(info.braceDepthBefore + 1)
            return
        }

        if isSwiftClosureOpening(line: info.strippedTrimmed) {
            state.closureDepths.append(info.braceDepthBefore + 1)
        }
    }

    private static func isSwiftNestedFunctionSignature(line: String, entryPoint: String?) -> Bool {
        guard line.hasPrefix("func ") else { return false }
        if let entryPoint, isSwiftEntryPointSignature(line: line, name: entryPoint) {
            return false
        }
        return true
    }

    private static func isSwiftClosureOpening(line: String) -> Bool {
        guard line.contains("{") else { return false }

        // Avoid misclassifying declarations/control-flow blocks as closures.
        let prefixes = [
            "}", "class ", "struct ", "enum ", "protocol ", "extension ",
            "func ", "if ", "else", "for ", "while ", "switch ", "do ", "catch ", "defer ", "repeat "
        ]
        if prefixes.contains(where: { line.hasPrefix($0) }) { return false }
        if line.hasPrefix("guard ") { return false }
        if line.contains(" else {") { return false }

        return true
    }

    private static func updateSolutionState(info: SwiftLineInfo, state: inout SwiftInstrumentationState) {
        if state.solutionDepth == nil, isSwiftSolutionClassOpening(line: info.strippedTrimmed) {
            state.isPendingSolutionOpen = true
        }
        if state.isPendingSolutionOpen, state.solutionDepth == nil, info.openBraces > 0 {
            state.solutionDepth = info.braceDepthBefore + 1
            state.isPendingSolutionOpen = false
        }
    }

    private static func updateEntryPointState(
        info: SwiftLineInfo,
        strippedLines: [String],
        entryPoint: String?,
        isInSolution: Bool,
        state: inout SwiftInstrumentationState
    ) {
        guard isInSolution, state.entryDepth == nil, let entryPoint else { return }

        if state.isPendingEntryOpen == false,
           isSwiftEntryPointSignature(line: info.strippedTrimmed, name: entryPoint) {
            let parsedParams = swiftParamNamesFromSignature(
                strippedLines: strippedLines,
                signatureStartLineIndex: info.lineIndex
            )
            if !parsedParams.isEmpty {
                state.entryParamNames = parsedParams
            }
            if info.openBraces > 0 {
                state.entryDepth = info.braceDepthBefore + 1
                state.isInEntryPoint = true
                state.entryFuncLevelDecls = []
            } else {
                state.isPendingEntryOpen = true
            }
            return
        }

        if state.isPendingEntryOpen, info.openBraces > 0 {
            state.entryDepth = info.braceDepthBefore + 1
            state.isInEntryPoint = true
            state.isPendingEntryOpen = false
            state.entryFuncLevelDecls = []
        }
    }

    private static func visibleSwiftVars(info: SwiftLineInfo, state: inout SwiftInstrumentationState) -> [String] {
        guard state.isInEntryPoint, let entryDepth = state.entryDepth else { return [] }

        if info.braceDepthBefore == entryDepth,
           let decl = parseSwiftVarDecl(from: info.strippedTrimmed) {
            state.entryFuncLevelDecls.append(VarDecl(name: decl, line: info.lineIndex))
        }

        return state.entryFuncLevelDecls
            .filter { $0.line < info.lineIndex }
            .map(\.name)
    }

    private static func closeScopesAfterLine(info: SwiftLineInfo, state: inout SwiftInstrumentationState) {
        state.braceDepth = max(0, info.braceDepthBefore + info.openBraces - info.closeBraces)

        while let depth = state.closureDepths.last, state.braceDepth < depth {
            state.closureDepths.removeLast()
        }
        while let depth = state.localFuncDepths.last, state.braceDepth < depth {
            state.localFuncDepths.removeLast()
        }

        if let entryDepth = state.entryDepth,
           state.isInEntryPoint,
           state.braceDepth < entryDepth {
            state.isInEntryPoint = false
            state.entryDepth = nil
            state.entryFuncLevelDecls = []
            state.closureDepths = []
            state.localFuncDepths = []
        }

        if let solutionDepth = state.solutionDepth,
           state.braceDepth < solutionDepth {
            state.solutionDepth = nil
            state.isPendingSolutionOpen = false

            state.isInEntryPoint = false
            state.entryDepth = nil
            state.isPendingEntryOpen = false
            state.entryFuncLevelDecls = []
            state.closureDepths = []
            state.localFuncDepths = []
        }
    }
}

extension AutoInstrumenter {
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
}

extension AutoInstrumenter {
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

    private static func splitLineComment(_ line: String) -> (code: String, comment: String) {
        guard let range = line.range(of: "//") else { return (line, "") }
        return (String(line[..<range.lowerBound]), String(line[range.lowerBound...]))
    }

    private static func countOccurrences(of needle: Character, in haystack: String) -> Int {
        haystack.reduce(0) { $0 + ($1 == needle ? 1 : 0) }
    }

    private static func isSwiftLoopOpening(trimmed: String) -> Bool {
        let loopPatterns = [
            "^for\\s+.*\\{\\s*$",
            "^while\\s+.*\\{\\s*$",
            "^repeat\\s*\\{\\s*$"
        ]
        return loopPatterns.contains { trimmed.range(of: $0, options: .regularExpression) != nil }
    }

    private static func swiftCaptureVars(
        paramNames: [String],
        funcLevelVars: [String],
        loopVars: [String]
    ) -> [String] {
        let allVars = (paramNames + loopVars + funcLevelVars)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { isValidSwiftIdentifier($0) }
            .uniqued()
        // Keep this small; large capture dictionaries can cause the Swift compiler
        // to time out type-checking when inserted repeatedly inside loops.
        return Array(allVars.prefix(8))
    }

    private static func swiftTraceLines(
        label: String,
        captureVars: [String],
        indent: String,
        uniqueSuffix: Int
    ) -> [String] {
        guard !captureVars.isEmpty else {
            return ["\(indent)Trace.step(\"\(label)\")"]
        }

        let traceVar = "__focusTrace_\(uniqueSuffix)"
        var lines: [String] = ["\(indent)var \(traceVar): [String: Any?] = [:]"]
        for name in captureVars {
            lines.append("\(indent)\(traceVar)[\"\(name)\"] = \(name)")
        }
        lines.append("\(indent)Trace.step(\"\(label)\", \(traceVar))")
        return lines
    }

    private static func isSwiftStandaloneReturnLine(strippedTrimmed: String) -> Bool {
        // Only instrument `return ...` that starts the statement.
        // Inline returns like `if x { return y }` are left untouched to avoid
        // rewriting complex single-line constructs.
        strippedTrimmed == "return" || strippedTrimmed.hasPrefix("return ")
    }
}

extension AutoInstrumenter {
    static func leadingWhitespace(_ line: String) -> String {
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

    static func isValidSwiftIdentifier(_ name: String) -> Bool {
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
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
