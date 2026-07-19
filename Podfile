inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'

target :'Lockdown' do
  plugin 'cocoapods-acknowledgements', :settings_bundle => true
  pod 'AwesomeSpotlightView'
  pod 'RQShineLabel'
  pod 'NicoProgress'
  pod 'SwiftMessages', '6.0.0'
  pod 'PromiseKit'
  pod 'SwiftyStoreKit', '0.13.1'
  pod 'KeychainAccess'
  pod 'PopupDialog', '~> 0.9'
  pod 'SwiftCSV'
end

target :'LockdownTunnel' do
  pod 'PromiseKit'
  pod 'SwiftyStoreKit', '0.13.1'
  pod 'KeychainAccess'
end

target :'Lockdown VPN Widget' do
  pod 'PromiseKit'
  pod 'SwiftyStoreKit', '0.13.1'
  pod 'KeychainAccess'
end

target :'Lockdown Firewall Widget' do
  pod 'PromiseKit'
  pod 'SwiftyStoreKit', '0.13.1'
  pod 'KeychainAccess'
end

target :'LockdownTests' do
  # see https://github.com/pointfreeco/swift-snapshot-testing/pull/308
  pod 'SnapshotTesting', :git => 'https://github.com/pointfreeco/swift-snapshot-testing.git', :commit => '8e9f685'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end

  swift_messages_xibs = Dir.glob(File.join(__dir__, 'Pods/SwiftMessages/SwiftMessages/Resources/*.xib'))
  swift_messages_xibs.each do |path|
    contents = File.read(path)
    updated_contents = contents.gsub(
      /<deployment version="[^"]+" identifier="iOS"\/>/,
      '<deployment identifier="iOS"/>'
    )
    File.write(path, updated_contents) if contents != updated_contents
  end

  framework_header_globs = {
    'DynamicBlurView' => [
      'Pods/Target Support Files/DynamicBlurView/DynamicBlurView-umbrella.h'
    ],
    'PromiseKit' => [
      'Pods/PromiseKit/**/*.h',
      'Pods/Target Support Files/PromiseKit/PromiseKit-umbrella.h'
    ],
    'RQShineLabel' => [
      'Pods/Target Support Files/RQShineLabel/RQShineLabel-umbrella.h'
    ]
  }
  framework_header_globs.each do |module_name, globs|
    globs.flat_map { |glob| Dir.glob(File.join(__dir__, glob)) }.each do |path|
      contents = File.read(path)
      updated_contents = contents.gsub(/^#(import|include) "([^"]+)"/) do
        "##{Regexp.last_match(1)} <#{module_name}/#{Regexp.last_match(2)}>"
      end
      if contents != updated_contents
        File.chmod(0o644, path)
        File.write(path, updated_contents)
      end
    end
  end
end
