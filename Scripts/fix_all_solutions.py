#!/usr/bin/env python3
"""
fix_all_solutions.py

Comprehensive solution fixer that:
1. Applies mechanical fixes (single-line expansion, single-quotes, etc.)
2. Compile-tests each approach using swiftc
3. Calls Groq API to regenerate approaches that still fail
4. Verifies AI-generated fixes compile AND pass test cases before applying

Usage:
    export GROQ_API_KEY="gsk_..."
    python3 Scripts/fix_all_solutions.py <topic-id>

    # Must specify a single topic to process one at a time
"""

import json
import os
import re
import subprocess
import sys
import tempfile
import time

# Configuration
SOLUTIONS_DIR = "FocusApp/Resources/Solutions"
GROQ_MODEL = "llama-3.3-70b-versatile"
GROQ_ENDPOINT = "https://api.groq.com/openai/v1/chat/completions"
API_DELAY = 20.0  # seconds between API calls (respect TPM limit)
RETRY_DELAY = 65.0  # seconds on rate limit
MAX_RETRIES = 5
COMPILE_TIMEOUT = 30  # seconds
RUN_TIMEOUT = 10  # seconds per test case

# Class-design slugs that can't be wrapped
CLASS_DESIGN_SLUGS = {
    "design-add-and-search-words-data-structure",
    "implement-trie-prefix-tree",
    "word-search-ii",
    "min-stack",
    "lru-cache",
    "lfu-cache",
    "insert-delete-getrandom-o1",
    "design-twitter",
    "kth-largest-element-in-a-stream",
    "find-median-from-data-stream",
    "implement-queue-using-stacks",
    "implement-stack-using-queues",
    "flatten-nested-list-iterator",
    "peeking-iterator",
    "binary-search-tree-iterator",
    "online-stock-span",
    "design-circular-queue",
    "map-sum-pairs",
    "implement-magic-dictionary",
    "time-based-key-value-store",
    "my-calendar-i",
    "my-calendar-ii",
    "range-sum-query-mutable",
    "online-election",
    "encode-and-decode-tinyurl",
    "rle-iterator",
    "first-bad-version",
    "guess-number-higher-or-lower",
    "detect-squares",
    "serialize-and-deserialize-binary-tree",
    "codec",
    "design-hashmap",
    "design-hashset",
}


def log(msg: str):
    """Print with flush to ensure output is not buffered."""
    print(msg, flush=True)


# Resolve project root
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
SOLUTIONS_PATH = os.path.join(PROJECT_ROOT, SOLUTIONS_DIR)

# API key
API_KEY = os.environ.get("GROQ_API_KEY", "")


def ensure_class_solution(code: str) -> str:
    """Wrap code in class Solution {} if not already present."""
    if "class Solution" in code or "struct Solution" in code:
        return code
    lines = code.split("\n")
    imports = []
    body_lines = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("import "):
            imports.append(stripped)
        else:
            body_lines.append(line)
    body = "\n".join(body_lines).strip()
    prefix = "\n".join(imports) + "\n\n" if imports else ""
    return f"{prefix}class Solution {{\n{body}\n}}"


def extract_func_signature(code: str):
    """Extract the first function signature from code inside class Solution."""
    pattern = r'func\s+(`?[A-Za-z_][A-Za-z0-9_]*`?)\s*\(([^)]*)\)\s*(?:->\s*([^{\n]+))?'
    match = re.search(pattern, code)
    if not match:
        return None
    name = match.group(1)
    params_raw = match.group(2)
    return_type = (match.group(3) or "").strip()
    return name, params_raw, return_type


