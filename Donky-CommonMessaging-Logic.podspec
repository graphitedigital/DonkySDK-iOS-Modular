Pod::Spec.new do |s|
  s.name             = "Donky-CommonMessaging-Logic"
  s.version          = "4.8.6.1"
  s.summary          = "The shared messaging logic"
  s.description      = <<-DESC
                       Only manually import this Pod if you wish to create your own completely Bespoke messaging UI. This contains central logic around changing the state of internal messages and reporting these back to the Donky Network. 
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", 
                         :tag => 'v4.8.6.1' }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Common/Logic/**/*.{h,m}'
  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency "Donky-Core-SDK"
  
end
