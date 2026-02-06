import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
}

struct Problem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let difficulty: Difficulty
    let url: String
    let leetcodeNumber: Int?

    enum CodingKeys: String, CodingKey {
        case name, difficulty, url, leetcodeNumber
    }

    init(name: String, difficulty: Difficulty, url: String, leetcodeNumber: Int? = nil) {
        self.name = name
        self.difficulty = difficulty
        self.url = url
        self.leetcodeNumber = leetcodeNumber
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.url = try container.decode(String.self, forKey: .url)
        self.leetcodeNumber = try container.decodeIfPresent(Int.self, forKey: .leetcodeNumber)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(leetcodeNumber, forKey: .leetcodeNumber)
    }

    var displayName: String {
        guard let leetcodeNumber else { return name }
        return "#\(leetcodeNumber) \(name)"
    }
}

struct Day: Identifiable, Codable {
    let id: Int
    let date: String
    let topic: String
    let problems: [Problem]
}

struct PlanData: Codable {
    let preCompletedTopics: [String]
    let days: [Day]
}

enum PlanDataLoader {
    static func load() -> PlanData {
        let locale = Locale.current.language.languageCode?.identifier
        let localizedURL = Bundle.main.url(
            forResource: "Plan",
            withExtension: "json",
            subdirectory: nil,
            localization: locale
        )

        if let url = localizedURL ?? Bundle.main.url(forResource: "Plan", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let plan = try? JSONDecoder().decode(PlanData.self, from: data) {
            return plan
        }

        return fallbackPlanData
    }
}

// Fallback plan data if bundled JSON is missing or invalid.
private let fallbackPlanData = PlanData(
    preCompletedTopics: [
        "Arrays & Hashing",
        "Two Pointers",
        "Sliding Window"
    ],
    days: [
    Day(id: 1, date: "Feb 6", topic: "Priority Sprint I", problems: [
        Problem(name: "Two Sum", difficulty: .easy, url: "https://leetcode.com/problems/two-sum/", leetcodeNumber: 1),
        Problem(name: "Valid Parentheses", difficulty: .easy, url: "https://leetcode.com/problems/valid-parentheses/", leetcodeNumber: 20),
        Problem(name: "Reverse Linked List", difficulty: .easy, url: "https://leetcode.com/problems/reverse-linked-list/", leetcodeNumber: 206),
        Problem(
            name: "Longest Substring Without Repeating Characters",
            difficulty: .medium,
            url: "https://leetcode.com/problems/longest-substring-without-repeating-characters/",
            leetcodeNumber: 3
        ),
        Problem(name: "Top K Frequent Elements", difficulty: .medium, url: "https://leetcode.com/problems/top-k-frequent-elements/", leetcodeNumber: 347),
        Problem(name: "Search in Rotated Sorted Array", difficulty: .medium, url: "https://leetcode.com/problems/search-in-rotated-sorted-array/", leetcodeNumber: 33),
        Problem(name: "Spiral Matrix", difficulty: .medium, url: "https://leetcode.com/problems/spiral-matrix/", leetcodeNumber: 54),
        Problem(name: "Reverse Linked List II", difficulty: .medium, url: "https://leetcode.com/problems/reverse-linked-list-ii/", leetcodeNumber: 92),
        Problem(name: "Coin Change", difficulty: .medium, url: "https://leetcode.com/problems/coin-change/", leetcodeNumber: 322)
    ]),
    Day(id: 2, date: "Feb 7", topic: "Priority Sprint II", problems: [
        Problem(name: "Merge Two Sorted Lists", difficulty: .easy, url: "https://leetcode.com/problems/merge-two-sorted-lists/", leetcodeNumber: 21),
        Problem(name: "Linked List Cycle", difficulty: .easy, url: "https://leetcode.com/problems/linked-list-cycle/", leetcodeNumber: 141),
        Problem(name: "Contains Duplicate", difficulty: .easy, url: "https://leetcode.com/problems/contains-duplicate/", leetcodeNumber: 217),
        Problem(name: "Best Time to Buy and Sell Stock", difficulty: .easy, url: "https://leetcode.com/problems/best-time-to-buy-and-sell-stock/", leetcodeNumber: 121),
        Problem(name: "Valid Anagram", difficulty: .easy, url: "https://leetcode.com/problems/valid-anagram/", leetcodeNumber: 242),
        Problem(name: "Ransom Note", difficulty: .easy, url: "https://leetcode.com/problems/ransom-note/", leetcodeNumber: 383),
        Problem(name: "Binary Search", difficulty: .easy, url: "https://leetcode.com/problems/binary-search/", leetcodeNumber: 704),
        Problem(name: "Climbing Stairs", difficulty: .easy, url: "https://leetcode.com/problems/climbing-stairs/", leetcodeNumber: 70),
        Problem(name: "Group Anagrams", difficulty: .medium, url: "https://leetcode.com/problems/group-anagrams/", leetcodeNumber: 49),
        Problem(name: "Product of Array Except Self", difficulty: .medium, url: "https://leetcode.com/problems/product-of-array-except-self/", leetcodeNumber: 238),
        Problem(name: "Subarray Sum Equals K", difficulty: .medium, url: "https://leetcode.com/problems/subarray-sum-equals-k/", leetcodeNumber: 560),
        Problem(name: "Permutation in String", difficulty: .medium, url: "https://leetcode.com/problems/permutation-in-string/", leetcodeNumber: 567),
        Problem(name: "3Sum", difficulty: .medium, url: "https://leetcode.com/problems/3sum/", leetcodeNumber: 15),
        Problem(name: "Merge Intervals", difficulty: .medium, url: "https://leetcode.com/problems/merge-intervals/", leetcodeNumber: 56),
        Problem(name: "Number of Islands", difficulty: .medium, url: "https://leetcode.com/problems/number-of-islands/", leetcodeNumber: 200),
        Problem(name: "Rotting Oranges", difficulty: .medium, url: "https://leetcode.com/problems/rotting-oranges/", leetcodeNumber: 994)
    ]),
    Day(id: 3, date: "Feb 8", topic: "Linked List", problems: [
        Problem(name: "Reverse Linked List", difficulty: .easy, url: "https://leetcode.com/problems/reverse-linked-list/", leetcodeNumber: 206),
        Problem(name: "Merge Two Sorted Lists", difficulty: .easy, url: "https://leetcode.com/problems/merge-two-sorted-lists/", leetcodeNumber: 21),
        Problem(name: "Reorder List", difficulty: .medium, url: "https://leetcode.com/problems/reorder-list/", leetcodeNumber: 143),
        Problem(name: "Remove Nth Node From End of List", difficulty: .medium, url: "https://leetcode.com/problems/remove-nth-node-from-end-of-list/", leetcodeNumber: 19),
        Problem(name: "Linked List Cycle", difficulty: .easy, url: "https://leetcode.com/problems/linked-list-cycle/", leetcodeNumber: 141)
    ]),
    Day(id: 4, date: "Feb 9", topic: "Linked List (cont.)", problems: [
        Problem(name: "Merge K Sorted Lists", difficulty: .medium, url: "https://leetcode.com/problems/merge-k-sorted-lists/", leetcodeNumber: 23),
        Problem(name: "Copy List with Random Pointer", difficulty: .medium, url: "https://leetcode.com/problems/copy-list-with-random-pointer/", leetcodeNumber: 138),
        Problem(name: "Add Two Numbers", difficulty: .medium, url: "https://leetcode.com/problems/add-two-numbers/", leetcodeNumber: 2),
        Problem(name: "Find the Duplicate Number", difficulty: .medium, url: "https://leetcode.com/problems/find-the-duplicate-number/", leetcodeNumber: 287),
        Problem(name: "LRU Cache", difficulty: .medium, url: "https://leetcode.com/problems/lru-cache/", leetcodeNumber: 146)
    ]),
    Day(id: 5, date: "Feb 10", topic: "Trees", problems: [
        Problem(name: "Invert Binary Tree", difficulty: .easy, url: "https://leetcode.com/problems/invert-binary-tree/", leetcodeNumber: 226),
        Problem(name: "Maximum Depth of Binary Tree", difficulty: .easy, url: "https://leetcode.com/problems/maximum-depth-of-binary-tree/", leetcodeNumber: 104),
        Problem(name: "Same Tree", difficulty: .easy, url: "https://leetcode.com/problems/same-tree/", leetcodeNumber: 100),
        Problem(name: "Subtree of Another Tree", difficulty: .easy, url: "https://leetcode.com/problems/subtree-of-another-tree/", leetcodeNumber: 572),
        Problem(name: "Lowest Common Ancestor of BST", difficulty: .medium, url: "https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/", leetcodeNumber: 235)
    ]),
    Day(id: 6, date: "Feb 11", topic: "Priority Practice I", problems: [
        Problem(name: "Two Sum", difficulty: .easy, url: "https://leetcode.com/problems/two-sum/", leetcodeNumber: 1),
        Problem(name: "Valid Parentheses", difficulty: .easy, url: "https://leetcode.com/problems/valid-parentheses/", leetcodeNumber: 20),
        Problem(name: "Reverse Linked List", difficulty: .easy, url: "https://leetcode.com/problems/reverse-linked-list/", leetcodeNumber: 206)
    ]),
    Day(id: 7, date: "Feb 12", topic: "Priority Practice II", problems: [
        Problem(
            name: "Longest Substring Without Repeating Characters",
            difficulty: .medium,
            url: "https://leetcode.com/problems/longest-substring-without-repeating-characters/",
            leetcodeNumber: 3
        ),
        Problem(name: "Top K Frequent Elements", difficulty: .medium, url: "https://leetcode.com/problems/top-k-frequent-elements/", leetcodeNumber: 347),
        Problem(name: "Search in Rotated Sorted Array", difficulty: .medium, url: "https://leetcode.com/problems/search-in-rotated-sorted-array/", leetcodeNumber: 33)
    ]),
    Day(id: 8, date: "Feb 13", topic: "Priority Practice III", problems: [
        Problem(name: "Spiral Matrix", difficulty: .medium, url: "https://leetcode.com/problems/spiral-matrix/", leetcodeNumber: 54),
        Problem(name: "Reverse Linked List II", difficulty: .medium, url: "https://leetcode.com/problems/reverse-linked-list-ii/", leetcodeNumber: 92),
        Problem(name: "Coin Change", difficulty: .medium, url: "https://leetcode.com/problems/coin-change/", leetcodeNumber: 322)
    ]),
    Day(id: 9, date: "Feb 14", topic: "Heap (cont.) + Backtracking", problems: [
        Problem(name: "Find Median from Data Stream", difficulty: .medium, url: "https://leetcode.com/problems/find-median-from-data-stream/", leetcodeNumber: 295),
        Problem(name: "Subsets", difficulty: .medium, url: "https://leetcode.com/problems/subsets/", leetcodeNumber: 78),
        Problem(name: "Combination Sum", difficulty: .medium, url: "https://leetcode.com/problems/combination-sum/", leetcodeNumber: 39),
        Problem(name: "Permutations", difficulty: .medium, url: "https://leetcode.com/problems/permutations/", leetcodeNumber: 46),
        Problem(name: "Subsets II", difficulty: .medium, url: "https://leetcode.com/problems/subsets-ii/", leetcodeNumber: 90)
    ]),
    Day(id: 10, date: "Feb 15", topic: "Backtracking (cont.)", problems: [
        Problem(name: "Combination Sum II", difficulty: .medium, url: "https://leetcode.com/problems/combination-sum-ii/", leetcodeNumber: 40),
        Problem(name: "Word Search", difficulty: .medium, url: "https://leetcode.com/problems/word-search/", leetcodeNumber: 79),
        Problem(name: "Palindrome Partitioning", difficulty: .medium, url: "https://leetcode.com/problems/palindrome-partitioning/", leetcodeNumber: 131),
        Problem(name: "Letter Combinations of Phone Number", difficulty: .medium, url: "https://leetcode.com/problems/letter-combinations-of-a-phone-number/", leetcodeNumber: 17),
        Problem(name: "N-Queens", difficulty: .medium, url: "https://leetcode.com/problems/n-queens/", leetcodeNumber: 51)
    ]),
    Day(id: 11, date: "Feb 16", topic: "Graphs", problems: [
        Problem(name: "Number of Islands", difficulty: .medium, url: "https://leetcode.com/problems/number-of-islands/", leetcodeNumber: 200),
        Problem(name: "Clone Graph", difficulty: .medium, url: "https://leetcode.com/problems/clone-graph/", leetcodeNumber: 133),
        Problem(name: "Max Area of Island", difficulty: .medium, url: "https://leetcode.com/problems/max-area-of-island/", leetcodeNumber: 695),
        Problem(name: "Pacific Atlantic Water Flow", difficulty: .medium, url: "https://leetcode.com/problems/pacific-atlantic-water-flow/", leetcodeNumber: 417),
        Problem(name: "Surrounded Regions", difficulty: .medium, url: "https://leetcode.com/problems/surrounded-regions/", leetcodeNumber: 130)
    ]),
    Day(id: 12, date: "Feb 17", topic: "Graphs (cont.)", problems: [
        Problem(name: "Rotting Oranges", difficulty: .medium, url: "https://leetcode.com/problems/rotting-oranges/", leetcodeNumber: 994),
        Problem(name: "Course Schedule", difficulty: .medium, url: "https://leetcode.com/problems/course-schedule/", leetcodeNumber: 207),
        Problem(name: "Course Schedule II", difficulty: .medium, url: "https://leetcode.com/problems/course-schedule-ii/", leetcodeNumber: 210),
        Problem(name: "Graph Valid Tree", difficulty: .medium, url: "https://leetcode.com/problems/graph-valid-tree/", leetcodeNumber: 261),
        Problem(name: "Number of Connected Components in Graph", difficulty: .medium, url: "https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/", leetcodeNumber: 323)
    ]),
    Day(id: 13, date: "Feb 18", topic: "Advanced Graphs", problems: [
        Problem(name: "Redundant Connection", difficulty: .medium, url: "https://leetcode.com/problems/redundant-connection/", leetcodeNumber: 684),
        Problem(name: "Word Ladder", difficulty: .medium, url: "https://leetcode.com/problems/word-ladder/", leetcodeNumber: 127),
        Problem(name: "Alien Dictionary", difficulty: .medium, url: "https://leetcode.com/problems/alien-dictionary/", leetcodeNumber: 269),
        Problem(name: "Min Cost to Connect All Points", difficulty: .medium, url: "https://leetcode.com/problems/min-cost-to-connect-all-points/", leetcodeNumber: 1584),
        Problem(name: "Network Delay Time", difficulty: .medium, url: "https://leetcode.com/problems/network-delay-time/", leetcodeNumber: 743)
    ]),
    Day(id: 14, date: "Feb 19", topic: "1-D Dynamic Programming", problems: [
        Problem(name: "Climbing Stairs", difficulty: .easy, url: "https://leetcode.com/problems/climbing-stairs/", leetcodeNumber: 70),
        Problem(name: "House Robber", difficulty: .medium, url: "https://leetcode.com/problems/house-robber/", leetcodeNumber: 198),
        Problem(name: "House Robber II", difficulty: .medium, url: "https://leetcode.com/problems/house-robber-ii/", leetcodeNumber: 213),
        Problem(name: "Longest Palindromic Substring", difficulty: .medium, url: "https://leetcode.com/problems/longest-palindromic-substring/", leetcodeNumber: 5),
        Problem(name: "Palindromic Substrings", difficulty: .medium, url: "https://leetcode.com/problems/palindromic-substrings/", leetcodeNumber: 647)
    ]),
    Day(id: 15, date: "Feb 20", topic: "1-D DP (cont.) + 2-D DP Intro", problems: [
        Problem(name: "Decode Ways", difficulty: .medium, url: "https://leetcode.com/problems/decode-ways/", leetcodeNumber: 91),
        Problem(name: "Coin Change", difficulty: .medium, url: "https://leetcode.com/problems/coin-change/", leetcodeNumber: 322),
        Problem(name: "Maximum Product Subarray", difficulty: .medium, url: "https://leetcode.com/problems/maximum-product-subarray/", leetcodeNumber: 152),
        Problem(name: "Word Break", difficulty: .medium, url: "https://leetcode.com/problems/word-break/", leetcodeNumber: 139),
        Problem(name: "Longest Increasing Subsequence", difficulty: .medium, url: "https://leetcode.com/problems/longest-increasing-subsequence/", leetcodeNumber: 300)
    ])
    ]
)

let planData = PlanDataLoader.load()
let preCompletedTopics = planData.preCompletedTopics
let dsaPlan = planData.days
