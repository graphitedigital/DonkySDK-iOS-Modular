Pod::Spec.new do |s|
  s.name             = "Donky-RichMessage-Inbox"
  s.version          = "4.8.6.3"

  s.summary          = "The base logic layer required to handle incoming Remote notifications and also Simple Push messages stored on the server."
  s.description      = <<-DESC
                       This is the Rich Message inbox, it includes everything to receive rich messages and display them to your users.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" } 
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.8.6.3'  }


  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Rich/UI/Inbox/**/*.{h,m}'
  s.resources = ["src/modules/Messaging/Rich/UI/Inbox/Assets/**/*.png"]
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-RichMessage-Logic"

  
end
