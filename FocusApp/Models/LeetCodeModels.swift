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
    let questionId: String?
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
