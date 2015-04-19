Pod::Spec.new do |s|
  s.name             = "Donky-RichMessage-Logic"
  s.version          = "2.1"
  s.summary          = "The base logic layer required to handle incoming Rich Messages."
  s.description      = <<-DESC
                       This is the Rich Message logic , it contains all the logic necessary to receive and process inbound rich messages, saving them into the Database and recording analytics around delivery.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Rich/Logic/**/*.{h,m}'
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Donky-CommonMessaging-Logic', '~> 2.0'
  
end
