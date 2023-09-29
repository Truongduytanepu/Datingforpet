# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PetDating' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  
  pod 'FirebaseAuth'
  pod 'FirebaseDatabase'
  pod 'Firebase/Storage'
  pod 'Firebase/Core'
  pod 'Kingfisher'
  pod "ESTabBarController-swift"
  pod 'ActionSheetPicker-3.0'
  pod "WARangeSlider"
  pod 'IQKeyboardManagerSwift'
  pod 'AnimatedCollectionViewLayout'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'SCLAlertView'
  pod 'ReachabilitySwift'
  pod 'MessageKit'
  
  # Pods for PetDating

end


post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
