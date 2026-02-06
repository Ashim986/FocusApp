# LeetCode Solution Generation Guide

This document describes how to generate LeetCode solutions using AI for the FocusApp.

## Overview

The solution generation system uses two Swift scripts:

| Script | Purpose |
|--------|---------|
| `solution_generator.swift` | Main generator with OpenAI API integration |
| `generate_solution.swift` | Template generator and problem manifest utilities |

## Prerequisites

1. **Problem Manifest**: A `problem-manifest.json` file at `FocusApp/Resources/problem-manifest.json`
2. **OpenAI API Key** (for AI generation): Set via `OPENAI_API_KEY` environment variable
3. **Swift**: Installed (comes with Xcode on macOS)

---

## Script 1: solution_generator.swift (AI-Powered)

The main generator that creates complete solutions using AI.

### Location
```
Scripts/solution_generator.swift
```

### Usage

```bash
cd /path/to/FocusApp

# Generate using OpenAI
OPENAI_API_KEY="sk-..." swift Scripts/solution_generator.swift generate \
  --slug two-sum \
  --provider openai

# Generate using stub files (for testing)
swift Scripts/solution_generator.swift generate \
  --slug two-sum \
  --provider stub \
  --stub-dir ./stubs

# Generate all problems for a topic
swift Scripts/solution_generator.swift generate \
  --topic "Linked List" \
  --provider openai

# Generate all problems in the manifest
swift Scripts/solution_generator.swift generate \
  --all \
  --provider openai

# Custom output path
swift Scripts/solution_generator.swift generate \
  --slug reverse-linked-list \
  --provider openai \
  --output ./Solutions/linked-list.json

# Replace existing solutions
swift Scripts/solution_generator.swift generate \
  --slug two-sum \
  --provider openai \
  --replace
```

### CLI Options

| Option | Description |
|--------|-------------|
| `--slug <slug>` | Generate for a specific problem slug (repeatable) |
| `--all` | Generate for all problems in the manifest |
| `--topic <topic>` | Generate for all problems with this topic |
| `--output <path>` | Output JSON path (default: `FocusApp/Resources/Solutions.json`) |
| `--provider <stub\|openai>` | AI provider to use |
| `--stub-dir <path>` | Directory with stub JSON files (required for stub provider) |
| `--replace` | Replace existing solutions if slug already exists |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key (required for openai provider) | - |
| `OPENAI_MODEL` | Model to use | `gpt-4.1-mini` |

### AI Providers

#### OpenAI Provider
Uses OpenAI's chat completions API to generate solutions.

```bash
export OPENAI_API_KEY="sk-your-api-key"
export OPENAI_MODEL="gpt-4.1-mini"  # Optional, defaults to gpt-4.1-mini

swift Scripts/solution_generator.swift generate --slug two-sum --provider openai
```

#### Stub Provider
For testing without API calls. Reads pre-made JSON files from a directory.

```bash
# Create stub directory with <slug>.json files
mkdir stubs
echo '{"summary":"Test","approaches":[...]}' > stubs/two-sum.json

swift Scripts/solution_generator.swift generate \
  --slug two-sum \
  --provider stub \
  --stub-dir ./stubs
```

### Prompt Template

The AI receives this prompt for each problem:

```
Generate a LeetCode solution JSON for this problem.

Problem:
- Title: {title}
- Slug: {slug}
- Difficulty: {difficulty}
- Topics: {topics}

Requirements:
- Provide EXACT JSON with fields: summary, approaches, relatedProblems.
- approaches must include TWO approaches:
  1) Baseline (clear but less optimal)
  2) Optimized (best known time/space)
- Each approach must include: name, intuition, approach, explanation, code, complexity, testCases.
- complexity must include time, space, timeExplanation, spaceExplanation.
- testCases must include input, expectedOutput, explanation.
- Provide Swift code only.
```

### Validation Rules

Generated solutions are validated before saving:

1. Summary must not be empty
2. At least 2 approaches required
3. Each approach must have a non-empty name
4. Each approach must have non-empty code

---

## Script 2: generate_solution.swift (Templates)

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

Output:
```
// Solution template for: Two Sum (#1)
// Difficulty: Easy
// Topics: Array, Hash Table
// Acceptance Rate: 49.5%

{
  "id": "uuid...",
  "problemSlug": "two-sum",
  "summary": "TODO: Add 1-2 sentence summary...",
  "approaches": [...]
}
```

