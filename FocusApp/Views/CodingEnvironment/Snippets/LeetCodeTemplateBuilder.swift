import Foundation

struct LeetCodeTemplateBuilder {
    static func template(for content: QuestionContent, language: ProgrammingLanguage) -> String? {
        guard let meta = LeetCodeMetaData.decode(from: content.metaData) else { return nil }
        return template(for: meta, language: language)
    }

    static func template(for meta: LeetCodeMetaData, language: ProgrammingLanguage) -> String? {
        if meta.isClassDesign {
            return classDesignTemplate(for: meta, language: language)
        }

        guard let name = meta.name, !name.isEmpty else { return nil }
        let params = meta.primaryParams
        let returnType = LeetCodeValueType(raw: meta.returnType?.type ?? "void")

        switch language {
        case .swift:
            return swiftFunctionTemplate(name: name, params: params, returnType: returnType)
        case .python:
            return pythonFunctionTemplate(name: name, params: params, returnType: returnType)
        }
    }

    private static func classDesignTemplate(for meta: LeetCodeMetaData, language: ProgrammingLanguage) -> String? {
        guard let className = meta.className, let methods = meta.methods, !methods.isEmpty else { return nil }
        switch language {
        case .swift:
            return swiftClassDesignTemplate(className: className, methods: methods)
        case .python:
            return pythonClassDesignTemplate(className: className, methods: methods)
        }
    }
}
