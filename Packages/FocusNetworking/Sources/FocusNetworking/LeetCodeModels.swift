import Foundation

public struct LeetCodeRestSubmissionListResponse: Decodable {
    public let submissions: [LeetCodeRestSubmission]

    enum CodingKeys: String, CodingKey {
        case submission
        case submissions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        submissions = (try? container.decode([LeetCodeRestSubmission].self, forKey: .submission))
            ?? (try? container.decode([LeetCodeRestSubmission].self, forKey: .submissions))
            ?? []
    }
}

public struct LeetCodeRestSubmission: Decodable {
    public let titleSlug: String
    public let statusDisplay: String?
    public let timestamp: String?
    public let lang: String?

    enum CodingKeys: String, CodingKey {
        case titleSlug
        case statusDisplay
        case timestamp
        case lang
    }
}

public struct LeetCodeRestProblemResponse: Decodable {
    public let title: String
    public let content: String
    public let exampleTestcases: String
    public let sampleTestCase: String
    public let difficulty: String
    public let codeSnippets: [LeetCodeRestCodeSnippet]
    public let metaData: String?

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

    public init(from decoder: Decoder) throws {
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

public struct LeetCodeRestCodeSnippet: Decodable {
    public let lang: String?
    public let langSlug: String
    public let code: String
}

public struct LeetCodeUserProfileResponse: Decodable {
    public let username: String?

    enum CodingKeys: String, CodingKey {
        case username
        case profile
        case userProfile
    }

    public init(from decoder: Decoder) throws {
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

public struct LeetCodeUserProfile: Decodable {
    public let username: String?
}

public struct LeetCodeGraphQLResponse<T: Decodable>: Decodable {
    public let data: T?
    public let errors: [LeetCodeGraphQLError]?
}

public struct LeetCodeGraphQLError: Decodable {
    public let message: String
}

public struct LeetCodeRecentAcSubmissionsData: Decodable {
    public let recentAcSubmissionList: [LeetCodeGraphQLSubmission]
}

public struct LeetCodeGraphQLSubmission: Decodable {
    public let titleSlug: String
}

public struct LeetCodeGraphQLQuestionData: Decodable {
    public let question: LeetCodeGraphQLQuestion?
}

public struct LeetCodeGraphQLQuestion: Decodable {
    public let title: String
    public let content: String
    public let exampleTestcases: String
    public let sampleTestCase: String
    public let difficulty: String
    public let codeSnippets: [LeetCodeRestCodeSnippet]
    public let metaData: String?
    public let questionId: String?
}

public struct LeetCodeMetaData: Decodable {
    public let name: String?
    public let params: [LeetCodeMetaParam]?
    public let returnType: LeetCodeMetaReturn?
    public let className: String?
    public let methods: [LeetCodeMetaMethod]?

    enum CodingKeys: String, CodingKey {
        case name
        case params
        case returnType = "return"
        case className
        case classname
        case methods
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        params = try? container.decode([LeetCodeMetaParam].self, forKey: .params)
        returnType = try? container.decode(LeetCodeMetaReturn.self, forKey: .returnType)
        className = (try? container.decode(String.self, forKey: .className))
            ?? (try? container.decode(String.self, forKey: .classname))
        methods = try? container.decode([LeetCodeMetaMethod].self, forKey: .methods)
    }
}

public struct LeetCodeMetaParam: Decodable {
    public let name: String?
    public let type: String

    public init(name: String?, type: String) {
        self.name = name
        self.type = type
    }
}

public struct LeetCodeMetaReturn: Decodable {
    public let type: String

    public init(type: String) {
        self.type = type
    }
}

public struct LeetCodeMetaMethod: Decodable {
    public let name: String
    public let params: [LeetCodeMetaParam]
    public let returnType: LeetCodeMetaReturn?

    enum CodingKeys: String, CodingKey {
        case name
        case params
        case returnType = "return"
    }

    public init(name: String, params: [LeetCodeMetaParam], returnType: LeetCodeMetaReturn?) {
        self.name = name
        self.params = params
        self.returnType = returnType
    }
}

extension LeetCodeMetaData {
    public static func decode(from raw: String?) -> LeetCodeMetaData? {
        guard let raw, let data = raw.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(LeetCodeMetaData.self, from: data)
    }

    public var isClassDesign: Bool {
        let hasClassName = !(className?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasMethods = !(methods?.isEmpty ?? true)
        return hasClassName && hasMethods
    }

    public var primaryParams: [LeetCodeMetaParam] {
        params ?? []
    }
}
