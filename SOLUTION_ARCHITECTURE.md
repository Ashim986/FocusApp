# LeetCode Solutions Architecture

## Overview

This document outlines the architecture for storing and serving 2000+ LeetCode problem solutions with comprehensive explanations, multiple approaches, and complexity analysis.

## Goals

1. **Scalability**: Support 800+ Easy and 1500+ Medium problems
2. **Performance**: Fast load times, lazy loading on demand
3. **Maintainability**: Easy to add/update solutions
4. **Offline Support**: Solutions available without internet
5. **Searchability**: Find solutions by topic, difficulty, pattern

---

## Storage Architecture: Hybrid JSON + SwiftData

### Layer 1: Bundled JSON Files (Source of Truth)

```
FocusApp/Resources/Solutions/
├── index.json                    # Master index with metadata
├── arrays-hashing.json           # ~100 problems
├── two-pointers.json             # ~50 problems
├── sliding-window.json           # ~40 problems
├── stack.json                    # ~40 problems
├── binary-search.json            # ~50 problems
├── linked-list.json              # ~40 problems
├── trees.json                    # ~80 problems
├── tries.json                    # ~20 problems
├── heap-priority-queue.json      # ~40 problems
├── backtracking.json             # ~50 problems
├── graphs.json                   # ~80 problems
├── dynamic-programming-1d.json   # ~60 problems
├── dynamic-programming-2d.json   # ~50 problems
├── greedy.json                   # ~50 problems
├── intervals.json                # ~30 problems
├── math-geometry.json            # ~40 problems
├── bit-manipulation.json         # ~30 problems
└── misc.json                     # Uncategorized
```

**Estimated Total Size**: 8-12 MB (compressed in app bundle)

### Layer 2: SwiftData Cache (Runtime Performance)

```swift
@Model
class CachedSolution {
    @Attribute(.unique) var problemSlug: String
    var leetcodeNumber: Int
    var topic: String
    var difficulty: String
    var summary: String
    var approachesData: Data  // Encoded [SolutionApproach]
    var lastAccessed: Date
    var isFavorite: Bool

    // Computed from approachesData
    var approaches: [SolutionApproach] { ... }
}

@Model
class SolutionIndex {
    var topic: String
    var problemSlugs: [String]
    var lastUpdated: Date
    var isLoaded: Bool
}
```

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     App Launch                               │
├─────────────────────────────────────────────────────────────┤
│  1. Load index.json (lightweight, ~50KB)                    │
│  2. Check SwiftData cache for frequently accessed           │
│  3. Display UI immediately                                   │
├─────────────────────────────────────────────────────────────┤
│                   User Requests Solution                     │
├─────────────────────────────────────────────────────────────┤
│  1. Check SwiftData cache first (O(1) lookup)               │
│  2. If miss: Load topic JSON file                           │
│  3. Parse and cache in SwiftData                            │
│  4. Return solution                                          │
├─────────────────────────────────────────────────────────────┤
│                   Background Prefetch                        │
├─────────────────────────────────────────────────────────────┤
│  1. Prefetch solutions for today's problems                 │
│  2. Prefetch related problems                               │
│  3. Cache in SwiftData for instant access                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Index File Structure

```json
// index.json
{
  "version": "2.0.0",
  "lastUpdated": "2026-02-05",
  "totalProblems": 2300,
  "topics": [
    {
      "id": "arrays-hashing",
      "name": "Arrays & Hashing",
      "file": "arrays-hashing.json",
      "problemCount": 98,
      "difficulties": { "easy": 45, "medium": 53 }
    },
    {
      "id": "linked-list",
      "name": "Linked List",
      "file": "linked-list.json",
      "problemCount": 42,
      "difficulties": { "easy": 15, "medium": 27 }
    }
    // ... more topics
  ],
  "problemIndex": {
    "two-sum": { "topic": "arrays-hashing", "number": 1, "difficulty": "easy" },
    "reverse-linked-list": { "topic": "linked-list", "number": 206, "difficulty": "easy" }
    // ... all problems for quick lookup
  }
}
```

---

## Solution Generation Pipeline

### Phase 1: Problem List Collection

```
┌─────────────────────────────────────────────────────────────┐
│              LeetCode Problem Fetcher                        │
├─────────────────────────────────────────────────────────────┤
│  Source: LeetCode GraphQL API                               │
│  Data: Problem name, number, difficulty, tags, description  │
│  Output: problems-manifest.json                             │
└─────────────────────────────────────────────────────────────┘
```

### Phase 2: Solution Generation (AI-Powered)

```
┌─────────────────────────────────────────────────────────────┐
│              Solution Generator                              │
├─────────────────────────────────────────────────────────────┤
│  For each problem:                                          │
│  1. Fetch problem description from LeetCode                 │
│  2. Generate 2-3 solution approaches using AI               │
│  3. Include: intuition, approach, code, complexity          │
│  4. Generate test cases with explanations                   │
│  5. Validate code syntax                                    │
│  6. Save to topic JSON file                                 │
├─────────────────────────────────────────────────────────────┤
│  Rate Limiting:                                             │
│  - LeetCode: 1 request/second                               │
│  - AI Generation: Batch processing                          │
│  - Estimated time: ~50 hours for 2000 problems              │
└─────────────────────────────────────────────────────────────┘
```

