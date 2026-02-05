import Foundation

extension LeetCodeTemplateBuilder {
    static func swiftFunctionTemplate(
        name: String,
        params: [LeetCodeMetaParam],
        returnType: LeetCodeValueType
    ) -> String {
        let typesUsed = collectTypes(params: params, returnType: returnType)
        let support = swiftSupportClasses(typesUsed: typesUsed)
        let parameters = swiftParameterList(params)
        let returnSignature = returnType == .void ? "" : " -> \(returnType.swiftType)"
        let returnLine = swiftDefaultReturn(for: returnType)

        var lines: [String] = []
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class Solution {")
        lines.append("    func \(swiftSafeIdentifier(name, index: 0))\(parameters)\(returnSignature) {")
        lines.append("        // TODO: Implement")
        if let returnLine {
            lines.append("        \(returnLine)")
        }
        lines.append("    }")
        lines.append("}")

        return lines.joined(separator: "\n")
    }

    static func swiftClassDesignTemplate(className: String, methods: [LeetCodeMetaMethod]) -> String {
        let typesUsed = collectTypes(methods: methods)
        let support = swiftSupportClasses(typesUsed: typesUsed)

        var lines: [String] = []
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class \(swiftSafeIdentifier(className, index: 0)) {")

        for (index, method) in methods.enumerated() {
            if method.name == className {
                let params = swiftParameterList(method.params)
                lines.append("    init\(params) {")
                lines.append("        // TODO: Initialize")
                lines.append("    }")
            } else {
                let returnType = LeetCodeValueType(raw: method.returnType?.type ?? "void")
                let returnSignature = returnType == .void ? "" : " -> \(returnType.swiftType)"
                let returnLine = swiftDefaultReturn(for: returnType)
                let parameters = swiftParameterList(method.params)
                let methodName = swiftSafeIdentifier(method.name, index: index)
                lines.append("    func \(methodName)\(parameters)\(returnSignature) {")
                lines.append("        // TODO: Implement")
                if let returnLine {
                    lines.append("        \(returnLine)")
                }
                lines.append("    }")
            }
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private static func swiftParameterList(_ params: [LeetCodeMetaParam]) -> String {
        guard !params.isEmpty else { return "()" }
        let signature = params.enumerated().map { index, param -> String in
            let name = swiftSafeIdentifier(param.name ?? "arg\(index + 1)", index: index)
            let type = LeetCodeValueType(raw: param.type).swiftType
            return "_ \(name): \(type)"
        }.joined(separator: ", ")
        return "(\(signature))"
    }
}