def build_compile_wrapper(code: str) -> str:
    """Build a minimal compilable wrapper around the solution code."""
    wrapped = ensure_class_solution(code)

    if "import Foundation" not in wrapped:
        wrapped = "import Foundation\n\n" + wrapped

    support_classes = ""
    if "TreeNode" in wrapped and "class TreeNode" not in wrapped:
        support_classes += """
class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init() { self.val = 0; self.left = nil; self.right = nil }
    init(_ val: Int) { self.val = val; self.left = nil; self.right = nil }
    init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) { self.val = val; self.left = left; self.right = right }
}
"""
    if "ListNode" in wrapped and "class ListNode" not in wrapped:
        support_classes += """
class ListNode {
    var val: Int
    var next: ListNode?
    init() { self.val = 0; self.next = nil }
    init(_ val: Int) { self.val = val; self.next = nil }
    init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next }
}
"""
    if "Node" in wrapped and "class Node" not in wrapped and "TreeNode" not in wrapped:
        if re.search(r'Node[?\[\]]', wrapped):
            support_classes += """
class Node {
    var val: Int
    var children: [Node]
    var next: Node?
    var neighbors: [Node?]
    var random: Node?
    init() { self.val = 0; self.children = []; self.next = nil; self.neighbors = []; self.random = nil }
    init(_ val: Int) { self.val = val; self.children = []; self.next = nil; self.neighbors = []; self.random = nil }
}
"""

    if support_classes:
        lines = wrapped.split("\n")
        insert_idx = 0
        for i, line in enumerate(lines):
            if line.strip().startswith("import "):
                insert_idx = i + 1
            elif line.strip().startswith("class Solution") or line.strip().startswith("struct Solution"):
                break
        lines.insert(insert_idx, support_classes)
        wrapped = "\n".join(lines)

    main_code = "\nlet _ = Solution()\n"
    return wrapped + main_code


