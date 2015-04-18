Pod::Spec.new do |s|
  s.name             = "Donky-CommonMessaging-Logic"
  s.version          = "0.0.1"
  s.summary          = "The shared messaging logic"
  s.description      = <<-DESC
                       This contains all shared logic for Socail/Messaging funtiocnality.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Common/Logic/**/*',  
  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency 'Donky-Core-SDK', '~> 1.0.0.0'
  
end
