Pod::Spec.new do |s|
  s.name             = "Donky-SimplePush-UI"
  s.version          = "4.7.0.1"
  s.summary          = "The complete Simple Push Module"
  s.description      = <<-DESC
                       This is the Simple Push UI, it includes everthirng you need to receive Simple Push messages as well as utilising Donky's built in app Banner View and analytics.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.7.0.0' }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  
  s.source_files = 'src/modules/Messaging/SimplePush/Logic/**/*.{h,m}'
 
  s.deprecated = true
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-CommonMessaging-Logic"
  
end
