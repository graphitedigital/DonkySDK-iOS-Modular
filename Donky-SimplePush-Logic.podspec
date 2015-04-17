Pod::Spec.new do |s|
  s.name             = "Donky-SimplePush-Logic"
  s.version          = "1.0.4.2"
  s.summary          = "The base logic layer required to handle incoming Remote notifications and also Simple Push messages stored on the server."
  s.description      = <<-DESC
                       This is the Simple Push logic , it contains all of the API's requred to register with and send data over the Donky Network. If using any of the Donky-Modules then it is not necessary to also explicitly add this to your PodFile. 
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
  s.dependency 'Donky-Core-SDK', '~> 1.0' 
  
end
