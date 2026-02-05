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
    Day(id: 1, date: "Feb 3", topic: "Linked List", problems: [
        Problem(name: "Reverse Linked List", difficulty: .easy, url: "https://leetcode.com/problems/reverse-linked-list/", leetcodeNumber: 206),
        Problem(name: "Merge Two Sorted Lists", difficulty: .easy, url: "https://leetcode.com/problems/merge-two-sorted-lists/", leetcodeNumber: 21),
        Problem(name: "Reorder List", difficulty: .medium, url: "https://leetcode.com/problems/reorder-list/", leetcodeNumber: 143),
        Problem(name: "Remove Nth Node From End of List", difficulty: .medium, url: "https://leetcode.com/problems/remove-nth-node-from-end-of-list/", leetcodeNumber: 19),
        Problem(name: "Linked List Cycle", difficulty: .easy, url: "https://leetcode.com/problems/linked-list-cycle/", leetcodeNumber: 141)
    ]),
    Day(id: 2, date: "Feb 4", topic: "Linked List (cont.)", problems: [
        Problem(name: "Merge K Sorted Lists", difficulty: .medium, url: "https://leetcode.com/problems/merge-k-sorted-lists/", leetcodeNumber: 23),
        Problem(name: "Copy List with Random Pointer", difficulty: .medium, url: "https://leetcode.com/problems/copy-list-with-random-pointer/", leetcodeNumber: 138),
        Problem(name: "Add Two Numbers", difficulty: .medium, url: "https://leetcode.com/problems/add-two-numbers/", leetcodeNumber: 2),
        Problem(name: "Find the Duplicate Number", difficulty: .medium, url: "https://leetcode.com/problems/find-the-duplicate-number/", leetcodeNumber: 287),
        Problem(name: "LRU Cache", difficulty: .medium, url: "https://leetcode.com/problems/lru-cache/", leetcodeNumber: 146)
    ]),
    Day(id: 3, date: "Feb 5", topic: "Trees", problems: [
        Problem(name: "Invert Binary Tree", difficulty: .easy, url: "https://leetcode.com/problems/invert-binary-tree/", leetcodeNumber: 226),
        Problem(name: "Maximum Depth of Binary Tree", difficulty: .easy, url: "https://leetcode.com/problems/maximum-depth-of-binary-tree/", leetcodeNumber: 104),
        Problem(name: "Same Tree", difficulty: .easy, url: "https://leetcode.com/problems/same-tree/", leetcodeNumber: 100),
        Problem(name: "Subtree of Another Tree", difficulty: .easy, url: "https://leetcode.com/problems/subtree-of-another-tree/", leetcodeNumber: 572),
        Problem(name: "Lowest Common Ancestor of BST", difficulty: .medium, url: "https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/", leetcodeNumber: 235)
    ]),
    Day(id: 4, date: "Feb 6", topic: "Trees (cont.)", problems: [
        Problem(name: "Binary Tree Level Order Traversal", difficulty: .medium, url: "https://leetcode.com/problems/binary-tree-level-order-traversal/", leetcodeNumber: 102),
        Problem(name: "Validate Binary Search Tree", difficulty: .medium, url: "https://leetcode.com/problems/validate-binary-search-tree/", leetcodeNumber: 98),
        Problem(name: "Kth Smallest Element in BST", difficulty: .medium, url: "https://leetcode.com/problems/kth-smallest-element-in-a-bst/", leetcodeNumber: 230),
        Problem(
            name: "Construct Binary Tree from Preorder and Inorder",
            difficulty: .medium,
            url: "https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/",
            leetcodeNumber: 105
        ),
        Problem(name: "Binary Tree Maximum Path Sum", difficulty: .medium, url: "https://leetcode.com/problems/binary-tree-maximum-path-sum/", leetcodeNumber: 124)
    ]),
    Day(id: 5, date: "Feb 7", topic: "Tries", problems: [
        Problem(name: "Implement Trie (Prefix Tree)", difficulty: .medium, url: "https://leetcode.com/problems/implement-trie-prefix-tree/", leetcodeNumber: 208),
        Problem(name: "Design Add and Search Words Data Structure", difficulty: .medium, url: "https://leetcode.com/problems/design-add-and-search-words-data-structure/", leetcodeNumber: 211),
        Problem(name: "Word Search II", difficulty: .medium, url: "https://leetcode.com/problems/word-search-ii/", leetcodeNumber: 212),
        Problem(name: "Count Good Nodes in Binary Tree", difficulty: .medium, url: "https://leetcode.com/problems/count-good-nodes-in-binary-tree/", leetcodeNumber: 1448),
        Problem(name: "Serialize and Deserialize Binary Tree", difficulty: .medium, url: "https://leetcode.com/problems/serialize-and-deserialize-binary-tree/", leetcodeNumber: 297)
    ]),
    Day(id: 6, date: "Feb 8", topic: "Heap / Priority Queue", problems: [
        Problem(name: "Kth Largest Element in a Stream", difficulty: .easy, url: "https://leetcode.com/problems/kth-largest-element-in-a-stream/", leetcodeNumber: 703),
        Problem(name: "Last Stone Weight", difficulty: .easy, url: "https://leetcode.com/problems/last-stone-weight/", leetcodeNumber: 1046),
        Problem(name: "K Closest Points to Origin", difficulty: .medium, url: "https://leetcode.com/problems/k-closest-points-to-origin/", leetcodeNumber: 973),
        Problem(name: "Task Scheduler", difficulty: .medium, url: "https://leetcode.com/problems/task-scheduler/", leetcodeNumber: 621),
        Problem(name: "Design Twitter", difficulty: .medium, url: "https://leetcode.com/problems/design-twitter/", leetcodeNumber: 355)
    ]),
    Day(id: 7, date: "Feb 9", topic: "Heap (cont.) + Backtracking", problems: [
        Problem(name: "Find Median from Data Stream", difficulty: .medium, url: "https://leetcode.com/problems/find-median-from-data-stream/", leetcodeNumber: 295),
        Problem(name: "Subsets", difficulty: .medium, url: "https://leetcode.com/problems/subsets/", leetcodeNumber: 78),
        Problem(name: "Combination Sum", difficulty: .medium, url: "https://leetcode.com/problems/combination-sum/", leetcodeNumber: 39),
        Problem(name: "Permutations", difficulty: .medium, url: "https://leetcode.com/problems/permutations/", leetcodeNumber: 46),
        Problem(name: "Subsets II", difficulty: .medium, url: "https://leetcode.com/problems/subsets-ii/", leetcodeNumber: 90)
    ]),
    Day(id: 8, date: "Feb 10", topic: "Backtracking (cont.)", problems: [
        Problem(name: "Combination Sum II", difficulty: .medium, url: "https://leetcode.com/problems/combination-sum-ii/", leetcodeNumber: 40),
        Problem(name: "Word Search", difficulty: .medium, url: "https://leetcode.com/problems/word-search/", leetcodeNumber: 79),
        Problem(name: "Palindrome Partitioning", difficulty: .medium, url: "https://leetcode.com/problems/palindrome-partitioning/", leetcodeNumber: 131),
        Problem(name: "Letter Combinations of Phone Number", difficulty: .medium, url: "https://leetcode.com/problems/letter-combinations-of-a-phone-number/", leetcodeNumber: 17),
        Problem(name: "N-Queens", difficulty: .medium, url: "https://leetcode.com/problems/n-queens/", leetcodeNumber: 51)
    ]),
    Day(id: 9, date: "Feb 11", topic: "Graphs", problems: [
        Problem(name: "Number of Islands", difficulty: .medium, url: "https://leetcode.com/problems/number-of-islands/", leetcodeNumber: 200),
        Problem(name: "Clone Graph", difficulty: .medium, url: "https://leetcode.com/problems/clone-graph/", leetcodeNumber: 133),
        Problem(name: "Max Area of Island", difficulty: .medium, url: "https://leetcode.com/problems/max-area-of-island/", leetcodeNumber: 695),
        Problem(name: "Pacific Atlantic Water Flow", difficulty: .medium, url: "https://leetcode.com/problems/pacific-atlantic-water-flow/", leetcodeNumber: 417),
        Problem(name: "Surrounded Regions", difficulty: .medium, url: "https://leetcode.com/problems/surrounded-regions/", leetcodeNumber: 130)
    ]),
    Day(id: 10, date: "Feb 12", topic: "Graphs (cont.)", problems: [
        Problem(name: "Rotting Oranges", difficulty: .medium, url: "https://leetcode.com/problems/rotting-oranges/", leetcodeNumber: 994),
        Problem(name: "Course Schedule", difficulty: .medium, url: "https://leetcode.com/problems/course-schedule/", leetcodeNumber: 207),
        Problem(name: "Course Schedule II", difficulty: .medium, url: "https://leetcode.com/problems/course-schedule-ii/", leetcodeNumber: 210),
        Problem(name: "Graph Valid Tree", difficulty: .medium, url: "https://leetcode.com/problems/graph-valid-tree/", leetcodeNumber: 261),
        Problem(name: "Number of Connected Components in Graph", difficulty: .medium, url: "https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/", leetcodeNumber: 323)
    ]),
    Day(id: 11, date: "Feb 13", topic: "Advanced Graphs", problems: [
        Problem(name: "Redundant Connection", difficulty: .medium, url: "https://leetcode.com/problems/redundant-connection/", leetcodeNumber: 684),
        Problem(name: "Word Ladder", difficulty: .medium, url: "https://leetcode.com/problems/word-ladder/", leetcodeNumber: 127),
        Problem(name: "Alien Dictionary", difficulty: .medium, url: "https://leetcode.com/problems/alien-dictionary/", leetcodeNumber: 269),
        Problem(name: "Min Cost to Connect All Points", difficulty: .medium, url: "https://leetcode.com/problems/min-cost-to-connect-all-points/", leetcodeNumber: 1584),
        Problem(name: "Network Delay Time", difficulty: .medium, url: "https://leetcode.com/problems/network-delay-time/", leetcodeNumber: 743)
    ]),
    Day(id: 12, date: "Feb 14", topic: "1-D Dynamic Programming", problems: [
        Problem(name: "Climbing Stairs", difficulty: .easy, url: "https://leetcode.com/problems/climbing-stairs/", leetcodeNumber: 70),
        Problem(name: "House Robber", difficulty: .medium, url: "https://leetcode.com/problems/house-robber/", leetcodeNumber: 198),
        Problem(name: "House Robber II", difficulty: .medium, url: "https://leetcode.com/problems/house-robber-ii/", leetcodeNumber: 213),
        Problem(name: "Longest Palindromic Substring", difficulty: .medium, url: "https://leetcode.com/problems/longest-palindromic-substring/", leetcodeNumber: 5),
        Problem(name: "Palindromic Substrings", difficulty: .medium, url: "https://leetcode.com/problems/palindromic-substrings/", leetcodeNumber: 647)
    ]),
    Day(id: 13, date: "Feb 15", topic: "1-D DP (cont.) + 2-D DP Intro", problems: [
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
