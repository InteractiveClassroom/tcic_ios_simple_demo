# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'tcic_ios_simple_demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for tcic_ios_simple_demo
  pod 'tcic_ios', :podspec => 'https://ios.qcloudclass.com/1.1.2/tcic_ios.podspec?time=20260126'

  target 'tcic_ios_simple_demoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'tcic_ios_simple_demoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  require 'fileutils'

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 统一把 Pods 的最低支持版本抬到 iOS 12，避免 Xcode 15.x 对 8.0/9.0 的告警
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'

      # Intel Mac 上只需要 x86_64 simulator，避免 Pod 的 Copy XCFrameworks 脚本去找 ios-arm64_x86_64-simulator slice
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