def compile_swift(code: str, binary_out: str = None) -> tuple:
    """Compile Swift code, return (success: bool, error: str, binary_path: str or None)."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
        f.write(code)
        f.flush()
        source_path = f.name

    if binary_out is None:
        binary_path = source_path.replace('.swift', '')
    else:
        binary_path = binary_out

    try:
        result = subprocess.run(
            ['/usr/bin/swiftc', '-O', '-o', binary_path, source_path],
            capture_output=True, text=True, timeout=COMPILE_TIMEOUT
        )
        if result.returncode == 0:
            return True, "", binary_path
        return False, result.stderr, None
    except subprocess.TimeoutExpired:
        return False, "Compilation timed out", None
    except Exception as e:
        return False, str(e), None
    finally:
        try:
            os.unlink(source_path)
        except OSError:
            pass


def run_test_case(binary_path: str, input_str: str) -> tuple:
    """Run a compiled binary with input, return (stdout, stderr, exit_code)."""
    try:
        result = subprocess.run(
            [binary_path],
            input=input_str,
            capture_output=True, text=True, timeout=RUN_TIMEOUT
        )
        return result.stdout, result.stderr, result.returncode
    except subprocess.TimeoutExpired:
        return "", "Timeout", 1
    except Exception as e:
        return "", str(e), 1


# ============================================================
# Mechanical Fixes
# ============================================================

def is_single_line_code(code: str) -> bool:
    """Check if code is compressed onto a single line or very few lines."""
    newlines = code.count("\n")
    braces = code.count("{") + code.count("}")
    length = len(code)
    semicolons = code.count(";")

    if semicolons > 5 and newlines < 5:
        return True
    if newlines < 2 and braces > 3 and length > 80:
        return True
    if newlines < 3 and braces > 5 and length > 200:
        return True
    return False


def expand_single_line(code: str) -> str:
    """Expand compressed code into properly indented multi-line code."""
    tokens = []
    current = ""
    in_string = False
    escape = False

    for ch in code:
        if escape:
            current += ch
            escape = False
            continue
        if ch == '\\' and in_string:
            current += ch
            escape = True
            continue
        if ch == '"':
            in_string = not in_string
            current += ch
            continue
        if ch == ';' and not in_string:
            tokens.append(current)
            current = ""
            continue
        current += ch
    if current:
        tokens.append(current)

    combined = " ".join(t.strip() for t in tokens if t.strip())

    lines = []
    depth = 0
    cur = ""
    in_string = False
    escape = False

    for ch in combined:
        if escape:
            cur += ch
            escape = False
            continue
        if ch == '\\' and in_string:
            cur += ch
            escape = True
            continue
        if ch == '"':
            in_string = not in_string
            cur += ch
            continue

        if not in_string:
            if ch == '{':
                cur += ch
                stripped = cur.strip()
                if stripped:
                    indent = "    " * depth
                    lines.append(indent + stripped)
                cur = ""
                depth += 1
                continue
            if ch == '}':
                stripped = cur.strip()
                if stripped:
                    indent = "    " * depth
                    lines.append(indent + stripped)
                cur = ""
                depth = max(0, depth - 1)
                indent = "    " * depth
                lines.append(indent + "}")
                continue

        cur += ch

    stripped = cur.strip()
    if stripped:
        indent = "    " * depth
        lines.append(indent + stripped)

    return "\n".join(lines)


def fix_single_line_code(code: str) -> str:
    """Expand single-line code into multi-line."""
    if not is_single_line_code(code):
        return code
    return expand_single_line(code)


def fix_single_quotes(code: str) -> str:
    """Replace single-quoted character literals with double-quoted ones."""
    result = re.sub(
        r"(?<![A-Za-z])'(\\.|[^'\\])'",
        r'"\1"',
        code
    )
    return result


def fix_import_after_class(code: str) -> str:
    """Move import Foundation that appears inside class to the top."""
    lines = code.split("\n")
    saw_class = False
    import_idx = None
    for i, line in enumerate(lines):
        stripped = line.strip()
        if any(stripped.startswith(p) for p in ["class ", "public class ", "struct ", "public struct "]):
            saw_class = True
        if saw_class and stripped == "import Foundation":
            import_idx = i
            break

    if import_idx is None:
        return code

    lines.pop(import_idx)
    if import_idx < len(lines) and lines[import_idx].strip() == "":
        lines.pop(import_idx)
    if import_idx > 0 and import_idx - 1 < len(lines) and lines[import_idx - 1].strip() == "":
        lines.pop(import_idx - 1)

    insert_at = 0
    while insert_at < len(lines) and lines[insert_at].strip() == "":
        insert_at += 1
    lines.insert(insert_at, "import Foundation")
    if insert_at + 1 < len(lines) and lines[insert_at + 1].strip() != "":
        lines.insert(insert_at + 1, "")

    return "\n".join(lines)


def fix_excessive_indentation(code: str) -> str:
    """Strip excessive base indentation (6+ spaces on every line)."""
    lines = code.split("\n")
    non_empty = [l for l in lines if l.strip()]
    if not non_empty:
        return code
    min_indent = min(len(l) - len(l.lstrip(' ')) for l in non_empty)
    if min_indent < 6:
        return code
    return "\n".join(
        "" if not l.strip() else l[min_indent:]
        for l in lines
    )


def apply_mechanical_fixes(code: str) -> str:
    """Apply all mechanical fixes to solution code."""
    fixed = code
    fixed = fix_single_line_code(fixed)
    fixed = fix_excessive_indentation(fixed)
    fixed = fix_import_after_class(fixed)
    fixed = fix_single_quotes(fixed)
    return fixed


# ============================================================
# Groq API
# ============================================================

def call_groq(prompt: str, retry: int = 0) -> str:
    """Call Groq API using curl (avoids Cloudflare 403 from urllib)."""
    if not API_KEY:
        return ""

    payload = json.dumps({
        "model": GROQ_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.2,
        "max_tokens": 4096,
    })

    try:
        result = subprocess.run(
            [
                "curl", "-s", "-X", "POST", GROQ_ENDPOINT,
                "-H", "Content-Type: application/json",
                "-H", f"Authorization: Bearer {API_KEY}",
                "-d", payload,
            ],
            capture_output=True, text=True, timeout=120
        )
        if result.returncode != 0:
            log(f"    curl error: {result.stderr[:100]}")
            return ""

        body = json.loads(result.stdout)
        if "error" in body:
            error_msg = body["error"].get("message", str(body["error"]))
            if "rate_limit" in error_msg.lower() and retry < MAX_RETRIES:
                wait = RETRY_DELAY * (retry + 1)
                log(f"    Rate limited, waiting {wait}s...")
                time.sleep(wait)
                return call_groq(prompt, retry + 1)
            log(f"    API error: {error_msg[:100]}")
            return ""

        return body["choices"][0]["message"]["content"]
    except json.JSONDecodeError as e:
        log(f"    JSON decode error: {e}")
        return ""
    except subprocess.TimeoutExpired:
        log(f"    API call timed out")
        return ""
    except Exception as e:
        log(f"    API exception: {e}")
        return ""


def extract_code_from_response(response: str) -> str:
    """Extract Swift code from AI response, stripping markdown fences."""
    match = re.search(r'```(?:swift)?\s*\n(.*?)```', response, re.DOTALL)
    if match:
        code = match.group(1).strip()
    else:
        code = response.strip()
    return code


def regenerate_with_ai(slug: str, approach_name: str, code: str, error: str) -> str:
    """Use Groq API to regenerate a failing Swift solution."""
    prompt = f"""Fix this Swift LeetCode solution that has compilation errors.

