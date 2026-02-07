#!/usr/bin/env ruby
# frozen_string_literal: true

# This script adds three new Swift files to the Xcode project.pbxproj:
#   1. LeetCodeSubmissionService.swift -> Models group + FocusApp Sources
#   2. TestCaseAIService.swift         -> Models group + FocusApp Sources
#   3. CodingEnvironmentPresenter+LeetCodeSubmit.swift -> Execution group + FocusApp Sources
#
# The script is idempotent: if files are already present, it reports that and skips them.

require 'fileutils'

PBXPROJ = File.join(__dir__, '..', 'FocusApp.xcodeproj', 'project.pbxproj')

unless File.exist?(PBXPROJ)
  abort "ERROR: project.pbxproj not found at #{PBXPROJ}"
end

content = File.read(PBXPROJ)

# --- Files to add ---
FILES = [
  {
    name: 'LeetCodeSubmissionService.swift',
    ref_id:   'F2A10001A1B2C3D4E5F60001',
    build_id: 'F2A10002A1B2C3D4E5F60001',
    group: :models,
    quoted: false,
  },
  {
    name: 'TestCaseAIService.swift',
    ref_id:   'F2A10001A1B2C3D4E5F60002',
    build_id: 'F2A10002A1B2C3D4E5F60002',
    group: :models,
    quoted: false,
  },
  {
    name: 'CodingEnvironmentPresenter+LeetCodeSubmit.swift',
    ref_id:   'F2A10001A1B2C3D4E5F60003',
    build_id: 'F2A10002A1B2C3D4E5F60003',
    group: :execution,
    quoted: true,
  },
]

# --- Known anchors ---
# Last entry in Models group children
MODELS_ANCHOR    = 'A7F3B2C1D8E9F0A1B2C3D4E6 /* SolutionAIService.swift */,'
# Last entry in Execution group children
EXECUTION_ANCHOR = '91545BFE73ED44268B3DC9E8 /* LeetCodeExecutionWrapper+TypeParsing.swift */,'
# Last entry in FocusApp main target Sources build phase (A10004002)
SOURCES_ANCHOR   = 'E1A10002 /* LeetCodeLoginSheet.swift in Sources */,'

changed = false
all_present = true

FILES.each do |file|
  name = file[:name]
  # Check if this file is already referenced in the project
  if content.include?(name)
    puts "SKIP: #{name} already present in project.pbxproj"
    next
  end

  all_present = false

  # Create backup on first modification
  unless changed
    backup = "#{PBXPROJ}.backup"
    FileUtils.cp(PBXPROJ, backup)
    puts "Backup created: #{backup}"
    changed = true
  end

  ref_id   = file[:ref_id]
  build_id = file[:build_id]
  path_val = file[:quoted] ? "\"#{name}\"" : name

  # 1. PBXFileReference
  ref_line = "\t\t#{ref_id} /* #{name} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = #{path_val}; sourceTree = \"<group>\"; };\n"
  marker = '/* End PBXFileReference section */'
  content.sub!(marker, "#{ref_line}#{marker}")
  puts "Added PBXFileReference for #{name}."

  # 2. PBXBuildFile
  build_line = "\t\t#{build_id} /* #{name} in Sources */ = {isa = PBXBuildFile; fileRef = #{ref_id} /* #{name} */; };\n"
  marker = '/* End PBXBuildFile section */'
  content.sub!(marker, "#{build_line}#{marker}")
  puts "Added PBXBuildFile for #{name}."

  # 3. Group membership
  group_entry = "\t\t\t\t#{ref_id} /* #{name} */,"
  case file[:group]
  when :models
    if content.include?(MODELS_ANCHOR)
      content.sub!(MODELS_ANCHOR, "#{MODELS_ANCHOR}\n#{group_entry}")
      puts "Added #{name} to Models group."
    else
      puts "WARNING: Could not find Models group anchor."
    end
  when :execution
    if content.include?(EXECUTION_ANCHOR)
      content.sub!(EXECUTION_ANCHOR, "#{EXECUTION_ANCHOR}\n#{group_entry}")
      puts "Added #{name} to Execution group."
    else
      puts "WARNING: Could not find Execution group anchor."
    end
  end

  # 4. Sources build phase
  sources_entry = "\t\t\t\t#{build_id} /* #{name} in Sources */,"
  if content.include?(SOURCES_ANCHOR)
    content.sub!(SOURCES_ANCHOR, "#{SOURCES_ANCHOR}\n#{sources_entry}")
    puts "Added #{name} to FocusApp main target Sources build phase."
  else
    puts "WARNING: Could not find Sources build phase anchor."
  end

  puts ""
end

if all_present
  puts "\nAll 3 files are already present in project.pbxproj. No changes needed."
else
  File.write(PBXPROJ, content)
  puts "Done! project.pbxproj updated successfully."
end
