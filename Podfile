source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'WSDOT' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Messaging'
    pod 'Firebase/Performance'
    pod 'Fabric', '~> 1.10.2'
    pod 'Crashlytics', '~> 3.14.0'
    pod 'GoogleMaps', '~> 3.7.0'
    pod 'RealmSwift', '~> 4.3.2'
    pod 'Alamofire', '~> 5.0.0'
    pod 'SwiftyJSON', '~> 4.2.0'
    pod 'SDWebImage', '~> 5.5.2'
    pod 'EasyTipView', '~> 2.0.4'
    pod 'NotificationBannerSwift', '3.0.2'
end

target 'WSDOTTests' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Messaging'
    pod 'Firebase/Performance'
    pod 'Fabric', '~> 1.10.2'
    pod 'Crashlytics', '~> 3.14.0'
    pod 'GoogleMaps', '~> 3.7.0'
    pod 'RealmSwift', '~> 4.3.2'
    pod 'Alamofire', '~> 5.0.0'
    pod 'SwiftyJSON', '~> 4.2.0'
    pod 'SDWebImage', '~> 5.5.2'
    pod 'EasyTipView', '~> 2.0.4'
    pod 'NotificationBannerSwift', '3.0.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
