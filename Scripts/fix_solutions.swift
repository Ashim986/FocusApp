#!/usr/bin/env swift

// fix_solutions.swift
//
// Fixes common mechanical errors in bundled solution JSON files:
// 1. Expands single-line semicolon code into properly indented multi-line code
// 2. Moves `import Foundation` that appears after a class definition to before it
// 3. Strips excessive base indentation (6+ spaces on every line)
//
// Usage: swift Scripts/fix_solutions.swift

import Foundation

// MARK: - Configuration

let solutionsDir = "FocusApp/Resources/Solutions"

// MARK: - Fix 1: Expand single-line semicolon code

/// Checks whether code is a single-line (or nearly single-line) block
/// with many semicolons acting as statement separators.
func isSingleLineSemicolonCode(_ code: String) -> Bool {
    let newlines = code.filter { $0 == "\n" }.count
    let semicolons = code.filter { $0 == ";" }.count
    return semicolons > 5 && newlines < 5
}

/// Splits a string into sub-pieces at `{` and `}` boundaries while keeping
/// the braces attached to the appropriate piece.
///
/// For example: `class Solution { func foo() -> Int { return 0 } }`
/// becomes: [`class Solution {`, `func foo() -> Int {`, `return 0`, `}`, `}`]
func splitAtBraces(_ code: String) -> [String] {
    var result: [String] = []
    var current = ""
    var inString = false
    var escape = false

    for ch in code {
        if escape {
            current.append(ch)
            escape = false
            continue
        }
        if ch == "\\" && inString {
            current.append(ch)
            escape = true
            continue
        }
        if ch == "\"" {
            inString.toggle()
            current.append(ch)
            continue
        }

        if !inString {
            if ch == "{" {
                current.append(ch)
                let trimmed = current.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    result.append(trimmed)
                }
                current = ""
                continue
            }
            if ch == "}" {
                let trimmed = current.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    result.append(trimmed)
                }
                current = ""
                result.append("}")
                continue
            }
        }

        current.append(ch)
    }

    let trimmed = current.trimmingCharacters(in: .whitespaces)
    if !trimmed.isEmpty {
        result.append(trimmed)
    }

    return result
}

/// Splits code at semicolons (outside string literals) and re-indents
/// based on brace depth.
func expandSingleLineCode(_ code: String) -> String {
    // First, split on semicolons outside of string literals
    var segments: [String] = []
    var current = ""
    var inString = false
    var escape = false

    for ch in code {
        if escape {
            current.append(ch)
            escape = false
            continue
        }
        if ch == "\\" && inString {
            current.append(ch)
            escape = true
            continue
        }
        if ch == "\"" {
            inString.toggle()
            current.append(ch)
            continue
        }
        if ch == ";" && !inString {
            segments.append(current)
            current = ""
            continue
        }
        current.append(ch)
    }
    if !current.isEmpty {
        segments.append(current)
    }

    // Now we have segments. Next, split further on `{` and `}` boundaries
    // to create individual lines and track brace depth for indentation.
    var lines: [String] = []
    var braceDepth = 0

    for segment in segments {
        let trimmed = segment.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { continue }

        // Split segment into sub-lines at brace boundaries
        let subLines = splitAtBraces(trimmed)

        for subLine in subLines {
            let sub = subLine.trimmingCharacters(in: .whitespaces)
            if sub.isEmpty { continue }

            // Count closing braces at the start to decrease indent BEFORE this line
            let leadingClose = sub.prefix(while: { $0 == "}" }).count
            braceDepth = max(0, braceDepth - leadingClose)

            let indent = String(repeating: "    ", count: braceDepth)
            lines.append(indent + sub)

            // Count net brace change for this line (excluding leading closes already handled)
            let opens = sub.filter { $0 == "{" }.count
            let closes = sub.filter { $0 == "}" }.count
            let netChange = opens - (closes - leadingClose)
            braceDepth = max(0, braceDepth + netChange)
        }
    }

    return lines.joined(separator: "\n")
}

// MARK: - Fix 2: Move `import Foundation` that appears after a class definition

