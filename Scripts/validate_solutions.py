#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from collections import Counter


def slug_from_url(url: str):
    if not url:
        return None
    parts = url.rstrip("/").split("/")
    if "problems" in parts:
        idx = parts.index("problems")
        if idx + 1 < len(parts):
            return parts[idx + 1]
    return None


def load_json(path: Path):
    return json.loads(path.read_text())


def is_empty(value):
    return not value or not value.strip()


def validate_solution(solution: dict) -> list:
    issues: list[str] = []
    slug = solution.get("problemSlug", "<unknown>")

    if is_empty(solution.get("summary")):
        issues.append(f"{slug}: summary missing")

    approaches = solution.get("approaches") or []
    if len(approaches) < 2:
        issues.append(f"{slug}: expected >= 2 approaches, found {len(approaches)}")

    for index, approach in enumerate(approaches, start=1):
        prefix = f"{slug} approach {index}"
        for field in ["name", "intuition", "approach", "explanation", "code"]:
            if is_empty(approach.get(field)):
                issues.append(f"{prefix}: {field} missing")

        complexity = approach.get("complexity") or {}
        for field in ["time", "space", "timeExplanation", "spaceExplanation"]:
            if is_empty(complexity.get(field)):
                issues.append(f"{prefix}: complexity.{field} missing")

        test_cases = approach.get("testCases") or []
        if len(test_cases) == 0:
            issues.append(f"{prefix}: no test cases")
        for tc_index, test_case in enumerate(test_cases, start=1):
            tc_prefix = f"{prefix} testCase {tc_index}"
            if is_empty(test_case.get("input")):
                issues.append(f"{tc_prefix}: input missing")
            if is_empty(test_case.get("expectedOutput")):
                issues.append(f"{tc_prefix}: expectedOutput missing")

    return issues


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate Solutions.json for completeness")
    parser.add_argument(
        "--solutions",
        default="FocusApp/Resources/Solutions.json",
        help="Path to Solutions.json",
    )
    parser.add_argument(
        "--plan",
        default="FocusApp/Resources/Plan.json",
        help="Path to Plan.json",
    )
    args = parser.parse_args()

    solutions_path = Path(args.solutions)
    plan_path = Path(args.plan)

    solutions_bundle = load_json(solutions_path)
    solutions = solutions_bundle.get("solutions", [])

    slugs = [s.get("problemSlug") for s in solutions]
    slug_counts = Counter(slugs)
    duplicate_slugs = [slug for slug, count in slug_counts.items() if count > 1]

    issues: list[str] = []
    for solution in solutions:
        issues.extend(validate_solution(solution))

    plan_slugs: set[str] = set()
    if plan_path.exists():
        plan = load_json(plan_path)
        for day in plan.get("days", []):
            for problem in day.get("problems", []):
                slug = slug_from_url(problem.get("url", ""))
                if slug:
                    plan_slugs.add(slug)

    solution_slugs = {s.get("problemSlug") for s in solutions if s.get("problemSlug")}
    missing_plan = sorted(plan_slugs - solution_slugs)

    print("=== Solution Validation Report ===")
    print(f"Solutions count: {len(solutions)}")
    print(f"Plan slugs count: {len(plan_slugs)}")
    print(f"Duplicate slugs: {len(duplicate_slugs)}")
    if duplicate_slugs:
        print("Duplicates:")
        for slug in duplicate_slugs:
            print(f"  - {slug}")

    if missing_plan:
        print("\nMissing plan solutions:")
        for slug in missing_plan:
            print(f"  - {slug}")
    else:
        print("\nMissing plan solutions: none")

    if issues:
        print(f"\nIssues ({len(issues)}):")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("\nIssues: none")


if __name__ == "__main__":
    main()
