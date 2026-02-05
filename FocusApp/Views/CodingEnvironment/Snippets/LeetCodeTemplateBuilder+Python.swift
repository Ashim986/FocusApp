import Foundation

extension LeetCodeTemplateBuilder {
    static func pythonFunctionTemplate(
        name: String,
        params: [LeetCodeMetaParam],
        returnType: LeetCodeValueType
    ) -> String {
        let typesUsed = collectTypes(params: params, returnType: returnType)
        let support = pythonSupportClasses(typesUsed: typesUsed)
        let imports = pythonTypingImports(typesUsed: typesUsed)
        let parameterList = pythonParameterList(params)
        let returnSignature = returnType == .void ? "" : " -> \(returnType.pythonType)"

        var lines: [String] = []
        if !imports.isEmpty {
            lines.append(imports)
        }
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class Solution:")
        lines.append("    def \(pythonSafeIdentifier(name, index: 0))(\(parameterList))\(returnSignature):")
        lines.append("        # TODO: Implement")
        lines.append("        pass")

        return lines.joined(separator: "\n")
    }

    static func pythonClassDesignTemplate(className: String, methods: [LeetCodeMetaMethod]) -> String {
        let typesUsed = collectTypes(methods: methods)
        let support = pythonSupportClasses(typesUsed: typesUsed)
        let imports = pythonTypingImports(typesUsed: typesUsed)

        var lines: [String] = []
        if !imports.isEmpty {
            lines.append(imports)
        }
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class \(pythonSafeIdentifier(className, index: 0)):")

        for (index, method) in methods.enumerated() {
            if method.name == className {
                let parameters = pythonParameterList(method.params)
                lines.append("    def __init__(\(parameters)):")
                lines.append("        # TODO: Initialize")
                lines.append("        pass")
            } else {
                let returnType = LeetCodeValueType(raw: method.returnType?.type ?? "void")
                let returnSignature = returnType == .void ? "" : " -> \(returnType.pythonType)"
                let parameters = pythonParameterList(method.params)
                let methodName = pythonSafeIdentifier(method.name, index: index)
                lines.append("    def \(methodName)(\(parameters))\(returnSignature):")
                lines.append("        # TODO: Implement")
                lines.append("        pass")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func pythonParameterList(_ params: [LeetCodeMetaParam]) -> String {
        let items = params.enumerated().map { index, param -> String in
            let name = pythonSafeIdentifier(param.name ?? "arg\(index + 1)", index: index)
            let type = LeetCodeValueType(raw: param.type).pythonType
            return "\(name): \(type)"
        }
        let list = (["self"] + items).joined(separator: ", ")
        return list
    }
}
