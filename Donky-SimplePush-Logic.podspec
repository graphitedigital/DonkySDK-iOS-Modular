Pod::Spec.new do |s|
  s.name             = "Donky-SimplePush-Logic"
  s.version          = "4.7.0.1"
  s.summary          = "The base logic layer required to handle incoming Remote notifications and also Simple Push messages stored on the server."
  s.description      = <<-DESC
                       This is the Simple Push logic , it contains all the logic necessary to receive and process remote notificaitons. As well as receive and process notifications via the Donky Backup channel.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.7.0.0'  }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/SimplePush/Logic/**/*.{h,m}'
 
  s.deprecated_in_favour_of = "Donky-Push"
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-CommonMessaging-Logic"
  
end