### Phase 3: Validation & Quality Control

```
┌─────────────────────────────────────────────────────────────┐
│              Solution Validator                              │
├─────────────────────────────────────────────────────────────┤
│  1. Syntax check: Swift code compiles                       │
│  2. Complexity verification                                 │
│  3. Test case validation                                    │
│  4. Content quality scoring                                 │
│  5. Deduplication check                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Create new solution models with topic support
- [ ] Implement TopicBasedSolutionStore
- [ ] Set up SwiftData caching layer
- [ ] Create index.json and topic file structure
- [ ] Migrate existing Solutions.json to new format

### Phase 2: Data Pipeline (Week 2)
- [ ] Build LeetCode problem fetcher (GraphQL)
- [ ] Create problem manifest with all Easy/Medium problems
- [ ] Set up batch processing infrastructure
- [ ] Implement rate limiting and error handling

### Phase 3: Solution Generation (Weeks 3-6)
- [ ] Generate solutions in batches by topic
- [ ] Priority order: NeetCode 150 → Blind 75 → All Easy → All Medium
- [ ] Validate and quality check each batch
- [ ] Incremental releases (update app as batches complete)

### Phase 4: Optimization (Week 7)
- [ ] Implement background prefetching
- [ ] Add search functionality
- [ ] Performance profiling and optimization
- [ ] Memory usage optimization

---

## File Size Estimates

| Topic | Problems | Est. Size |
|-------|----------|-----------|
| Arrays & Hashing | 98 | 800 KB |
| Two Pointers | 52 | 400 KB |
| Sliding Window | 38 | 300 KB |
| Stack | 42 | 350 KB |
| Binary Search | 48 | 400 KB |
| Linked List | 42 | 350 KB |
| Trees | 82 | 700 KB |
| Tries | 18 | 150 KB |
| Heap/Priority Queue | 38 | 320 KB |
| Backtracking | 52 | 450 KB |
| Graphs | 78 | 650 KB |
| DP (1D) | 58 | 500 KB |
| DP (2D) | 48 | 420 KB |
| Greedy | 52 | 430 KB |
| Intervals | 28 | 230 KB |
| Math & Geometry | 42 | 350 KB |
| Bit Manipulation | 32 | 260 KB |
| **Total** | **~900** | **~7 MB** |

---

## API Design

### SolutionProvider Protocol

```swift
protocol SolutionProviding: Sendable {
    // Core lookup
    func solution(for slug: String) async -> ProblemSolution?
    func solution(for leetcodeNumber: Int) async -> ProblemSolution?

    // Batch operations
    func solutions(for topic: String) async -> [ProblemSolution]
    func solutions(for slugs: [String]) async -> [ProblemSolution]

    // Search
    func search(query: String) async -> [ProblemSolution]

    // Metadata
    var availableTopics: [SolutionTopic] { get }
    var totalSolutionCount: Int { get }

    // Prefetch
    func prefetch(slugs: [String]) async
    func prefetch(topic: String) async
}
```

### HybridSolutionStore Implementation

```swift
final class HybridSolutionStore: SolutionProviding {
    private let bundleLoader: BundleSolutionLoader
    private let cache: SwiftDataSolutionCache
    private let index: SolutionIndex

    func solution(for slug: String) async -> ProblemSolution? {
        // 1. Check cache
        if let cached = await cache.get(slug) {
            return cached
        }

        // 2. Find topic from index
        guard let topicId = index.topic(for: slug) else { return nil }

        // 3. Load from bundle
        let solution = await bundleLoader.load(slug: slug, topic: topicId)

        // 4. Cache for next time
        if let solution {
            await cache.store(solution)
        }

        return solution
    }
}
```

---

## CLI Tool for Batch Generation

Create a separate command-line tool for generating solutions:

```bash
# Generate solutions for a specific topic
./SolutionGenerator --topic linked-list --output Solutions/linked-list.json

# Generate solutions for specific problems
./SolutionGenerator --problems "two-sum,reverse-linked-list" --output Solutions/custom.json

# Generate all Easy problems
./SolutionGenerator --difficulty easy --output Solutions/

# Resume from checkpoint
./SolutionGenerator --resume --checkpoint checkpoint.json
```

---

## Next Steps

1. **Approve this architecture** - Any changes needed?
2. **Create the new file structure** - Set up Solutions/ directory
3. **Update models** - Add topic support to existing models
4. **Build the SolutionIndex** - Master index file
5. **Start with priority problems** - NeetCode 150 first

---

## Questions to Resolve

1. Should we include Hard problems in the future?
2. Do we need multiple language support (Python, Java)?
3. Should solutions be updatable via remote config?
4. Do we need user notes/bookmarks on solutions?
