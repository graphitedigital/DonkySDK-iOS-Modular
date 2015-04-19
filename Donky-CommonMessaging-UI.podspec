Pod::Spec.new do |s|
  s.name             = "Donky-CommonMessaging-UI"
  s.version          = "2.1"
  s.summary          = "The shared messaging UI"
  s.description      = <<-DESC
                       This contains all shared UI Logic for Socail/Messaging funtiocnality.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Common/UI/**/*.{h,m}'
  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency 'Donky-CommonMessaging-Logic', '~> 2.0'
  s.dependency 'UIView-Autolayout', '~> 0.2'  
  
end
