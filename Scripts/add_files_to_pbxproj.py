#!/usr/bin/env python3
"""
Add TopicSolutionModels.swift, TopicSolutionStore.swift (Sources),
and FocusApp/Resources/Solutions/ directory with 18 JSON files (Resources)
to the Xcode project.pbxproj.
"""

import hashlib
import re
import sys


PBXPROJ_PATH = "/Users/ashimdahal/Documents/FocusApp/FocusApp.xcodeproj/project.pbxproj"

# --- Deterministic UUID generation ---
def make_uuid(seed: str) -> str:
    """Generate a deterministic 24-char hex UUID from a seed string."""
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()


# --- Files to add ---
SWIFT_FILES = [
    ("TopicSolutionModels.swift", "FocusApp/Models/TopicSolutionModels.swift"),
    ("TopicSolutionStore.swift", "FocusApp/Models/TopicSolutionStore.swift"),
]

JSON_FILES = [
    "index.json",
    "arrays-hashing.json",
    "two-pointers.json",
    "sliding-window.json",
    "stack.json",
    "binary-search.json",
    "linked-list.json",
    "trees.json",
    "tries.json",
    "heap-priority-queue.json",
    "backtracking.json",
    "graphs.json",
    "dynamic-programming.json",
    "greedy.json",
    "intervals.json",
    "math-geometry.json",
    "bit-manipulation.json",
    "misc.json",
]

# Generate UUIDs
swift_file_refs = {}
swift_build_refs = {}
for filename, path in SWIFT_FILES:
    swift_file_refs[filename] = make_uuid(f"fileref:{path}")
    swift_build_refs[filename] = make_uuid(f"buildfile:sources:{path}")

json_file_refs = {}
json_build_refs = {}
for filename in JSON_FILES:
    path = f"FocusApp/Resources/Solutions/{filename}"
    json_file_refs[filename] = make_uuid(f"fileref:{path}")
    json_build_refs[filename] = make_uuid(f"buildfile:resources:{path}")

# Solutions folder group UUID
SOLUTIONS_GROUP_UUID = make_uuid("group:FocusApp/Resources/Solutions")

# Print all UUIDs for verification
print("=== Generated UUIDs ===")
print(f"Solutions group: {SOLUTIONS_GROUP_UUID}")
print("\nSwift file refs:")
for f, u in swift_file_refs.items():
    print(f"  {f}: fileRef={u}, buildFile={swift_build_refs[f]}")
print("\nJSON file refs:")
for f, u in json_file_refs.items():
    print(f"  {f}: fileRef={u}, buildFile={json_build_refs[f]}")

# Check for UUID collisions with each other
all_uuids = list(swift_file_refs.values()) + list(swift_build_refs.values()) + \
            list(json_file_refs.values()) + list(json_build_refs.values()) + [SOLUTIONS_GROUP_UUID]
if len(all_uuids) != len(set(all_uuids)):
    print("ERROR: UUID collision detected among new UUIDs!")
    sys.exit(1)
print(f"\nAll {len(all_uuids)} new UUIDs are unique.")


# --- Read the pbxproj ---
with open(PBXPROJ_PATH, "r") as f:
    content = f.read()

# Check for collisions with existing UUIDs in the file
for uuid in all_uuids:
    if uuid in content:
        print(f"ERROR: UUID {uuid} already exists in pbxproj!")
        sys.exit(1)
print("No collisions with existing UUIDs in pbxproj.")

lines = content.split("\n")


def find_line(pattern, start=0):
    """Find the first line index matching the pattern from start."""
    for i in range(start, len(lines)):
        if pattern in lines[i]:
            return i
    return -1


# Check if TopicSolution files are already added
for filename, path in SWIFT_FILES:
    if f"path = {filename}" in content:
        print(f"ERROR: {filename} already has a file reference in pbxproj!")
        sys.exit(1)

# Check if Solutions group already exists
if "/* Solutions */ = {" in content and "path = Solutions;" in content:
    print("WARNING: Solutions group may already exist in pbxproj. Proceeding carefully...")


# ============================================================
# 1. Add PBXBuildFile entries
# ============================================================
print("\n--- Adding PBXBuildFile entries ---")

end_build_file = find_line("/* End PBXBuildFile section */")
if end_build_file == -1:
    print("ERROR: Could not find end of PBXBuildFile section")
    sys.exit(1)

new_build_file_lines = []

# Swift build files (Sources)
for filename, path in SWIFT_FILES:
    build_uuid = swift_build_refs[filename]
    file_uuid = swift_file_refs[filename]
    line = f"\t\t{build_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};"
    new_build_file_lines.append(line)

# JSON build files (Resources)
for filename in JSON_FILES:
    build_uuid = json_build_refs[filename]
    file_uuid = json_file_refs[filename]
    line = f"\t\t{build_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};"
    new_build_file_lines.append(line)

for i, line in enumerate(new_build_file_lines):
    lines.insert(end_build_file + i, line)
    print(f"  Added build file: {line.strip()[:80]}...")


# ============================================================
# 2. Add PBXFileReference entries
# ============================================================
print("\n--- Adding PBXFileReference entries ---")

end_file_ref = find_line("/* End PBXFileReference section */")
if end_file_ref == -1:
    print("ERROR: Could not find end of PBXFileReference section")
    sys.exit(1)

new_file_ref_lines = []

