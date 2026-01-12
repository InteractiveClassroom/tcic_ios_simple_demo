# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'tcic_ios_simple_demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for tcic_ios_simple_demo
  pod 'tcic_ios', :podspec => 'https://ios.qcloudclass.com/1.0.11/tcic_ios.podspec?time=122901'

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

  # tcic_ios 1.0.11 的源码在 Xcode 15.2 / Swift 5.9 下会因为 `some UIViewController`
  # 导致 `UIViewControllerRepresentable` 的关联类型推导失败，从而编译报错。
  # 这里在每次 `pod install` 后自动打补丁，避免手工改 Pods 内容。
  tcic_manager = File.join(installer.sandbox.root.to_s, 'tcic_ios', 'TCIC_IOS', 'TCICManager.swift')
  if File.exist?(tcic_manager)
    FileUtils.chmod('u+w', tcic_manager) rescue nil

    content = File.read(tcic_manager)
    patched = content

    patched = patched.gsub(
      'public func makeUIViewController(context: Context) -> some UIViewController {',
      "public typealias UIViewControllerType = TCICViewController\\n\\n    public func makeUIViewController(context: Context) -> TCICViewController {"
    )
    patched = patched.gsub(
      'public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}',
      'public func updateUIViewController(_ uiViewController: TCICViewController, context: Context) {}'
    )
    patched = patched.gsub(
      'public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: ()) {',
      'public static func dismantleUIViewController(_ uiViewController: TCICViewController, coordinator: ()) {'
    )

    File.write(tcic_manager, patched) if patched != content
  end
end
