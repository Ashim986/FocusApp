# LeetCode Solution Generation Guide

This document describes how LeetCode solutions are generated and stored in FocusApp.

## Overview

The solution generation system consists of:

| Component | Location | Purpose |
|-----------|----------|---------|
| `SolutionAIService.swift` | `FocusApp/Models/` | AI provider protocol + Groq/Gemini implementations |
| `generate_solution.swift` | `Scripts/` | Template generator and problem manifest utilities |
| `partition_solutions.swift` | `Scripts/` | Splits flat Solutions.json into topic-partitioned files |

### Current Coverage

- **736 solutions** across 17 NeetCode topics (100% of top 700 target)
- Solutions stored in `FocusApp/Resources/Solutions/*.json` (topic-partitioned)
- Index at `FocusApp/Resources/Solutions/index.json`
- Legacy flat file at `FocusApp/Resources/Solutions.json` (NeetCode 150 core)

---

## AI Solution Service (`SolutionAIService.swift`)

The app-side networking layer for generating solutions via AI. Supports Groq (OpenAI-compatible) and Google Gemini.

### Architecture

```
SolutionAIProviding (protocol)
    |
    +-- OpenAISolutionProvider   (Groq, OpenRouter, OpenAI-compatible endpoints)
    +-- GeminiSolutionProvider   (Google Gemini API)
    |
    +-- SolutionPromptBuilder    (LLM prompt construction)
    +-- JSONExtractor            (sanitize + extract JSON from LLM output)
    +-- SolutionMapper           (AI response -> app ProblemSolution)
    +-- SolutionGenerationError  (error types)
```

### Provider Protocol

```swift
protocol SolutionAIProviding: Sendable {
    func generateSolution(
        for problem: ManifestProblem
    ) async throws -> GeneratedSolution
}
```

### Supported Providers

#### Groq (Recommended)

Uses the OpenAI-compatible API at `api.groq.com`. Fast inference with Llama models.

