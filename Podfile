source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'WSDOT' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Messaging'
    pod 'GoogleMaps', '~> 2.5.0'
    pod 'RealmSwift', '~> 3.10.0'
    pod 'Alamofire', '~> 4.7.3'
    pod 'SwiftyJSON', '~> 4.1.0'
    pod 'SDWebImage', '~> 4.3.3'
    pod 'EasyTipView', '~> 2.0.0'
    pod 'SCLAlertView', '~> 0.8.0'
end

target 'WSDOTTests' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Messaging'
    pod 'GoogleMaps', '~> 2.5.0'
    pod 'RealmSwift', '~> 3.10.0'
    pod 'Alamofire', '~> 4.7.3'
    pod 'SwiftyJSON', '~> 4.1.0'
    pod 'SDWebImage', '~> 4.3.3'
    pod 'EasyTipView', '~> 2.0.0'
    pod 'SCLAlertView', '~> 0.8.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
    end
  end
end