#### Batch Generate
Creates templates for all problems in a topic:

```bash
swift Scripts/generate_solution.swift batch "Linked List"
```

Output: `linked-list-solutions-template.json`

#### List Topics
Shows all available topics and problem counts:

```bash
swift Scripts/generate_solution.swift list-topics
```

Output:
```
=== Available Topics ===

  Array: 245 problems
  Hash Table: 142 problems
  Linked List: 42 problems
  ...
```

#### List Problems
Browse problems, optionally filtered by topic:

```bash
# List all problems (first 50)
swift Scripts/generate_solution.swift list-problems

# Filter by topic
swift Scripts/generate_solution.swift list-problems --topic "Array"
```

---

## Data Models

### Problem Manifest (`problem-manifest.json`)

```json
{
  "version": "1.0.0",
  "generatedAt": "2026-02-05T00:00:00Z",
  "totalProblems": 2300,
  "problems": [
    {
      "number": 1,
      "title": "Two Sum",
      "slug": "two-sum",
      "difficulty": "Easy",
      "topics": ["Array", "Hash Table"],
      "acceptanceRate": 49.5
    }
  ]
}
```

### Generated Solution (AI Output)

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
        "time": "O(n²)",
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
    },
    {
      "name": "Hash Table",
      "intuition": "Use a hash table to store complements...",
      "approach": "1. Iterate once\n2. For each num, check if (target - num) exists in map",
      "explanation": "We trade space for time by storing seen values...",
      "code": "func twoSum(_ nums: [Int], _ target: Int) -> [Int] { ... }",
      "complexity": {
        "time": "O(n)",
        "space": "O(n)",
        "timeExplanation": "Single pass through the array",
        "spaceExplanation": "Hash table stores up to n elements"
      },
      "testCases": [...]
    }
  ],
  "relatedProblems": ["3sum", "4sum", "two-sum-ii-input-array-is-sorted"]
}
```

### Final Solution (Stored in Solutions.json)

```json
{
  "version": "1.0.0",
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
          "complexity": { ... },
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
      "lastUpdated": "2026-02-05T00:00:00Z"
    }
  ]
}
```

---

## Workflow

### 1. Create Problem Manifest

First, you need a problem manifest. You can create one by fetching from LeetCode's GraphQL API or manually:

```json
// FocusApp/Resources/problem-manifest.json
{
  "version": "1.0.0",
  "generatedAt": "2026-02-05T00:00:00Z",
  "totalProblems": 3,
  "problems": [
    {
      "number": 1,
      "title": "Two Sum",
      "slug": "two-sum",
      "difficulty": "Easy",
      "topics": ["Array", "Hash Table"],
      "acceptanceRate": 49.5
    },
    {
      "number": 206,
      "title": "Reverse Linked List",
      "slug": "reverse-linked-list",
      "difficulty": "Easy",
      "topics": ["Linked List", "Recursion"],
      "acceptanceRate": 72.1
    }
  ]
}
```

### 2. Generate Solutions

#### Option A: AI Generation (Recommended)

```bash
# Set up API key
export OPENAI_API_KEY="sk-your-key"

# Generate for specific problems
swift Scripts/solution_generator.swift generate \
  --slug two-sum \
  --slug reverse-linked-list \
  --provider openai

# Generate for all problems in the manifest
swift Scripts/solution_generator.swift generate \
  --all \
  --provider openai

# Or generate by topic
swift Scripts/solution_generator.swift generate \
  --topic "Linked List" \
  --provider openai
```

#### Option B: Template + Manual Fill

```bash
# Generate template
swift Scripts/generate_solution.swift template two-sum > two-sum-template.json

