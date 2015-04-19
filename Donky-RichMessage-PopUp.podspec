Pod::Spec.new do |s|
  s.name             = "Donky-RichMessage-PopUp"
  s.version          = "2.2"
  s.summary          = "The complete Simple Push Module"
  s.description      = <<-DESC
                       This is the Rich Message PopUp, it includes everything to receive rich messages and display them to your users. Once the user closes the 'pop up' window, the messages are destriy (this can be toggled via the API).
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Rich/UI/**/*.{h,m}'

  s.resources = 'src/modules/Messaging/Simple\ Push/Push\ UI/Helpers/Images'
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Donky-RichMessage-Logic', '~> 2.0'
  s.dependency 'Donky-CommonMessaging-UI', '~> 2.0'
  
end
