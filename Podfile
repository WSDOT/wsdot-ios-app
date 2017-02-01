source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'WSDOT' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'GoogleMaps'
    pod 'Google/Analytics'
    pod 'RealmSwift', '~> 2.4.2'
    pod 'Alamofire', '~> 4.2.0'
    pod 'SwiftyJSON', '~> 3.1.3'
    pod 'SDWebImage'
end

target 'WSDOTTests' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'GoogleMaps'
    pod 'Google/Analytics'
    pod 'RealmSwift', '~> 2.4.2'
    pod 'Alamofire', '~> 4.2.0'
    pod 'SwiftyJSON', '~> 3.1.3'
    pod 'SDWebImage'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