# Edit the template manually, then merge into Solutions.json
```

### 3. Validate Output

Check that `FocusApp/Resources/Solutions.json` contains the generated solutions:

```bash
cat FocusApp/Resources/Solutions.json | jq '.solutions | length'
```

### 4. Test in App

Build and run the app to verify solutions load correctly in the Coding Environment.

---

## Batch Mode

Batch mode adds per-problem error handling, checkpointing, resume capability, and rate limiting for generating solutions at scale.

### Batch CLI Options

| Option | Description | Default |
|--------|-------------|---------|
| `--batch` | Enable batch mode (per-problem error handling + checkpoint) | `false` |
| `--resume` | Resume from existing checkpoint (skip completed slugs) | `false` |
| `--checkpoint <path>` | Checkpoint file path | `Scripts/.batch-checkpoint.json` |
| `--delay <ms>` | Delay between API calls in milliseconds | `1000` |
| `--max-retries <n>` | Max retries per failed problem | `2` |
| `--topic-output` | Write directly to `Solutions/<topic>.json` topic files | `false` |
| `--limit <n>` | Max problems to target, sorted by LeetCode number | `700` |

### Batch Mode Examples

```bash
# Generate all problems in batch mode with resume support
OPENAI_API_KEY="sk-..." swift Scripts/solution_generator.swift generate \
  --all --provider openai --batch --resume --delay 2000

# Generate by topic with direct topic-file output
swift Scripts/solution_generator.swift generate \
  --topic "Linked List" --provider openai --batch --topic-output

# Resume an interrupted batch (skips already-completed slugs)
swift Scripts/solution_generator.swift generate \
  --all --provider openai --batch --resume

# Custom checkpoint path and retry settings
swift Scripts/solution_generator.swift generate \
  --all --provider openai --batch --resume \
  --checkpoint ./my-checkpoint.json \
  --max-retries 3 --delay 3000
```

### How Batch Mode Works

1. **Per-problem error handling**: If one problem fails, the batch continues with the next
2. **Retry with backoff**: Failed problems are retried up to `--max-retries` times with 2x delay backoff
3. **Checkpoint persistence**: After each problem, status is saved to the checkpoint file
4. **Resume**: With `--resume`, previously completed slugs are skipped automatically
5. **Progress output**: Real-time progress indicators show status for each problem

Output during batch run:
```
✓ [1/100] two-sum
✓ [2/100] reverse-linked-list
⚠ [3/100] lru-cache — retry 1/2
✓ [3/100] lru-cache
✗ [4/100] alien-dictionary — Rate limit (giving up after 2 retries)
...
=== Batch Complete ===
Generated: 98 / 100
Failed: 2 (slugs: alien-dictionary, serialize-and-deserialize-binary-tree)
Skipped: 0
Checkpoint: Scripts/.batch-checkpoint.json
```

### Topic-File Output (`--topic-output`)

When `--topic-output` is enabled, solutions are written directly to topic-partitioned files in `FocusApp/Resources/Solutions/` instead of the flat `Solutions.json`:

- Solutions are assigned to NeetCode topics (arrays-hashing, two-pointers, etc.)
- Existing topic files are loaded and merged (new solutions added, existing preserved)
- `Solutions/index.json` is regenerated after each batch with updated counts
- Uses the same `TopicSolutionsBundle` format the app expects

### Checkpoint File Format

The checkpoint file (`Scripts/.batch-checkpoint.json`) tracks per-slug status:

```json
{
  "startedAt": "2026-02-06T10:00:00Z",
  "lastUpdatedAt": "2026-02-06T10:15:30Z",
  "totalTarget": 100,
  "completed": {
    "two-sum": {
      "status": "done",
      "topic": "arrays-hashing",
      "completedAt": "2026-02-06T10:00:05Z",
      "retryCount": 0
    },
    "alien-dictionary": {
      "status": "failed",
      "error": "Rate limit exceeded",
      "completedAt": "2026-02-06T10:01:20Z",
      "retryCount": 2
    }
  }
}
```

The checkpoint file is gitignored (`Scripts/.batch-checkpoint.json`).

### Coverage Status Command

Check current solution coverage without generating anything:

```bash
swift Scripts/solution_generator.swift status
```

Output (default: top 700 problems by LeetCode number):
```
=== Solution Coverage (top 700 problems by number) ===

Topic                         Done   Target   Coverage
────────────────────────────────────────────────────────
Arrays & Hashing                 18       99      18.2%
Two Pointers                     13       66      19.7%
Sliding Window                    7       10      70.0%
...
────────────────────────────────────────────────────────
TOTAL                           203      700      29.0%