- **API Key**: Required. Obtain from [console.groq.com](https://console.groq.com)
- **Model**: `llama-3.3-70b-versatile` (recommended for quality)
- **Base URL**: `https://api.groq.com/openai/v1/chat/completions`

```swift
let provider = OpenAISolutionProvider(
    apiKey: "gsk_...",
    model: "llama-3.3-70b-versatile",
    baseURL: URL(string: "https://api.groq.com/openai/v1/chat/completions")!
)
let solution = try await provider.generateSolution(for: problem)
```

#### Gemini

Uses Google's Generative Language API with native JSON mode.

- **API Key**: Required. Obtain from [aistudio.google.com](https://aistudio.google.com)
- **Model**: `gemini-2.5-flash-lite` or `gemini-2.0-flash`
- **Max Output**: 8192 tokens

```swift
let provider = GeminiSolutionProvider(
    apiKey: "AIza...",
    model: "gemini-2.5-flash-lite"
)
let solution = try await provider.generateSolution(for: problem)
```

### JSON Handling

LLMs often return malformed JSON. The `JSONExtractor` utility handles:

1. **Markdown fence stripping**: Removes ` ```json `, ` ```swift `, ` ``` ` wrappers
2. **Object extraction**: Finds first `{` to last `}` in the response
3. **Control character sanitization**: Escapes raw newlines/tabs inside JSON string values

### Validation

`SolutionMapper.validate()` checks AI output quality:

1. Summary must not be empty
2. At least 2 approaches required
3. Each approach must have a non-empty name
4. Each approach must have non-empty code

### Mapping to App Models

`SolutionMapper.mapToSolution()` converts AI response DTOs to the app's `ProblemSolution` model:

- `GeneratedSolution` -> `ProblemSolution` (with UUID ids, Date timestamps)
- `GeneratedApproach` -> `SolutionApproach` (with order index)
- `GeneratedTestCase` -> `SolutionTestCase`
- `ComplexityAnalysis` is shared directly between AI response and app model

---

## Template Generator (`generate_solution.swift`)

A utility script for generating solution templates and exploring the problem manifest.

### Location
```
Scripts/generate_solution.swift
```

### Commands

#### Generate Template
Creates a TODO-filled template for a single problem:

```bash
swift Scripts/generate_solution.swift template two-sum
```

#### Batch Generate
Creates templates for all problems in a topic:

```bash
swift Scripts/generate_solution.swift batch "Linked List"
```

#### List Topics
Shows all available topics and problem counts:

```bash
swift Scripts/generate_solution.swift list-topics
```

#### List Problems
Browse problems, optionally filtered by topic:

```bash
swift Scripts/generate_solution.swift list-problems --topic "Array"
```

---

## Data Models

### AI Response (Intermediate DTOs)

```json
{
  "summary": "Find two numbers that add up to target using hash table for O(1) lookup.",
  "approaches": [
    {
      "name": "Brute Force",
      "intuition": "Check every pair of numbers...",
      "approach": "1. Use nested loops\n2. Check if nums[i] + nums[j] == target",
      "explanation": "For each element, we scan the rest of the array...",
      "code": "func twoSum(_ nums: [Int], _ target: Int) -> [Int] { ... }",
      "complexity": {
        "time": "O(n^2)",
        "space": "O(1)",
        "timeExplanation": "Nested loops over n elements",
        "spaceExplanation": "No extra space used"
      },
      "testCases": [
        {
          "input": "[2,7,11,15], target = 9",
          "expectedOutput": "[0,1]",
          "explanation": "nums[0] + nums[1] = 2 + 7 = 9"
        }
      ]
    }
  ],
  "relatedProblems": ["3sum", "4sum"]
}
```

### App Model (Stored in topic files)

```json
{
  "version": "1.0.0",
  "topic": "arrays-hashing",
  "solutions": [
    {
      "id": "uuid",
      "problemSlug": "two-sum",
      "summary": "...",
      "approaches": [
        {
          "id": "uuid",
          "name": "Hash Table",
          "order": 1,
          "intuition": "...",
          "approach": "...",
          "explanation": "...",
          "code": "...",
          "complexity": { "time": "O(n)", "space": "O(n)", ... },
          "testCases": [
            {
              "id": "uuid",
              "input": "...",
              "expectedOutput": "...",
              "explanation": "..."
            }
          ]
        }
      ],
      "relatedProblems": ["3sum"],
      "lastUpdated": "2026-02-06T00:00:00Z"
    }
  ]
}
```

---

## Solution Storage

### Topic-Partitioned Files (`Solutions/*.json`)

Solutions are organized into 17 NeetCode topic files:

| File | Topic |
|------|-------|
| `arrays-hashing.json` | Arrays & Hashing |
| `two-pointers.json` | Two Pointers |
| `sliding-window.json` | Sliding Window |
| `stack.json` | Stack |
| `binary-search.json` | Binary Search |
| `linked-list.json` | Linked List |
| `trees.json` | Trees |
| `tries.json` | Tries |
| `heap-priority-queue.json` | Heap / Priority Queue |
| `backtracking.json` | Backtracking |
| `graphs.json` | Graphs |
| `advanced-graphs.json` | Advanced Graphs |
| `1d-dynamic-programming.json` | 1-D Dynamic Programming |
| `2d-dynamic-programming.json` | 2-D Dynamic Programming |
| `greedy.json` | Greedy |
| `intervals.json` | Intervals |
| `math-geometry.json` | Math & Geometry |

### Index File (`Solutions/index.json`)

Maps each slug to its topic file for O(1) lookup:

```json
{
  "version": "1.0.0",
  "generatedAt": "2026-02-06T00:00:00Z",
  "topics": {
    "arrays-hashing": { "file": "arrays-hashing.json", "count": 99 },
    "two-pointers": { "file": "two-pointers.json", "count": 66 }
  },
  "slugToTopic": {
    "two-sum": "arrays-hashing",
    "reverse-linked-list": "linked-list"
  }
}
```

### Loading in App

`TopicSolutionStore` lazy-loads solutions by topic on demand. `OnDemandSolutionProvider` wraps it as the app-wide `SolutionProviding` implementation.

---

## Customizing the AI Prompt

To modify the prompt, edit `SolutionPromptBuilder.build()` in `SolutionAIService.swift`:

```swift
enum SolutionPromptBuilder {
    static func build(for problem: ManifestProblem) -> String {
        """
        Generate a LeetCode solution for: \(problem.title) (\(problem.slug), \(problem.difficulty)).
        Topics: \(problem.topics.joined(separator: ", "))

        Return ONLY a JSON object matching this EXACT schema...
        """
    }
}
```

### Customization Ideas

- Request Python code instead of Swift
- Add more approaches (3-4 instead of 2)
- Include hints for each approach
- Add common mistakes section
- Request visualization descriptions

---

## Troubleshooting

### "JSON encoding failed"
The AI returned invalid JSON. The `JSONExtractor` strips markdown fences and sanitizes control characters, but some models may produce unparseable output. Try a larger model (70B+ for Groq, gemini-2.0-flash for Gemini).

### "Need at least 2 approaches"
The AI didn't generate enough approaches. The prompt requests exactly 2 (brute-force + optimized). Re-run or modify the prompt.

### "Summary is empty"
The AI returned an empty or object-typed summary instead of a string. The prompt includes `CRITICAL RULES` to enforce this.

### Rate Limiting
- **Groq**: Free tier has strict rate limits. Paid plan recommended for batch operations.
- **Gemini**: Returns HTTP 429 when rate limited. Add delays between requests.

---

## Extending the System

### Adding a New AI Provider

1. Implement the `SolutionAIProviding` protocol in `SolutionAIService.swift`:

```swift
struct NewProvider: SolutionAIProviding {
    let apiKey: String
    let model: String

    func generateSolution(
        for problem: ManifestProblem
    ) async throws -> GeneratedSolution {
        // Build prompt
        let prompt = SolutionPromptBuilder.build(for: problem)
        // Call API, parse JSON response
        // Return GeneratedSolution
    }
}
```

2. Use `JSONExtractor` to handle LLM output quirks:

```swift
let jsonString = JSONExtractor.sanitizeJSON(
    JSONExtractor.extractJSONObject(from: rawResponse)
)
let solution = try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
```

### Adding Multi-Language Support

Modify the prompt to request multiple languages:

```swift
- Provide code in Swift and Python.
- Format as: { "swift": "...", "python": "..." }
```

Then update `SolutionApproach` model:

```swift
struct SolutionApproach: Codable {
    // ... existing fields
    let code: [String: String]  // ["swift": "...", "python": "..."]
}
```

---

## File Locations Summary

| File | Purpose |
|------|---------|
| `FocusApp/Models/SolutionAIService.swift` | AI provider protocol + Groq/Gemini implementations |
| `Scripts/generate_solution.swift` | Template generator CLI |
| `Scripts/partition_solutions.swift` | Splits flat Solutions.json into topic files |
| `FocusApp/Resources/problem-manifest.json` | Problem metadata (2,349 problems) |
| `FocusApp/Resources/Solutions.json` | Flat solutions file (NeetCode 150 core) |
| `FocusApp/Resources/Solutions/*.json` | Topic-partitioned solution files (17 topics) |
| `FocusApp/Resources/Solutions/index.json` | Topic index with slug-to-topic lookup |
| `FocusApp/Models/SolutionModels.swift` | App solution data models |
| `FocusApp/Models/TopicSolutionModels.swift` | Topic solution models (TopicSolutionsBundle, SolutionIndex) |
| `FocusApp/Models/SolutionStore.swift` | BundledSolutionStore, InMemorySolutionStore |
| `FocusApp/Models/TopicSolutionStore.swift` | Lazy-loading topic-partitioned solution store |
