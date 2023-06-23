source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'WSDOT' do
    pod 'Google-Mobile-Ads-SDK'
    pod 'Firebase/Analytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/Performance'
    pod 'Firebase/Crashlytics'
    pod 'GoogleMaps', '~> 3.7.0'
    pod 'RealmSwift', '~> 10.40.2'
    pod 'Alamofire', '~> 5.7.1'
    pod 'SwiftyJSON', '~> 5.0.1'
    pod 'SDWebImage', '~> 5.16.0'
    pod 'EasyTipView', '~> 2.1.0'
    pod 'NotificationBannerSwift', '3.1.0'
end

target 'WSDOTTests' do
    pod 'Google-Mobile-Ads-SDK'
    pod 'Firebase/Analytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/Performance'
    pod 'Firebase/Crashlytics'
    pod 'GoogleMaps', '~> 3.7.0'
    pod 'RealmSwift', '~> 10.40.2'
    pod 'Alamofire', '~> 5.7.1'
    pod 'SwiftyJSON', '~> 5.0.1'
    pod 'SDWebImage', '~> 5.16.0'
    pod 'EasyTipView', '~> 2.1.0'
    pod 'NotificationBannerSwift', '3.1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