/// Detects and fixes `import Foundation` appearing after a `class` keyword
/// in the code. Moves the import to the very top of the code.
func fixImportAfterClass(_ code: String) -> String {
    let lines = code.components(separatedBy: "\n")
    var sawClassOrStruct = false
    var importLineIndex: Int?

    for (index, line) in lines.enumerated() {
        let stripped = line.trimmingCharacters(in: .whitespaces)
        if stripped.hasPrefix("class ") || stripped.hasPrefix("public class ") ||
           stripped.hasPrefix("struct ") || stripped.hasPrefix("public struct ") {
            sawClassOrStruct = true
        }
        if sawClassOrStruct && stripped == "import Foundation" {
            importLineIndex = index
            break
        }
    }

    guard let idx = importLineIndex else { return code }

    var mutableLines = lines
    mutableLines.remove(at: idx)
    // Remove blank line that was right after the import
    if idx < mutableLines.count && mutableLines[idx].trimmingCharacters(in: .whitespaces).isEmpty {
        mutableLines.remove(at: idx)
    }
    // Remove blank line that was right before the import
    if idx > 0 && idx - 1 < mutableLines.count &&
        mutableLines[idx - 1].trimmingCharacters(in: .whitespaces).isEmpty {
        mutableLines.remove(at: idx - 1)
    }

    // Insert import Foundation at the top (skip any leading blank lines)
    var insertAt = 0
    while insertAt < mutableLines.count &&
          mutableLines[insertAt].trimmingCharacters(in: .whitespaces).isEmpty {
        insertAt += 1
    }
    mutableLines.insert("import Foundation", at: insertAt)
    // Ensure a blank line after the import
    if insertAt + 1 < mutableLines.count &&
       !mutableLines[insertAt + 1].trimmingCharacters(in: .whitespaces).isEmpty {
        mutableLines.insert("", at: insertAt + 1)
    }

    return mutableLines.joined(separator: "\n")
}

// MARK: - Fix 3: Strip excessive base indentation

/// If every non-empty line has at least N spaces of leading whitespace where
/// N >= 6, strip that common prefix from all lines.
func stripExcessiveIndentation(_ code: String) -> String {
    let lines = code.components(separatedBy: "\n")
    let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    guard !nonEmptyLines.isEmpty else { return code }

    let minIndent = nonEmptyLines.map { line -> Int in
        var count = 0
        for ch in line {
            if ch == " " {
                count += 1
            } else {
                break
            }
        }
        return count
    }.min() ?? 0

    guard minIndent >= 6 else { return code }

    let result = lines.map { line -> String in
        if line.trimmingCharacters(in: .whitespaces).isEmpty {
            return ""
        }
        let start = line.index(line.startIndex, offsetBy: min(minIndent, line.count))
        return String(line[start...])
    }.joined(separator: "\n")

    return result
}

// MARK: - Main

struct FixStats {
    var semicolonExpanded = 0
    var importMoved = 0
    var indentStripped = 0
    var filesModified = 0
    var filesProcessed = 0
    var details: [String] = []
}

private func applyFixes(to code: String, stats: inout FixStats) -> (fixed: String, applied: [String]) {
    var fixed = code
    var applied: [String] = []

    // Fix 1: Expand single-line semicolon code
    if isSingleLineSemicolonCode(fixed) {
        let expanded = expandSingleLineCode(fixed)
        if expanded != fixed {
            fixed = expanded
            applied.append("semicolon-expand")
            stats.semicolonExpanded += 1
        }
    }

    // Fix 2: Strip excessive base indentation (before import move,
    // so the import line is at column 0 when we detect it)
    let afterIndentFix = stripExcessiveIndentation(fixed)
    if afterIndentFix != fixed {
        fixed = afterIndentFix
        applied.append("indent-stripped")
        stats.indentStripped += 1
    }

    // Fix 3: Move import after class to top
    let afterImportFix = fixImportAfterClass(fixed)
    if afterImportFix != fixed {
        fixed = afterImportFix
        applied.append("import-moved")
        stats.importMoved += 1
    }

    return (fixed, applied)
}

