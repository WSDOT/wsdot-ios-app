source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'WSDOT' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'GoogleMaps'
    pod 'Google/Analytics'
    pod 'RealmSwift', '~> 1.1.0'
    pod 'Alamofire', '~> 3.5.0'
    pod 'SwiftyJSON'
    pod 'SDWebImage'
end

target 'WSDOTTests' do
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'GoogleMaps'
    pod 'Google/Analytics'
    pod 'RealmSwift', '~> 1.1.0'
    pod 'Alamofire', '~> 3.5.0'
    pod 'SwiftyJSON'
    pod 'SDWebImage'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3' # or '3.0'
    end
  end
end
