import os
from pbxproj import XcodeProject

def sync_project(project_dir, project_name):
    pbx_path = os.path.join(project_dir, f"{project_name}.xcodeproj", "project.pbxproj")
    if not os.path.exists(pbx_path):
        print(f"Skipping {project_name}, not found.")
        return

    project = XcodeProject.load(pbx_path)
    
    # 1. Find all swift files currently in the project
    file_refs = project.objects.get_objects_in_section('PBXFileReference')
    
    # Track paths that are in the project to identify missing ones
    in_project_paths = []
    to_delete = []
    
    for obj in file_refs:
        # Check if it's a swift file
        path = getattr(obj, 'path', None)
        if getattr(obj, 'lastKnownFileType', None) == 'sourcecode.swift' or getattr(obj, 'explicitFileType', None) == 'sourcecode.swift' or (path and path.endswith('.swift')):
            pass
            
    # Actually, a better approach is to simply use the built-in methods.
    # Let's manually collect all physical .swift files
    physical_files = []
    for root, dirs, files in os.walk(os.path.join(project_dir, project_name)):
        for file in files:
            if file.endswith('.swift'):
                physical_files.append(os.path.join(root, file))
                
    # Now try to add each physical file. pbxproj `add_file` returns False if it's already there (usually).
    # We will pass force=False to avoid duplicates.
    print(f"Adding files for {project_name}...")
    for file_path in physical_files:
        # Add the file. We need to put it in the target.
        # But wait, pbxproj add_file doesn't create groups automatically if we don't specify the parent.
        # So we just add it to the project root group, or let XcodeProject do it.
        # Let's use add_file.
        # We can specify the tree as 'SOURCE_ROOT'
        # To avoid duplicating references, let's first check if the file name is in the project
        file_name = os.path.basename(file_path)
        existing = project.get_files_by_name(file_name)
        
        if not existing:
            print(f"Adding missing file: {file_name}")
            project.add_file(file_path, tree='SOURCE_ROOT', target_name=project_name)
            
    # Now for deletions
    print(f"Removing missing files for {project_name}...")
    for obj in project.objects.get_objects_in_section('PBXFileReference'):
        path = getattr(obj, 'path', None)
        if path and path.endswith('.swift'):
            # The path could be just the filename or a relative path.
            # Let's search if this filename exists in our physical files
            file_name = os.path.basename(path)
            found = any(f.endswith(file_name) for f in physical_files)
            if not found:
                print(f"Removing deleted file from project: {path}")
                project.remove_file_by_id(obj.get_id())
                
    project.save()
    print(f"Saved {project_name}.")

# Sync both projects
sync_project("Courier", "Courier")
sync_project("Customer", "Customer")
