#!/usr/bin/env ruby
# Adds 4 Coordination test files to the FocusAppTests target in project.pbxproj

PROJECT_FILE = File.join(__dir__, 'FocusApp.xcodeproj', 'project.pbxproj')

# Read the file
content = File.read(PROJECT_FILE)

# Define file references and build file IDs (D7A1 prefix to avoid conflicts)
files = [
  {
    name: 'ContentCoordinatorTests.swift',
    file_ref: 'D7A10001AAAA111122223333',
    build_file: 'D7A10002BBBB111122223333',
  },
  {
    name: 'CodingCoordinatorTests.swift',
    file_ref: 'D7A10003CCCC111122223333',
    build_file: 'D7A10004DDDD111122223333',
  },
  {
    name: 'WidgetCoordinatorTests.swift',
    file_ref: 'D7A10005EEEE111122223333',
    build_file: 'D7A10006FFFF111122223333',
  },
  {
    name: 'FocusCoordinatorTests.swift',
    file_ref: 'D7A10007AAAA222233334444',
    build_file: 'D7A10008BBBB222233334444',
  },
]

# Verify no conflicts
files.each do |f|
  if content.include?(f[:file_ref]) || content.include?(f[:build_file])
    puts "ERROR: ID conflict detected for #{f[:name]}"
    exit 1
  end
end

puts "No ID conflicts found. Proceeding..."

# 1. Add PBXBuildFile entries (in the PBXBuildFile section)
build_file_entries = files.map do |f|
  "\t\t#{f[:build_file]} /* #{f[:name]} in Sources */ = {isa = PBXBuildFile; fileRef = #{f[:file_ref]} /* #{f[:name]} */; };"
end.join("\n")

# Insert before "/* End PBXBuildFile section */"
unless content.sub!("/* End PBXBuildFile section */", "#{build_file_entries}\n/* End PBXBuildFile section */")
  puts "ERROR: Could not find /* End PBXBuildFile section */"
  exit 1
end
puts "Added PBXBuildFile entries."

# 2. Add PBXFileReference entries (in the PBXFileReference section)
file_ref_entries = files.map do |f|
  "\t\t#{f[:file_ref]} /* #{f[:name]} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = #{f[:name]}; sourceTree = \"<group>\"; };"
end.join("\n")

# Insert before "/* End PBXFileReference section */"
unless content.sub!("/* End PBXFileReference section */", "#{file_ref_entries}\n/* End PBXFileReference section */")
  puts "ERROR: Could not find /* End PBXFileReference section */"
  exit 1
end
puts "Added PBXFileReference entries."

# 3. Create a new "Coordination" PBXGroup and add it to FocusAppTests group
coordination_group_id = 'D7A10009CCCC222233334444'

children_list = files.map do |f|
  "\t\t\t\t#{f[:file_ref]} /* #{f[:name]} */,"
end.join("\n")

coordination_group = "\t\t#{coordination_group_id} /* Coordination */ = {\n" \
  "\t\t\tisa = PBXGroup;\n" \
  "\t\t\tchildren = (\n" \
  "#{children_list}\n" \
  "\t\t\t);\n" \
  "\t\t\tpath = Coordination;\n" \
  "\t\t\tsourceTree = \"<group>\";\n" \
  "\t\t};\n"

# Insert before "/* End PBXGroup section */"
unless content.sub!("/* End PBXGroup section */", "#{coordination_group}/* End PBXGroup section */")
  puts "ERROR: Could not find /* End PBXGroup section */"
  exit 1
end
puts "Added Coordination PBXGroup."

# 4. Add the Coordination group reference to the FocusAppTests PBXGroup children
# The FocusAppTests group is E3BDFC6AC2C94292AEFE137B
# Insert after the last existing child (50F172123351462DA7C6FA81 /* Support */)
pattern4 = /(50F172123351462DA7C6FA81 \/\* Support \*\/,\n)(\t\t\t\);\n\t\t\tpath = FocusAppTests;)/
replacement4 = "\\1\t\t\t\t#{coordination_group_id} /* Coordination */,\n\\2"
unless content.sub!(pattern4, replacement4)
  puts "ERROR: Could not find FocusAppTests group to add Coordination child"
  exit 1
end
puts "Added Coordination group to FocusAppTests children."

# 5. Add build file references to FocusAppTests Sources build phase (F250B49CEB074B259AD2B1C8)
build_file_refs = files.map do |f|
  "\t\t\t\t#{f[:build_file]} /* #{f[:name]} in Sources */,"
end.join("\n")

# Insert after the last existing entry in FocusAppTests Sources build phase
pattern5 = /(7D5E84A37E0A1AC32E2934A6 \/\* TopicSolutionStoreTests\.swift in Sources \*\/,\n)(\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\};\n\t\tC6980DD47C124E11957094DA)/
replacement5 = "\\1#{build_file_refs}\n\\2"
unless content.sub!(pattern5, replacement5)
  puts "ERROR: Could not find FocusAppTests Sources build phase to add files"
  exit 1
end
puts "Added build files to FocusAppTests Sources build phase."

# Write the file
File.write(PROJECT_FILE, content)

puts "\nSuccessfully added 4 Coordination test files to FocusAppTests target."
puts "Files added:"
files.each { |f| puts "  - #{f[:name]} (ref: #{f[:file_ref]}, build: #{f[:build_file]})" }
puts "Coordination group: #{coordination_group_id}"
