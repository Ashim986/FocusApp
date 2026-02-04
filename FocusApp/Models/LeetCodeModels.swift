import Foundation

struct LeetCodeRestSubmissionListResponse: Decodable {
    let submissions: [LeetCodeRestSubmission]

    enum CodingKeys: String, CodingKey {
        case submission
        case submissions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        submissions = (try? container.decode([LeetCodeRestSubmission].self, forKey: .submission))
            ?? (try? container.decode([LeetCodeRestSubmission].self, forKey: .submissions))
            ?? []
    }
}

struct LeetCodeRestSubmission: Decodable {
    let titleSlug: String
    let statusDisplay: String?
    let timestamp: String?
    let lang: String?

    enum CodingKeys: String, CodingKey {
        case titleSlug
        case statusDisplay
        case timestamp
        case lang
    }
}

struct LeetCodeRestProblemResponse: Decodable {
    let title: String
    let content: String
    let exampleTestcases: String
    let sampleTestCase: String
    let difficulty: String
    let codeSnippets: [LeetCodeRestCodeSnippet]
    let metaData: String?

    enum CodingKeys: String, CodingKey {
        case title
        case questionTitle
        case content
        case question
        case exampleTestcases
        case sampleTestCase
        case difficulty
        case codeSnippets
        case metaData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? container.decode(String.self, forKey: .title))
            ?? (try? container.decode(String.self, forKey: .questionTitle))
            ?? ""
        content = (try? container.decode(String.self, forKey: .content))
            ?? (try? container.decode(String.self, forKey: .question))
            ?? ""
        exampleTestcases = (try? container.decode(String.self, forKey: .exampleTestcases)) ?? ""
        sampleTestCase = (try? container.decode(String.self, forKey: .sampleTestCase)) ?? ""
        difficulty = (try? container.decode(String.self, forKey: .difficulty)) ?? ""
        codeSnippets = (try? container.decode([LeetCodeRestCodeSnippet].self, forKey: .codeSnippets)) ?? []
        metaData = try? container.decode(String.self, forKey: .metaData)
    }
}

struct LeetCodeRestCodeSnippet: Decodable {
    let lang: String?
    let langSlug: String
    let code: String
}

struct LeetCodeUserProfileResponse: Decodable {
    let username: String?

    enum CodingKeys: String, CodingKey {
        case username
        case profile
        case userProfile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let name = try? container.decode(String.self, forKey: .username) {
            username = name
            return
        }
        if let profile = try? container.decode(LeetCodeUserProfile.self, forKey: .profile) {
            username = profile.username
            return
        }
        if let profile = try? container.decode(LeetCodeUserProfile.self, forKey: .userProfile) {
            username = profile.username
            return
        }
        username = nil
    }
}

struct LeetCodeUserProfile: Decodable {
    let username: String?
}

struct LeetCodeGraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [LeetCodeGraphQLError]?
}

struct LeetCodeGraphQLError: Decodable {
    let message: String
}

struct LeetCodeRecentAcSubmissionsData: Decodable {
    let recentAcSubmissionList: [LeetCodeGraphQLSubmission]
}

struct LeetCodeGraphQLSubmission: Decodable {
    let titleSlug: String
}

struct LeetCodeGraphQLQuestionData: Decodable {
    let question: LeetCodeGraphQLQuestion?
}

struct LeetCodeGraphQLQuestion: Decodable {
    let title: String
    let content: String
    let exampleTestcases: String
    let sampleTestCase: String
    let difficulty: String
    let codeSnippets: [LeetCodeRestCodeSnippet]
    let metaData: String?
}

struct LeetCodeMetaData: Decodable {
    let name: String?
    let params: [LeetCodeMetaParam]?
    let returnType: LeetCodeMetaReturn?
    let className: String?
    let methods: [LeetCodeMetaMethod]?

    enum CodingKeys: String, CodingKey {
        case name
        case params
        case returnType = "return"
        case className
        case classname
        case methods
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        params = try? container.decode([LeetCodeMetaParam].self, forKey: .params)
        returnType = try? container.decode(LeetCodeMetaReturn.self, forKey: .returnType)
        className = (try? container.decode(String.self, forKey: .className))
            ?? (try? container.decode(String.self, forKey: .classname))
        methods = try? container.decode([LeetCodeMetaMethod].self, forKey: .methods)
    }
}

struct LeetCodeMetaParam: Decodable {
    let name: String?
    let type: String
}

struct LeetCodeMetaReturn: Decodable {
    let type: String
}

struct LeetCodeMetaMethod: Decodable {
    let name: String
    let params: [LeetCodeMetaParam]
    let returnType: LeetCodeMetaReturn?

    enum CodingKeys: String, CodingKey {
        case name
        case params
        case returnType = "return"
    }
}

extension LeetCodeMetaData {
    static func decode(from raw: String?) -> LeetCodeMetaData? {
        guard let raw, let data = raw.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(LeetCodeMetaData.self, from: data)
    }

    var isClassDesign: Bool {
        let hasClassName = !(className?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasMethods = !(methods?.isEmpty ?? true)
        return hasClassName && hasMethods
    }

    var primaryParams: [LeetCodeMetaParam] {
        params ?? []
    }
}

indirect enum LeetCodeValueType: Equatable {
    case int
    case double
    case bool
    case string
    case character
    case void
    case list(LeetCodeValueType)
    case listNode
    case treeNode
    case unknown(String)

    init(raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        if lower.hasSuffix("[]") {
            let innerRaw = String(trimmed.dropLast(2))
            self = .list(LeetCodeValueType(raw: innerRaw))
            return
        }

        if lower.hasPrefix("list<"), lower.hasSuffix(">") {
            let start = trimmed.index(trimmed.startIndex, offsetBy: 5)
            let end = trimmed.index(before: trimmed.endIndex)
            let innerRaw = String(trimmed[start..<end])
            self = .list(LeetCodeValueType(raw: innerRaw))
            return
        }

        switch lower {
        case "int", "integer", "long", "short", "byte":
            self = .int
        case "double", "float", "decimal":
            self = .double
        case "bool", "boolean":
            self = .bool
        case "string", "str":
            self = .string
        case "char", "character":
            self = .character
        case "void":
            self = .void
        case "listnode":
            self = .listNode
        case "treenode":
            self = .treeNode
        default:
            self = .unknown(trimmed)
        }
    }

    var needsListNode: Bool {
        switch self {
        case .listNode:
            return true
        case .list(let inner):
            return inner.needsListNode
        default:
            return false
        }
    }

    var needsTreeNode: Bool {
        switch self {
        case .treeNode:
            return true
        case .list(let inner):
            return inner.needsTreeNode
        default:
            return false
        }
    }

    var swiftType: String {
        switch self {
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .bool:
            return "Bool"
        case .string:
            return "String"
        case .character:
            return "Character"
        case .void:
            return "Void"
        case .list(let inner):
            return "[\(inner.swiftType)]"
        case .listNode:
            return "ListNode?"
        case .treeNode:
            return "TreeNode?"
        case .unknown:
            return "Any"
        }
    }

    var pythonType: String {
        switch self {
        case .int:
            return "int"
        case .double:
            return "float"
        case .bool:
            return "bool"
        case .string, .character:
            return "str"
        case .void:
            return "None"
        case .list(let inner):
            return "List[\(inner.pythonType)]"
        case .listNode:
            return "Optional[ListNode]"
        case .treeNode:
            return "Optional[TreeNode]"
        case .unknown:
            return "Any"
        }
    }
}
