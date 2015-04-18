Pod::Spec.new do |s|
  s.name             = "Donky-SimplePush-Logic"
  s.version          = "1.9.9.9"
  s.summary          = "The base logic layer required to handle incoming Remote notifications and also Simple Push messages stored on the server."
  s.description      = <<-DESC
                       This is the Simple Push logic , it contains all the logic necessary to receive and process remote notificaitons. As well as receive and process notifications via the Donky Backup channel.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = ['src/modules/Core/**/*', 'src/modules/Core\ Analytics/**/*' 'src/modules/Messaging/Common\ Messaging/Logic/**/*', 'src/modules/Messaging/Simple\ Push/Push\ Logic/**/*']
  
  s.resources = ["src/modules/Core/App\ Settings\ Controller/Resources/DNConfiguration.plist", "src/modules/Core/Data\ Controller/Resources/DNDonkyDataModel.xcdatamodeld"]
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AFNetworking', '~> 2.3'
end
