Pod::Spec.new do |s|
  s.name             = "Donky-CommonMessaging-UI"
  s.version          = "4.8.6.0"
  s.summary          = "The shared messaging UI"
  s.description      = <<-DESC
                       This contains all shared UI Logic for Socail/Messaging funtiocnality. Including the internal banner view, localization files and shared controllers around obtaining Rich Message view controllers.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.8.5.0' }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Common/UI/**/*.{h,m}'
  s.resources = ["src/modules/Messaging/Common/UI/Rich\ Modules/Localisation/DRLocalization.strings", "src/modules/Messaging/Common/UI/Localization/DCUILocalization.strings", "src/modules/Messaging/Common/UI/Donky\ Banner\ View/Assets/common_messaging_default_avatar.png", "src/modules/Messaging/Common/UI/Donky\ Banner\ View/Assets/common_messaging_default_avatar@2x.png"]
  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency "Donky-CommonMessaging-Logic"
  s.dependency 'UIView-Autolayout', '~> 0.2'  
  
end
