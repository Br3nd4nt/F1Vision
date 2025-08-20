# Uncomment the next line to define a global platform for your project
platform :ios, '18.0'

# Set deployment target for all pods
install! 'cocoapods', :deterministic_uuids => false

target 'F1Vision' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # MARK: - Code Quality
  pod 'SwiftLint', '~> 0.59.1'
  
  # MARK: - WebSocket (Fast & Reliable)
  pod 'Starscream', '~> 4.0'           # High-performance WebSocket library
  
  # MARK: - Dependency Injection
  pod 'Swinject', '~> 2.8'             # Lightweight DI container
  
  # MARK: - Debugging & Development
  pod 'FLEX', '~> 5.0'                 # In-app debugging tools (Debug only)
  
  # MARK: - Type-Safe Resources
  pod 'R.swift', '~> 7.0'              # Strong typed, autocompleted resources
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
      
      # Enable arm64 for simulator (for Apple Silicon Macs)
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
