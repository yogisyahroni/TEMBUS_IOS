require 'xcodeproj'

def add_spm_dependency(project_path, target_name, pkg_url, version_requirement, products)
  project = Xcodeproj::Project.open(project_path)
  target = project.targets.find { |t| t.name == target_name }

  # Check if package already exists
  existing_pkg = project.root_object.package_references.find { |p| p.repositoryURL == pkg_url }
  
  unless existing_pkg
    puts "Adding package reference: #{pkg_url}"
    pkg_ref = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
    pkg_ref.repositoryURL = pkg_url
    pkg_ref.requirement = version_requirement
    project.root_object.package_references << pkg_ref
    existing_pkg = pkg_ref
  end

  products.each do |product_name|
    # Check if product is already added
    existing_prod = target.package_product_dependencies.find { |p| p.product_name == product_name }
    unless existing_prod
      puts "Adding product dependency: #{product_name}"
      prod_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
      prod_dep.package = existing_pkg
      prod_dep.product_name = product_name
      target.package_product_dependencies << prod_dep

      # Add to Frameworks build phase
      frameworks_phase = target.frameworks_build_phase
      build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
      build_file.product_ref = prod_dep
      frameworks_phase.files << build_file
    end
  end

  project.save
  puts "Saved #{project_path}"
end

# Customer App
add_spm_dependency(
  'Customer/Customer.xcodeproj',
  'Customer',
  'https://github.com/google/GoogleSignIn-iOS.git',
  { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => '7.0.0' },
  ['GoogleSignInSwift']
)

# Courier App
add_spm_dependency(
  'Courier/Courier.xcodeproj',
  'Courier',
  'https://github.com/stasel/WebRTC.git',
  { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => '111.0.0' },
  ['WebRTC']
)

add_spm_dependency(
  'Courier/Courier.xcodeproj',
  'Courier',
  'https://github.com/tomtom-international/tomtom-sdk-spm-core.git',
  { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => '0.70.0' },
  ['TomTomSDKMapDisplay']
)


# MLKit is not officially on SPM, but let's try this community mirror if it exists, or just use CocoaPods for it.
# Actually there's no official MLKit SPM. A common community mirror: https://github.com/d-date/google-mlkit-swiftpm
add_spm_dependency(
  'Courier/Courier.xcodeproj',
  'Courier',
  'https://github.com/d-date/google-mlkit-swiftpm.git',
  { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => '9.0.0' },
  ['MLKitFaceDetection']
)
