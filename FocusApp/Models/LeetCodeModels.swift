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

    enum CodingKeys: String, CodingKey {
        case title
        case questionTitle
        case content
        case question
        case exampleTestcases
        case sampleTestCase
        case difficulty
        case codeSnippets
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
