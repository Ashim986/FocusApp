#!/usr/bin/env ruby
# frozen_string_literal: true

# This script adds 7 Coordination files to the Xcode project.pbxproj file.
# It creates:
#   - PBXFileReference entries for each .swift file
#   - PBXBuildFile entries for each file (compile sources)
#   - A PBXGroup "Coordination" under the FocusApp group
#   - Entries in the FocusApp target's PBXSourcesBuildPhase

require 'fileutils'

PROJECT_FILE = File.join(__dir__, 'FocusApp.xcodeproj', 'project.pbxproj')
BACKUP_FILE  = PROJECT_FILE + '.backup'

# ── Files to add ──────────────────────────────────────────────────────────────
FILES = %w[
  Coordinating.swift
  NavigationState.swift
  AppCoordinator.swift
  ContentCoordinator.swift
  CodingCoordinator.swift
  WidgetCoordinator.swift
  FocusCoordinator.swift
].freeze

# ── Generate unique 24-character hex IDs ──────────────────────────────────────
content = File.read(PROJECT_FILE)
existing_ids = content.scan(/[A-Fa-f0-9]{24}/).map(&:upcase).to_set

def generate_id(existing)
  loop do
    id = Array.new(24) { rand(16).to_s(16).upcase }.join
    unless existing.include?(id)
      existing.add(id)
      return id
    end
  end
end

# For each file we need:
#   file_ref_id  -> PBXFileReference
#   build_id     -> PBXBuildFile
# Plus one group_id for the Coordination group.

file_entries = FILES.map do |name|
  {
    name:         name,
    file_ref_id:  generate_id(existing_ids),
    build_id:     generate_id(existing_ids),
  }
end

group_id = generate_id(existing_ids)

puts "Generated IDs:"
file_entries.each do |e|
  puts "  #{e[:name]}: fileRef=#{e[:file_ref_id]}  build=#{e[:build_id]}"
end
puts "  Coordination group: #{group_id}"

# ── Backup ────────────────────────────────────────────────────────────────────
FileUtils.cp(PROJECT_FILE, BACKUP_FILE)
puts "\nBackup saved to #{BACKUP_FILE}"

lines = File.readlines(PROJECT_FILE)

# ── 1. Add PBXBuildFile entries ───────────────────────────────────────────────
end_build_idx = lines.index { |l| l.include?('/* End PBXBuildFile section */') }
raise 'Cannot find End PBXBuildFile section' unless end_build_idx

build_lines = file_entries.map do |e|
  "\t\t#{e[:build_id]} /* #{e[:name]} in Sources */ = {isa = PBXBuildFile; fileRef = #{e[:file_ref_id]} /* #{e[:name]} */; };\n"
end

lines.insert(end_build_idx, *build_lines)

# ── 2. Add PBXFileReference entries ───────────────────────────────────────────
end_fileref_idx = lines.index { |l| l.include?('/* End PBXFileReference section */') }
raise 'Cannot find End PBXFileReference section' unless end_fileref_idx

fileref_lines = file_entries.map do |e|
  "\t\t#{e[:file_ref_id]} /* #{e[:name]} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = #{e[:name]}; sourceTree = \"<group>\"; };\n"
end

lines.insert(end_fileref_idx, *fileref_lines)

# ── 3. Add PBXGroup for Coordination ─────────────────────────────────────────
end_group_idx = lines.index { |l| l.include?('/* End PBXGroup section */') }
raise 'Cannot find End PBXGroup section' unless end_group_idx

children_list = file_entries.map { |e| "\t\t\t\t#{e[:file_ref_id]} /* #{e[:name]} */," }.join("\n")

group_block = <<~PBXGROUP
\t\t#{group_id} /* Coordination */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
#{children_list}
\t\t\t);
\t\t\tpath = Coordination;
\t\t\tsourceTree = "<group>";
\t\t};
PBXGROUP

lines.insert(end_group_idx, group_block)

# ── 4. Add Coordination group to FocusApp group's children ────────────────────
focusapp_path_idx = nil
lines.each_with_index do |line, idx|
  if line.strip == 'path = FocusApp;'
    focusapp_path_idx = idx
    break
  end
end
raise 'Cannot find FocusApp group (path = FocusApp;)' unless focusapp_path_idx

# Find the children block above this line
children_start = nil
(focusapp_path_idx - 1).downto(0) do |i|
  if lines[i].include?('children = (')
    children_start = i
    break
  end
end
raise 'Cannot find children = ( for FocusApp group' unless children_start

# Find closing );
children_end = nil
(children_start + 1).upto(lines.length - 1) do |i|
  if lines[i].strip == ');'
    children_end = i
    break
  end
end
raise 'Cannot find ); closing FocusApp group children' unless children_end

# Insert the Coordination group reference before the closing );
coordination_child_line = "\t\t\t\t#{group_id} /* Coordination */,\n"
lines.insert(children_end, coordination_child_line)

# ── 5. Add build file refs to FocusApp Sources build phase ────────────────────
sources_phase_idx = lines.index { |l| l.include?('A10004002 /* Sources */') && l.include?('{') }
raise 'Cannot find A10004002 Sources build phase' unless sources_phase_idx

# Find files = ( after this line
files_start = nil
(sources_phase_idx + 1).upto(lines.length - 1) do |i|
  if lines[i].include?('files = (')
    files_start = i
    break
  end
end
raise 'Cannot find files = ( in Sources build phase' unless files_start

# Find closing );
files_end = nil
(files_start + 1).upto(lines.length - 1) do |i|
  if lines[i].strip == ');'
    files_end = i
    break
  end
end
raise 'Cannot find ); closing Sources build phase files' unless files_end

# Insert build file references before the closing );
source_lines = file_entries.map do |e|
  "\t\t\t\t#{e[:build_id]} /* #{e[:name]} in Sources */,\n"
end

lines.insert(files_end, *source_lines)

# ── Write ─────────────────────────────────────────────────────────────────────
File.write(PROJECT_FILE, lines.join)

puts "\nDone! Added #{FILES.length} files to the Xcode project."
puts "  - #{FILES.length} PBXBuildFile entries"
puts "  - #{FILES.length} PBXFileReference entries"
puts "  - 1 PBXGroup (Coordination) with #{FILES.length} children"
puts "  - #{FILES.length} entries in FocusApp Sources build phase"
puts "  - Coordination group added to FocusApp group"