Checkpoint: 200 done, 3 failed
Failed: alien-dictionary, hard-problem-1, hard-problem-2
```

Use `--limit` to change the target scope:
```bash
# Target all 2,349 problems
swift Scripts/solution_generator.swift status --limit 2349

# Target top 500
swift Scripts/solution_generator.swift status --limit 500
```

### Priority Order

For generating solutions at scale, recommended order:

1. **NeetCode 150** — Core interview problems (mostly done)
2. **Blind 75** — Classic interview problems
3. **All Easy** — Build foundation
4. **All Medium** — Complete coverage
5. **All Hard** — Final stretch

### Incremental Topic-by-Topic Workflow

```bash
# Day 1: Arrays & Hashing (largest topic)
swift Scripts/solution_generator.swift generate \
  --topic "Array" --provider openai --batch --resume --topic-output

# Day 2: Linked Lists
swift Scripts/solution_generator.swift generate \
  --topic "Linked List" --provider openai --batch --resume --topic-output

# Day 3: Trees
swift Scripts/solution_generator.swift generate \
  --topic "Tree" --provider openai --batch --resume --topic-output

# Check progress anytime
swift Scripts/solution_generator.swift status
```

---

## Customizing the AI Prompt

To modify the prompt, edit `SolutionPromptBuilder.build()` in `solution_generator.swift`:

```swift
enum SolutionPromptBuilder {
    static func build(for problem: ProblemManifest.ProblemManifestEntry) -> String {
        return """
        Generate a LeetCode solution JSON for this problem.

        Problem:
        - Title: \(problem.title)
        - Slug: \(problem.slug)
        - Difficulty: \(problem.difficulty)
        - Topics: \(problem.topics.joined(separator: ", "))

        Requirements:
        - Provide EXACT JSON with fields: summary, approaches, relatedProblems.
        // ... customize here
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

### "Problem not found in manifest"
Ensure the slug exists in `problem-manifest.json`:
```bash
cat FocusApp/Resources/problem-manifest.json | grep "two-sum"
```

### "OPENAI_API_KEY is required"
Set the environment variable:
```bash
export OPENAI_API_KEY="sk-your-key"
```

### "JSON encoding failed"
The AI returned invalid JSON. Check the raw response or retry:
```bash
# The script extracts JSON between first { and last }
# If the AI adds markdown, it will be stripped
```

### "Need at least 2 approaches"
The AI didn't generate enough approaches. Re-run or modify the prompt to be more explicit.

### Merge Conflicts
If the output file already has solutions, they're merged by default. Use `--replace` to overwrite existing slugs.

---

## Extending the System

### Adding a New AI Provider

1. Implement the `SolutionAIProviding` protocol:

```swift
protocol SolutionAIProviding {
    func generateSolution(
        for problem: ProblemManifest.ProblemManifestEntry
    ) async throws -> GeneratedSolution
}
```

2. Add to `GenerationOptions.ProviderKind`:

```swift
enum ProviderKind: String {
    case stub
    case openai
    case claude  // New provider
}
```

3. Handle in `makeProvider()`:

```swift
case .claude:
    return ClaudeSolutionProvider(apiKey: ...)
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
| `Scripts/solution_generator.swift` | Main AI generator CLI (batch mode, topic output, status) |
| `Scripts/generate_solution.swift` | Template generator CLI |
| `Scripts/partition_solutions.swift` | Splits flat Solutions.json into topic files |
| `Scripts/.batch-checkpoint.json` | Batch checkpoint file (gitignored) |
| `FocusApp/Resources/problem-manifest.json` | Problem metadata (2,349 problems) |
| `FocusApp/Resources/Solutions.json` | Flat solutions file (NeetCode 150 core) |
| `FocusApp/Resources/Solutions/*.json` | Topic-partitioned solution files (17 topics) |
| `FocusApp/Resources/Solutions/index.json` | Topic index with slug-to-topic lookup |
| `FocusApp/Models/SolutionModels.swift` | App solution data models |
| `FocusApp/Models/TopicSolutionModels.swift` | Topic solution models (TopicSolutionsBundle, SolutionIndex) |
| `FocusApp/Models/SolutionStore.swift` | BundledSolutionStore, InMemorySolutionStore |
| `FocusApp/Models/TopicSolutionStore.swift` | Lazy-loading topic-partitioned solution store |
