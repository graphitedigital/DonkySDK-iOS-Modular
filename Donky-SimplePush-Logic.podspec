Pod::Spec.new do |s|
  s.name             = "Donky-SimplePush-Logic"
  s.version          = "1.0.4.1"
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

  s.source_files = 'src/modules/Messaging/Simple\ Push/Push\ Logic/**/*'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AFNetworking', '~> 2.3', 'Donky-Core-SDK', '~> 1.0' 
  
end
