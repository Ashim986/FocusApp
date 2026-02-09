import Foundation

struct LeetCodeExecutionWrapper {
    static func wrap(code: String, language: ProgrammingLanguage, meta: LeetCodeMetaData) -> String {
        guard shouldWrap(code: code, language: language, meta: meta) else { return code }
        switch language {
        case .swift:
            return wrapSwift(code: code, meta: meta)
        case .python:
            return wrapPython(code: code, meta: meta)
        }
    }

    static func shouldWrap(code: String, language: ProgrammingLanguage, meta: LeetCodeMetaData) -> Bool {
        if meta.isClassDesign { return false }
        guard let name = meta.name, !name.isEmpty else { return false }
        let marker = language == .swift ? "// FocusApp LeetCode Runner" : "# FocusApp LeetCode Runner"
        if code.contains(marker) { return false }
        switch language {
        case .swift:
            return code.contains("class Solution") || code.contains("struct Solution")
        case .python:
            return code.contains("class Solution")
        }
    }
}
