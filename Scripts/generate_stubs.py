#!/usr/bin/env python3
"""Generate stub solution JSON files for missing problems in the top 700."""

import json
import os
import textwrap

MANIFEST_PATH = "FocusApp/Resources/problem-manifest.json"
SOLUTIONS_DIR = "FocusApp/Resources/Solutions"
STUBS_DIR = "Scripts/generated-stubs"
TARGET_LIMIT = 700


def load_existing_slugs():
    """Load slugs that already have solutions in topic files."""
    existing = set()
    for fname in os.listdir(SOLUTIONS_DIR):
        if fname.endswith(".json") and fname != "index.json":
            with open(os.path.join(SOLUTIONS_DIR, fname)) as fh:
                data = json.load(fh)
                for sol in data.get("solutions", []):
                    existing.add(sol["problemSlug"])
    return existing


def make_stub(problem):
    """Create a stub GeneratedSolution for a problem."""
    title = problem["title"]
    slug = problem["slug"]
    difficulty = problem["difficulty"]
    topics = ", ".join(problem.get("topics", []))

    return {
        "summary": f"{title} - {difficulty} problem involving {topics}.",
        "approaches": [
            {
                "name": "Brute Force",
                "intuition": f"Start with the straightforward approach for {title}.",
                "approach": f"1. Consider all possible cases\n2. Apply direct logic\n3. Return the result",
                "explanation": f"The brute force approach for {title} checks all possibilities directly. While not optimal, it establishes correctness.",
                "code": textwrap.dedent(f"""\
                    // {title} - Brute Force
                    // Difficulty: {difficulty}
                    // Topics: {topics}

                    func solve() {{
                        // TODO: Implement brute force solution
                    }}"""),
                "complexity": {
                    "time": "O(n^2)" if difficulty == "Medium" else "O(n)",
                    "space": "O(1)",
                    "timeExplanation": f"Brute force approach for {title}",
                    "spaceExplanation": "Constant extra space",
                },
                "testCases": [
                    {
                        "input": "Example input",
                        "expectedOutput": "Example output",
                        "explanation": f"Basic test case for {title}",
                    }
                ],
            },
            {
                "name": "Optimized",
                "intuition": f"Optimize using properties of {topics} for {title}.",
                "approach": f"1. Use an efficient data structure or algorithm\n2. Reduce redundant computation\n3. Return the result",
                "explanation": f"The optimized approach for {title} leverages {topics} techniques to reduce time complexity.",
                "code": textwrap.dedent(f"""\
                    // {title} - Optimized
                    // Difficulty: {difficulty}
                    // Topics: {topics}

                    func solve() {{
                        // TODO: Implement optimized solution
                    }}"""),
                "complexity": {
                    "time": "O(n log n)" if difficulty == "Medium" else "O(n)",
                    "space": "O(n)",
                    "timeExplanation": f"Optimized approach for {title}",
                    "spaceExplanation": "Additional space for data structures",
                },
                "testCases": [
                    {
                        "input": "Example input",
                        "expectedOutput": "Example output",
                        "explanation": f"Basic test case for {title}",
                    }
                ],
            },
        ],
        "relatedProblems": [],
    }


def main():
    with open(MANIFEST_PATH) as f:
        manifest = json.load(f)

    existing = load_existing_slugs()
    top_n = sorted(manifest["problems"], key=lambda p: p["number"])[:TARGET_LIMIT]
    missing = [p for p in top_n if p["slug"] not in existing]

    os.makedirs(STUBS_DIR, exist_ok=True)

    for problem in missing:
        stub = make_stub(problem)
        path = os.path.join(STUBS_DIR, f"{problem['slug']}.json")
        with open(path, "w") as f:
            json.dump(stub, f, indent=2)

    print(f"Generated {len(missing)} stub files in {STUBS_DIR}/")
    print(f"Existing: {len(existing)}, Missing: {len(missing)}, Target: {TARGET_LIMIT}")


if __name__ == "__main__":
    main()
