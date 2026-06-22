require 'xcodeproj'
require 'pathname'

def sync_project(project_path, target_name)
  puts "Syncing #{project_path}..."
  project = Xcodeproj::Project.open(project_path)
  target = project.targets.find { |t| t.name == target_name }
  
  if target.nil?
    puts "Target #{target_name} not found!"
    return
  end

  source_dir = Pathname.new(project_path).dirname.join(target_name)
  
  # Find all physical Swift files
  physical_files = Dir.glob("#{source_dir}/**/*.swift")
  
  # Get all files currently in the compile phase
  compile_phase = target.source_build_phase
  existing_paths = compile_phase.files.filter_map { |file| file.file_ref&.real_path&.to_s }
  
  physical_files.each do |file_path|
    unless existing_paths.include?(file_path)
      puts "Adding missing file: #{file_path}"
      # Add file to the project relative to the main group
      group_path = Pathname.new(file_path).dirname.relative_path_from(source_dir).to_s
      
      # Find or create group
      group = project.main_group.find_subpath(File.join(target_name, group_path), true)
      group.set_source_tree('<group>')
      
      file_ref = group.new_reference(file_path)
      compile_phase.add_file_reference(file_ref)
    end
  end
  
  # Remove missing files from compile phase
  compile_phase.files.each do |build_file|
    file_ref = build_file.file_ref
    if file_ref
      path = file_ref.real_path.to_s
      unless File.exist?(path)
        puts "Removing deleted file reference: #{path}"
        build_file.remove_from_project
        file_ref.remove_from_project
      end
    end
  end

  project.save
  puts "Saved #{project_path}."
end

sync_project('Courier/Courier.xcodeproj', 'Courier')
sync_project('Customer/Customer.xcodeproj', 'Customer')
