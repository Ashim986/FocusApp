#!/usr/bin/env ruby
# Adds LeetCodeLoginSheet.swift to the Xcode project.pbxproj
#
# What it does:
# 1. Adds a PBXFileReference for the file
# 2. Adds a PBXBuildFile entry for the FocusApp main target
# 3. Adds the file reference to the Settings group (under Views/Settings)
# 4. Adds the build file to the FocusApp target's PBXSourcesBuildPhase

require 'fileutils'

PROJECT_FILE = File.join(__dir__, '..', 'FocusApp.xcodeproj', 'project.pbxproj')
FILE_NAME = 'LeetCodeLoginSheet.swift'

# Unique IDs with E1A1 prefix
FILE_REF_ID   = 'E1A10001' # PBXFileReference ID
BUILD_FILE_ID = 'E1A10002' # PBXBuildFile ID

# Known IDs from the project file
SETTINGS_GROUP_ID   = 'A1000500D'  # Settings group under Views
SOURCES_PHASE_ID    = 'A10004002'  # FocusApp target's PBXSourcesBuildPhase

# Read the project file
content = File.read(PROJECT_FILE)

# Safety check: don't add if already present
if content.include?(FILE_NAME)
  puts "WARNING: #{FILE_NAME} already exists in project.pbxproj. Aborting."
  exit 0
end

# Make a backup
backup_path = PROJECT_FILE + '.bak'
FileUtils.cp(PROJECT_FILE, backup_path)
puts "Backup created at #{backup_path}"

# 1. Add PBXFileReference
# Insert before "/* End PBXFileReference section */"
file_ref_line = "\t\t#{FILE_REF_ID} /* #{FILE_NAME} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = #{FILE_NAME}; sourceTree = \"<group>\"; };"

unless content.sub!("/* End PBXFileReference section */", "#{file_ref_line}\n/* End PBXFileReference section */")
  puts "ERROR: Could not find PBXFileReference section end marker."
  exit 1
end
puts "Added PBXFileReference."

# 2. Add PBXBuildFile
# Insert before "/* End PBXBuildFile section */"
build_file_line = "\t\t#{BUILD_FILE_ID} /* #{FILE_NAME} in Sources */ = {isa = PBXBuildFile; fileRef = #{FILE_REF_ID} /* #{FILE_NAME} */; };"

unless content.sub!("/* End PBXBuildFile section */", "#{build_file_line}\n/* End PBXBuildFile section */")
  puts "ERROR: Could not find PBXBuildFile section end marker."
  exit 1
end
puts "Added PBXBuildFile."

# 3. Add file reference to the Settings group (A1000500D)
# The group's children list ends with ");" before "path = Settings;"
# We match the entire children block and insert before its closing ");".
settings_group_pattern = /(#{Regexp.escape(SETTINGS_GROUP_ID)} \/\* Settings \*\/ = \{\s*isa = PBXGroup;\s*children = \((?:.*?)\n)(\s*\);\s*\n\s*path = Settings;)/m

if content.match?(settings_group_pattern)
  content.sub!(settings_group_pattern) do
    "#{$1}\t\t\t\t#{FILE_REF_ID} /* #{FILE_NAME} */,\n#{$2}"
  end
  puts "Added file reference to Settings group."
else
  puts "ERROR: Could not find Settings group (#{SETTINGS_GROUP_ID})."
  FileUtils.cp(backup_path, PROJECT_FILE)
  exit 1
end

# 4. Add build file to FocusApp target's PBXSourcesBuildPhase
# Match the sources phase and insert before the closing ");" of its files list
sources_phase_pattern = /(#{Regexp.escape(SOURCES_PHASE_ID)} \/\* Sources \*\/ = \{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = \d+;\s*files = \((?:.*?)\n)(\s*\);\s*\n\s*runOnlyForDeploymentPostprocessing)/m

if content.match?(sources_phase_pattern)
  content.sub!(sources_phase_pattern) do
    "#{$1}\t\t\t\t#{BUILD_FILE_ID} /* #{FILE_NAME} in Sources */,\n#{$2}"
  end
  puts "Added build file to FocusApp Sources build phase."
else
  puts "ERROR: Could not find Sources build phase (#{SOURCES_PHASE_ID})."
  FileUtils.cp(backup_path, PROJECT_FILE)
  exit 1
end

# Write the modified content
File.write(PROJECT_FILE, content)
puts "Successfully added #{FILE_NAME} to project.pbxproj"
puts "  File Reference ID: #{FILE_REF_ID}"
puts "  Build File ID:     #{BUILD_FILE_ID}"