# Swift file references
for filename, path in SWIFT_FILES:
    file_uuid = swift_file_refs[filename]
    line = f"\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};"
    new_file_ref_lines.append(line)

# JSON file references
for filename in JSON_FILES:
    file_uuid = json_file_refs[filename]
    line = f"\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = text.json; path = {filename}; sourceTree = \"<group>\"; }};"
    new_file_ref_lines.append(line)

for i, line in enumerate(new_file_ref_lines):
    lines.insert(end_file_ref + i, line)
    print(f"  Added file ref: {line.strip()[:80]}...")


# ============================================================
# 3. Add Solutions PBXGroup (folder group under Resources)
# ============================================================
print("\n--- Adding Solutions PBXGroup ---")

# Find the Resources group: A10005010 /* Resources */
resources_group_line = find_line("A10005010 /* Resources */ = {")
if resources_group_line == -1:
    print("ERROR: Could not find Resources PBXGroup")
    sys.exit(1)

# Find the children closing ); for Resources group
resources_children_start = find_line("children = (", resources_group_line)
resources_children_end = find_line(");", resources_children_start)

# Add Solutions group reference to Resources group children
solutions_group_ref = f"\t\t\t\t{SOLUTIONS_GROUP_UUID} /* Solutions */,"
lines.insert(resources_children_end, solutions_group_ref)
print(f"  Added Solutions group ref to Resources children")

# Find the end of the Resources group block (the closing };)
resources_path_line = find_line("path = Resources;", resources_group_line)
resources_group_close = find_line("};", resources_path_line)

# Build the Solutions group block
solutions_group_lines = [
    f"\t\t{SOLUTIONS_GROUP_UUID} /* Solutions */ = {{",
    "\t\t\tisa = PBXGroup;",
    "\t\t\tchildren = (",
]
for filename in sorted(JSON_FILES):
    file_uuid = json_file_refs[filename]
    solutions_group_lines.append(f"\t\t\t\t{file_uuid} /* {filename} */,")
solutions_group_lines.extend([
    "\t\t\t);",
    "\t\t\tpath = Solutions;",
    "\t\t\tsourceTree = \"<group>\";",
    "\t\t};",
])

# Insert the new group block after the Resources group closing };
insert_point = resources_group_close + 1
for i, line in enumerate(solutions_group_lines):
    lines.insert(insert_point + i, line)
    print(f"  Inserted group line: {line.strip()}")


# ============================================================
# 4. Add Swift files to the Models PBXGroup
# ============================================================
print("\n--- Adding Swift files to Models PBXGroup ---")

models_group_line = find_line("A10005004 /* Models */ = {")
if models_group_line == -1:
    print("ERROR: Could not find Models PBXGroup")
    sys.exit(1)

# Find the closing ); of the Models group children
models_children_start = find_line("children = (", models_group_line)
models_children_end = find_line(");", models_children_start)

new_model_children = []
for filename, path in SWIFT_FILES:
    file_uuid = swift_file_refs[filename]
    new_model_children.append(f"\t\t\t\t{file_uuid} /* {filename} */,")

for i, line in enumerate(new_model_children):
    lines.insert(models_children_end + i, line)
    print(f"  Added to Models group: {line.strip()}")


# ============================================================
# 5. Add build file refs to Sources build phase (Swift files)
# ============================================================
print("\n--- Adding Swift files to Sources build phase ---")

# The main app Sources build phase: A10004002 /* Sources */
sources_phase_line = find_line("A10004002 /* Sources */ = {")
if sources_phase_line == -1:
    print("ERROR: Could not find Sources build phase A10004002")
    sys.exit(1)

sources_files_start = find_line("files = (", sources_phase_line)
sources_files_end = find_line(");", sources_files_start)

new_source_entries = []
for filename, path in SWIFT_FILES:
    build_uuid = swift_build_refs[filename]
    new_source_entries.append(f"\t\t\t\t{build_uuid} /* {filename} in Sources */,")

for i, line in enumerate(new_source_entries):
    lines.insert(sources_files_end + i, line)
    print(f"  Added to Sources phase: {line.strip()}")


# ============================================================
# 6. Add build file refs to Resources build phase (JSON files)
# ============================================================
print("\n--- Adding JSON files to Resources build phase ---")

# The main app Resources build phase: A10004003 /* Resources */
resources_phase_line = find_line("A10004003 /* Resources */ = {")
if resources_phase_line == -1:
    print("ERROR: Could not find Resources build phase A10004003")
    sys.exit(1)

resources_files_start = find_line("files = (", resources_phase_line)
resources_files_end = find_line(");", resources_files_start)

new_resource_entries = []
for filename in JSON_FILES:
    build_uuid = json_build_refs[filename]
    new_resource_entries.append(f"\t\t\t\t{build_uuid} /* {filename} in Resources */,")

for i, line in enumerate(new_resource_entries):
    lines.insert(resources_files_end + i, line)
    print(f"  Added to Resources phase: {line.strip()}")


# ============================================================
# Write back
# ============================================================
print("\n--- Writing modified pbxproj ---")

output = "\n".join(lines)
with open(PBXPROJ_PATH, "w") as f:
    f.write(output)

original_line_count = len(content.split("\n"))
new_line_count = len(lines)
print(f"Done! Modified {PBXPROJ_PATH}")
print(f"Lines: {original_line_count} -> {new_line_count} (+{new_line_count - original_line_count})")
