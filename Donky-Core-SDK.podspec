#
# Be sure to run `pod lib lint Donky-Core-SDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Donky-Core-SDK"
  s.version          = "1.0.4.3"
  s.summary          = "The base logic to register and communicate with the Donky Network."
  s.description      = <<-DESC
                       This is the Donky Core SDK, it contains all of the API's requred to register with and send data over the Donky Network. If using any of the Donky-Modules then it is not necessary to also explicitly add this to your PodFile. 
                       DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = ['src/modules/Core/**/*', 'src/modules/Core\ Analytics/**/*']
  
  s.resources = ["src/modules/Core/App\ Settings\ Controller/Resources/DNConfiguration.plist", "src/modules/Core/Data\ Controller/Resources/DNDonkyDataModel.xcdatamodeld"]

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AFNetworking', '~> 2.3'
  
end
