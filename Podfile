source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'WSDOT' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'GoogleMaps', '~> 2.5.0'
    pod 'GoogleAnalytics'
    pod 'RealmSwift', '~> 3.0.2'
    pod 'Alamofire', '~> 4.5.1'
    pod 'SwiftyJSON', '~> 3.1.3'
    pod 'SDWebImage', '~> 4.2.3'
    pod 'EasyTipView', '~> 1.0.2'
    pod 'SCLAlertView'
end

target 'WSDOTTests' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'GoogleMaps', '~> 2.5.0'
    pod 'GoogleAnalytics'
    pod 'RealmSwift', '~> 3.0.2'
    pod 'Alamofire', '~> 4.5.1'
    pod 'SwiftyJSON', '~> 3.1.3'
    pod 'SDWebImage', '~> 4.2.3'
    pod 'EasyTipView', '~> 1.0.2'
    pod 'SCLAlertView'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
