Pod::Spec.new do |s|
  s.name             = "Donky-SimplePush-UI"
  s.version          = "2.0"
  s.summary          = "The complete Simple Push Module"
  s.description      = <<-DESC
                       This is the Simple Push UI, it includes everthirng you need to receive Simple Push messages as well as utilising Donky's built in app Banner View and analytics.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/Simple\ Push/**/*'
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Donky-SimplePush-Logic', '~> 2.0'
  s.dependency 'Donky-CommonMessaging-UI', '~> 2.0'
end
