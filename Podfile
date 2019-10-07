source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'WSDOT' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Messaging'
    pod 'Firebase/Performance'
    pod 'Fabric', '~> 1.9.0'
    pod 'Crashlytics', '~> 3.12.0'
    pod 'GoogleMaps', '~> 2.6.0'
    pod 'RealmSwift', '~> 3.18.0'
    pod 'Alamofire', '~> 4.8.0'
    pod 'SwiftyJSON', '~> 4.2.0'
    pod 'SDWebImage', '~> 4.3.3'
    pod 'EasyTipView', '~> 2.0.1'
    pod 'NotificationBannerSwift', '2.0.1'
end

target 'WSDOTTests' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Messaging'
    pod 'Firebase/Performance'
    pod 'Fabric', '~> 1.9.0'
    pod 'Crashlytics', '~> 3.12.0'
    pod 'GoogleMaps', '~> 2.6.0'
    pod 'RealmSwift', '~> 3.18.0'
    pod 'Alamofire', '~> 4.8.0'
    pod 'SwiftyJSON', '~> 4.2.0'
    pod 'SDWebImage', '~> 4.3.3'
    pod 'EasyTipView', '~> 2.0.1'
    pod 'NotificationBannerSwift', '2.0.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end
