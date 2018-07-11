Pod::Spec.new do |s|
  s.name             = "Donky-RichMessage-PopUp"
  s.version          = "4.9.0.0"
  s.summary          = "The complete Simple Push Module"
  s.description      = <<-DESC
                       This is the Rich Message PopUp, it includes everything to receive rich messages and display them to your users. Once the user closes the 'pop up' window, the messages are then destroyed (this can be toggled via the API).
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :branch => 'swift/4.9.0.0'  }
  s.social_media_url = 'https://twitter.com/mobiledonky'
  
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.deprecated = true
  
  s.source_files = 'src/modules/Messaging/Rich/Logic/**/*.{h,m}'

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-CommonMessaging-Logic"
  
end