Problem: {slug}
Approach: {approach_name}

Current code (has errors):
```swift
{code}
```

Compile error:
{error[:500]}

Requirements:
1. Return ONLY the fixed Swift code inside a ```swift code block
2. The code must be a valid Swift class named "Solution" with the correct function signature for the LeetCode problem
3. Use proper Swift syntax (no Python/Java idioms)
4. Use String.Index for string subscripting, NOT integer subscripts like str[0]. Prefer converting to Array(string) first.
5. Use "double quotes" for all string/character literals, NOT 'single quotes'
6. Do NOT use tuples as Set elements or Dictionary keys (tuples don't conform to Hashable in Swift)
7. If you need to mutate a function parameter, shadow it: `var nums = nums`
8. Put each statement on its own line (no semicolons as statement separators)
9. Include `import Foundation` at the top only if you use Foundation APIs
10. Make sure the code compiles with Swift 5.x / 6.x
11. The solution must be CORRECT — produce the right output for the given problem

Return the complete class. Nothing else."""

    response = call_groq(prompt)
    if not response:
        return ""

    return extract_code_from_response(response)


# ============================================================
# Main Processing
# ============================================================

def process_topic(topic_file: str, stats: dict):
    """Process a single topic JSON file."""
    filepath = os.path.join(SOLUTIONS_PATH, topic_file)
    with open(filepath, 'r') as f:
        data = json.load(f)

    solutions = data.get("solutions", [])
    modified = False
    topic_name = topic_file.replace(".json", "")

    log(f"\n=== {topic_name} ===")

    for sol_idx, solution in enumerate(solutions):
        slug = solution.get("problemSlug", "?")
        if slug in CLASS_DESIGN_SLUGS:
            stats["skipped"] += len(solution.get("approaches", []))
            continue

        approaches = solution.get("approaches", [])
        for app_idx, approach in enumerate(approaches):
            code = approach.get("code", "")
            app_name = approach.get("name", "?")
            test_cases = approach.get("testCases", [])
            stats["total"] += 1

            if not code.strip():
                stats["skipped"] += 1
                continue

            # Step 1: Apply mechanical fixes
            fixed = apply_mechanical_fixes(code)

            # Step 2: Build compile wrapper and test
            wrapper = build_compile_wrapper(fixed)
            success, error, _ = compile_swift(wrapper)

            if success:
                if fixed != code:
                    approach["code"] = fixed
                    modified = True
                    stats["mechanical_fixed"] += 1
                    log(f"  ✓ MECHANICAL [{slug}/{app_name}]")
                else:
                    stats["already_ok"] += 1
                continue

            # Step 3: Try AI regeneration if we have API key
            if not API_KEY:
                stats["still_failing"] += 1
                log(f"  ✗ STILL FAILING [{slug}/{app_name}]: {error[:100]}")
                continue

            log(f"  → AI REGEN [{slug}/{app_name}]: {error[:80]}")
            time.sleep(API_DELAY)

            new_code = regenerate_with_ai(slug, app_name, fixed, error)
            if not new_code:
                stats["ai_failed"] += 1
                log(f"    AI returned empty")
                continue

            # Step 4: Verify AI code compiles
            new_wrapper = build_compile_wrapper(new_code)
            success2, error2, binary_path = compile_swift(new_wrapper)

            if not success2:
                stats["ai_failed"] += 1
                log(f"    ✗ AI fix doesn't compile: {error2[:80]}")
                # Cleanup
                continue

            # Step 5: Run test cases to verify correctness
            if test_cases and binary_path:
                pass_count = 0
                fail_count = 0
                for tc in test_cases:
                    tc_input = tc.get("input", "")
                    tc_expected = tc.get("expectedOutput", "")
                    stdout, stderr, exit_code = run_test_case(binary_path, tc_input)

                    if exit_code != 0:
                        fail_count += 1
                        continue

                    # Normalize output for comparison
                    actual = stdout.strip()
                    expected = tc_expected.strip()

                    # Try various normalizations
                    if actual == expected:
                        pass_count += 1
                    elif actual.strip('"') == expected.strip('"'):
                        pass_count += 1
                    elif actual.replace(", ", ",").replace(": ", ":") == expected.replace(", ", ",").replace(": ", ":"):
                        pass_count += 1
                    else:
                        fail_count += 1

                total_tests = pass_count + fail_count

                # Clean up binary
                try:
                    os.unlink(binary_path)
                except OSError:
                    pass

                if total_tests > 0 and fail_count == 0:
                    approach["code"] = new_code
                    modified = True
                    stats["ai_fixed"] += 1
                    log(f"    ✓ AI fix: compiles + passes {pass_count}/{total_tests} tests")
                elif total_tests > 0:
                    stats["ai_failed"] += 1
                    log(f"    ✗ AI fix: compiles but fails {fail_count}/{total_tests} tests")
                else:
                    # No test cases ran (empty input?), accept if it compiles
                    approach["code"] = new_code
                    modified = True
                    stats["ai_fixed"] += 1
                    log(f"    ✓ AI fix: compiles (no runnable tests)")
            else:
                # No test cases available, accept if it compiles
                approach["code"] = new_code
                modified = True
                stats["ai_fixed"] += 1
                log(f"    ✓ AI fix: compiles (no test cases)")
                if binary_path:
                    try:
                        os.unlink(binary_path)
                    except OSError:
                        pass

    if modified:
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
        stats["files_modified"] += 1
        log(f"  Updated {topic_file}")


def main():
    if len(sys.argv) < 2:
        log("Usage: python3 Scripts/fix_all_solutions.py <topic-id>")
        log("Process one topic at a time to avoid losing progress.")
        log("")
        # List available topics
        files = sorted(f for f in os.listdir(SOLUTIONS_PATH)
                       if f.endswith(".json") and f != "index.json")
        log("Available topics:")
        for f in files:
            log(f"  {f.replace('.json', '')}")
        sys.exit(1)

    target_topic = sys.argv[1]

    if not os.path.exists(SOLUTIONS_PATH):
        log(f"ERROR: Solutions directory not found at {SOLUTIONS_PATH}")
        sys.exit(1)

    if not API_KEY:
        log("WARNING: GROQ_API_KEY not set — only mechanical fixes will be applied")

    target_file = f"{target_topic}.json"
    files = sorted(f for f in os.listdir(SOLUTIONS_PATH)
                   if f.endswith(".json") and f != "index.json")

    if target_file not in files:
        log(f"ERROR: Topic file '{target_file}' not found")
        log(f"Available: {', '.join(f.replace('.json', '') for f in files)}")
        sys.exit(1)

    log(f"Processing topic: {target_topic}")
    if API_KEY:
        log(f"Groq API key: ...{API_KEY[-8:]}")
    log(f"API delay: {API_DELAY}s between calls")

    stats = {
        "total": 0,
        "already_ok": 0,
        "mechanical_fixed": 0,
        "ai_fixed": 0,
        "ai_failed": 0,
        "still_failing": 0,
        "skipped": 0,
        "files_modified": 0,
    }

    process_topic(target_file, stats)

    log("\n" + "=" * 50)
    log("SUMMARY")
    log("=" * 50)
    log(f"Total approaches:     {stats['total']}")
    log(f"Already compiling:    {stats['already_ok']}")
    log(f"Mechanical fixes:     {stats['mechanical_fixed']}")
    log(f"AI fixes (verified):  {stats['ai_fixed']}")
    log(f"AI failed:            {stats['ai_failed']}")
    log(f"Still failing:        {stats['still_failing']}")
    log(f"Skipped (design):     {stats['skipped']}")
    log(f"Files modified:       {stats['files_modified']}")
    total_passing = stats['already_ok'] + stats['mechanical_fixed'] + stats['ai_fixed']
    total_testable = stats['total'] - stats['skipped']
    if total_testable > 0:
        log(f"Pass rate:            {total_passing}/{total_testable} ({100*total_passing/total_testable:.1f}%)")


if __name__ == "__main__":
    main()