private func processApproaches(
    _ approaches: inout [[String: Any]],
    fileName: String,
    slug: String,
    stats: inout FixStats
) -> Bool {
    var modified = false

    for appIdx in 0..<approaches.count {
        guard let code = approaches[appIdx]["code"] as? String else { continue }
        let appName = approaches[appIdx]["name"] as? String ?? "?"

        let result = applyFixes(to: code, stats: &stats)
        guard result.fixed != code else { continue }

        approaches[appIdx]["code"] = result.fixed
        modified = true

        let detail = "  [\(fileName)] \(slug) / \(appName): \(result.applied.joined(separator: ", "))"
        stats.details.append(detail)
    }

    return modified
}

private func processSolution(
    _ solution: inout [String: Any],
    fileName: String,
    stats: inout FixStats
) -> Bool {
    guard var approaches = solution["approaches"] as? [[String: Any]] else {
        return false
    }

    let slug = solution["problemSlug"] as? String ?? "?"
    let modified = processApproaches(&approaches, fileName: fileName, slug: slug, stats: &stats)
    if modified {
        solution["approaches"] = approaches
    }
    return modified
}

private func processSolutions(
    _ solutions: inout [[String: Any]],
    fileName: String,
    stats: inout FixStats
) -> Bool {
    var modified = false

    for solIdx in 0..<solutions.count {
        var sol = solutions[solIdx]
        if processSolution(&sol, fileName: fileName, stats: &stats) {
            solutions[solIdx] = sol
            modified = true
        }
    }

    return modified
}

func processFile(at path: String, stats: inout FixStats) throws {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)

    guard var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        print("  Skipping \(url.lastPathComponent): not a JSON object")
        return
    }

    guard var solutions = json["solutions"] as? [[String: Any]] else {
        print("  Skipping \(url.lastPathComponent): no 'solutions' array")
        return
    }

    stats.filesProcessed += 1
    let fileName = url.lastPathComponent
    let fileModified = processSolutions(&solutions, fileName: fileName, stats: &stats)

    if fileModified {
        json["solutions"] = solutions
        let outputData = try JSONSerialization.data(
            withJSONObject: json,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        try outputData.write(to: url)
        stats.filesModified += 1
        print("  Updated \(fileName)")
    } else {
        print("  No changes in \(fileName)")
    }
}

// Resolve project root (script is at Scripts/fix_solutions.swift)
let scriptPath = CommandLine.arguments[0]
let scriptURL = URL(fileURLWithPath: scriptPath).standardized

// Walk up from the script location to find the project root
var candidateURL = scriptURL.deletingLastPathComponent()
for _ in 0..<5 {
    let xcodeproj = candidateURL.appendingPathComponent("FocusApp.xcodeproj")
    if FileManager.default.fileExists(atPath: xcodeproj.path) {
        break
    }
    candidateURL = candidateURL.deletingLastPathComponent()
}
let projectRoot = candidateURL.path

let solutionsDirPath = (projectRoot as NSString).appendingPathComponent(solutionsDir)

print("Solutions directory: \(solutionsDirPath)")
print()

guard FileManager.default.fileExists(atPath: solutionsDirPath) else {
    print("ERROR: Solutions directory not found at \(solutionsDirPath)")
    print("Run this script from the project root: swift Scripts/fix_solutions.swift")
    exit(1)
}

let contents = try FileManager.default.contentsOfDirectory(atPath: solutionsDirPath)
let jsonFiles = contents.filter { $0.hasSuffix(".json") && $0 != "index.json" }.sorted()

print("Found \(jsonFiles.count) topic files to process")
print()

var stats = FixStats()

for file in jsonFiles {
    let path = (solutionsDirPath as NSString).appendingPathComponent(file)
    try processFile(at: path, stats: &stats)
}

print()
print("=== Summary ===")
print("Files processed: \(stats.filesProcessed)")
print("Files modified:  \(stats.filesModified)")
print("Semicolons expanded:       \(stats.semicolonExpanded)")
print("Imports moved:             \(stats.importMoved)")
print("Indentation stripped:      \(stats.indentStripped)")
print("Total approaches fixed:    \(stats.semicolonExpanded + stats.importMoved + stats.indentStripped)")
print()

if !stats.details.isEmpty {
    print("=== Details ===")
    for detail in stats.details {
        print(detail)
    }
}
