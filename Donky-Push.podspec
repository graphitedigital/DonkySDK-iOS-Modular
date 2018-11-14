Pod::Spec.new do |s|
  s.name             = "Donky-Push"
  s.version          = "4.9.0.1"

  s.summary          = "This is the Donky Push module , it contains all the logic necessary to receive and process remote notificaitons. As well as receive and process notifications via the Donky Backup channel"
  s.description      = <<-DESC
                       This is the Donky Push module , it contains all the logic necessary to receive and process remote notificaitons. As well as receive and process notifications via the Donky Backup channel.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.9.0.1'  }


  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Messaging/SimplePush/Logic/**/*.{h,m}', 'src/modules/Core/**/*.{h,m}', 'src/modules/Core\ Analytics/**/*.{h,m}'
 
  s.resources = ["src/modules/Core/App\ Settings\ Controller/Resources/DNConfiguration.plist", "src/modules/Core/Data\ Controller/Resources/DNDonkyDataModel.xcdatamodeld", "src/modules/Core/Universal\ Helpers/Localization/DNLocalization.strings"]

  s.frameworks = 'UIKit', 'Foundation'
  #s.dependency "Donky-CommonMessaging-Logic"
  
end
