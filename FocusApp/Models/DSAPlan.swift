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

    enum CodingKeys: String, CodingKey {
        case name, difficulty, url
    }

    init(name: String, difficulty: Difficulty, url: String) {
        self.name = name
        self.difficulty = difficulty
        self.url = url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.url = try container.decode(String.self, forKey: .url)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(url, forKey: .url)
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
        Problem(name: "Reverse Linked List", difficulty: .easy, url: "https://leetcode.com/problems/reverse-linked-list/"),
        Problem(name: "Merge Two Sorted Lists", difficulty: .easy, url: "https://leetcode.com/problems/merge-two-sorted-lists/"),
        Problem(name: "Reorder List", difficulty: .medium, url: "https://leetcode.com/problems/reorder-list/"),
        Problem(name: "Remove Nth Node From End of List", difficulty: .medium, url: "https://leetcode.com/problems/remove-nth-node-from-end-of-list/"),
        Problem(name: "Linked List Cycle", difficulty: .easy, url: "https://leetcode.com/problems/linked-list-cycle/")
    ]),
    Day(id: 2, date: "Feb 4", topic: "Linked List (cont.)", problems: [
        Problem(name: "Merge K Sorted Lists", difficulty: .medium, url: "https://leetcode.com/problems/merge-k-sorted-lists/"),
        Problem(name: "Copy List with Random Pointer", difficulty: .medium, url: "https://leetcode.com/problems/copy-list-with-random-pointer/"),
        Problem(name: "Add Two Numbers", difficulty: .medium, url: "https://leetcode.com/problems/add-two-numbers/"),
        Problem(name: "Find the Duplicate Number", difficulty: .medium, url: "https://leetcode.com/problems/find-the-duplicate-number/"),
        Problem(name: "LRU Cache", difficulty: .medium, url: "https://leetcode.com/problems/lru-cache/")
    ]),
    Day(id: 3, date: "Feb 5", topic: "Trees", problems: [
        Problem(name: "Invert Binary Tree", difficulty: .easy, url: "https://leetcode.com/problems/invert-binary-tree/"),
        Problem(name: "Maximum Depth of Binary Tree", difficulty: .easy, url: "https://leetcode.com/problems/maximum-depth-of-binary-tree/"),
        Problem(name: "Same Tree", difficulty: .easy, url: "https://leetcode.com/problems/same-tree/"),
        Problem(name: "Subtree of Another Tree", difficulty: .easy, url: "https://leetcode.com/problems/subtree-of-another-tree/"),
        Problem(name: "Lowest Common Ancestor of BST", difficulty: .medium, url: "https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/")
    ]),
    Day(id: 4, date: "Feb 6", topic: "Trees (cont.)", problems: [
        Problem(name: "Binary Tree Level Order Traversal", difficulty: .medium, url: "https://leetcode.com/problems/binary-tree-level-order-traversal/"),
        Problem(name: "Validate Binary Search Tree", difficulty: .medium, url: "https://leetcode.com/problems/validate-binary-search-tree/"),
        Problem(name: "Kth Smallest Element in BST", difficulty: .medium, url: "https://leetcode.com/problems/kth-smallest-element-in-a-bst/"),
        Problem(name: "Construct Binary Tree from Preorder and Inorder", difficulty: .medium, url: "https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/"),
        Problem(name: "Binary Tree Maximum Path Sum", difficulty: .medium, url: "https://leetcode.com/problems/binary-tree-maximum-path-sum/")
    ]),
    Day(id: 5, date: "Feb 7", topic: "Tries", problems: [
        Problem(name: "Implement Trie (Prefix Tree)", difficulty: .medium, url: "https://leetcode.com/problems/implement-trie-prefix-tree/"),
        Problem(name: "Design Add and Search Words Data Structure", difficulty: .medium, url: "https://leetcode.com/problems/design-add-and-search-words-data-structure/"),
        Problem(name: "Word Search II", difficulty: .medium, url: "https://leetcode.com/problems/word-search-ii/"),
        Problem(name: "Count Good Nodes in Binary Tree", difficulty: .medium, url: "https://leetcode.com/problems/count-good-nodes-in-binary-tree/"),
        Problem(name: "Serialize and Deserialize Binary Tree", difficulty: .medium, url: "https://leetcode.com/problems/serialize-and-deserialize-binary-tree/")
    ]),
    Day(id: 6, date: "Feb 8", topic: "Heap / Priority Queue", problems: [
        Problem(name: "Kth Largest Element in a Stream", difficulty: .easy, url: "https://leetcode.com/problems/kth-largest-element-in-a-stream/"),
        Problem(name: "Last Stone Weight", difficulty: .easy, url: "https://leetcode.com/problems/last-stone-weight/"),
        Problem(name: "K Closest Points to Origin", difficulty: .medium, url: "https://leetcode.com/problems/k-closest-points-to-origin/"),
        Problem(name: "Task Scheduler", difficulty: .medium, url: "https://leetcode.com/problems/task-scheduler/"),
        Problem(name: "Design Twitter", difficulty: .medium, url: "https://leetcode.com/problems/design-twitter/")
    ]),
    Day(id: 7, date: "Feb 9", topic: "Heap (cont.) + Backtracking", problems: [
        Problem(name: "Find Median from Data Stream", difficulty: .medium, url: "https://leetcode.com/problems/find-median-from-data-stream/"),
        Problem(name: "Subsets", difficulty: .medium, url: "https://leetcode.com/problems/subsets/"),
        Problem(name: "Combination Sum", difficulty: .medium, url: "https://leetcode.com/problems/combination-sum/"),
        Problem(name: "Permutations", difficulty: .medium, url: "https://leetcode.com/problems/permutations/"),
        Problem(name: "Subsets II", difficulty: .medium, url: "https://leetcode.com/problems/subsets-ii/")
    ]),
    Day(id: 8, date: "Feb 10", topic: "Backtracking (cont.)", problems: [
        Problem(name: "Combination Sum II", difficulty: .medium, url: "https://leetcode.com/problems/combination-sum-ii/"),
        Problem(name: "Word Search", difficulty: .medium, url: "https://leetcode.com/problems/word-search/"),
        Problem(name: "Palindrome Partitioning", difficulty: .medium, url: "https://leetcode.com/problems/palindrome-partitioning/"),
        Problem(name: "Letter Combinations of Phone Number", difficulty: .medium, url: "https://leetcode.com/problems/letter-combinations-of-a-phone-number/"),
        Problem(name: "N-Queens", difficulty: .medium, url: "https://leetcode.com/problems/n-queens/")
    ]),
    Day(id: 9, date: "Feb 11", topic: "Graphs", problems: [
        Problem(name: "Number of Islands", difficulty: .medium, url: "https://leetcode.com/problems/number-of-islands/"),
        Problem(name: "Clone Graph", difficulty: .medium, url: "https://leetcode.com/problems/clone-graph/"),
        Problem(name: "Max Area of Island", difficulty: .medium, url: "https://leetcode.com/problems/max-area-of-island/"),
        Problem(name: "Pacific Atlantic Water Flow", difficulty: .medium, url: "https://leetcode.com/problems/pacific-atlantic-water-flow/"),
        Problem(name: "Surrounded Regions", difficulty: .medium, url: "https://leetcode.com/problems/surrounded-regions/")
    ]),
    Day(id: 10, date: "Feb 12", topic: "Graphs (cont.)", problems: [
        Problem(name: "Rotting Oranges", difficulty: .medium, url: "https://leetcode.com/problems/rotting-oranges/"),
        Problem(name: "Course Schedule", difficulty: .medium, url: "https://leetcode.com/problems/course-schedule/"),
        Problem(name: "Course Schedule II", difficulty: .medium, url: "https://leetcode.com/problems/course-schedule-ii/"),
        Problem(name: "Graph Valid Tree", difficulty: .medium, url: "https://leetcode.com/problems/graph-valid-tree/"),
        Problem(name: "Number of Connected Components in Graph", difficulty: .medium, url: "https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/")
    ]),
    Day(id: 11, date: "Feb 13", topic: "Advanced Graphs", problems: [
        Problem(name: "Redundant Connection", difficulty: .medium, url: "https://leetcode.com/problems/redundant-connection/"),
        Problem(name: "Word Ladder", difficulty: .medium, url: "https://leetcode.com/problems/word-ladder/"),
        Problem(name: "Alien Dictionary", difficulty: .medium, url: "https://leetcode.com/problems/alien-dictionary/"),
        Problem(name: "Min Cost to Connect All Points", difficulty: .medium, url: "https://leetcode.com/problems/min-cost-to-connect-all-points/"),
        Problem(name: "Network Delay Time", difficulty: .medium, url: "https://leetcode.com/problems/network-delay-time/")
    ]),
    Day(id: 12, date: "Feb 14", topic: "1-D Dynamic Programming", problems: [
        Problem(name: "Climbing Stairs", difficulty: .easy, url: "https://leetcode.com/problems/climbing-stairs/"),
        Problem(name: "House Robber", difficulty: .medium, url: "https://leetcode.com/problems/house-robber/"),
        Problem(name: "House Robber II", difficulty: .medium, url: "https://leetcode.com/problems/house-robber-ii/"),
        Problem(name: "Longest Palindromic Substring", difficulty: .medium, url: "https://leetcode.com/problems/longest-palindromic-substring/"),
        Problem(name: "Palindromic Substrings", difficulty: .medium, url: "https://leetcode.com/problems/palindromic-substrings/")
    ]),
    Day(id: 13, date: "Feb 15", topic: "1-D DP (cont.) + 2-D DP Intro", problems: [
        Problem(name: "Decode Ways", difficulty: .medium, url: "https://leetcode.com/problems/decode-ways/"),
        Problem(name: "Coin Change", difficulty: .medium, url: "https://leetcode.com/problems/coin-change/"),
        Problem(name: "Maximum Product Subarray", difficulty: .medium, url: "https://leetcode.com/problems/maximum-product-subarray/"),
        Problem(name: "Word Break", difficulty: .medium, url: "https://leetcode.com/problems/word-break/"),
        Problem(name: "Longest Increasing Subsequence", difficulty: .medium, url: "https://leetcode.com/problems/longest-increasing-subsequence/")
    ])
    ]
)

let planData = PlanDataLoader.load()
let preCompletedTopics = planData.preCompletedTopics
let dsaPlan = planData.days
