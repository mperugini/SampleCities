# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'SmartCityExploration' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Architecture
  pod 'Factory', '~> 2.3'  # Lightweight DI for Swift 6
  
  # Performance Monitoring
  pod 'Firebase/Performance'
  pod 'Firebase/Analytics'
  
  # Swift 6 compatibility
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '6.0'
        config.build_settings['SWIFT_STRICT_CONCURRENCY'] = 'complete'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
        config.build_settings['ENABLE_TESTABILITY'] = true
      end
    end
  end
end
