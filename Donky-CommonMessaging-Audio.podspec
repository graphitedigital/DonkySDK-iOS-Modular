Pod::Spec.new do |s|
  s.name             = "Donky-CommonMessaging-Audio"
  s.version          = "4.9.0.1"

  s.summary          = "The shared messaging Audio"
  s.description      = <<-DESC
                       Only manually import this Pod if you wish Donky to use audio, this includes vibrations.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", 
                         :branch => 'swift/4.9.0.0' }


  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Common/Audio/**/*.{h,m}'

  s.resources = ["src/modules/Messaging/Common/Audio/Assets/*.mp3"]

  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation'
  
  s.dependency "Donky-Core-SDK"
    
end
