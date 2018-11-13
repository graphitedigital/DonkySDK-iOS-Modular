Pod::Spec.new do |s|
  s.name             = "Donky-Core-SDK"
  s.version          = "4.8.6.3"

  s.summary          = "The core component to the Donky SDK."
  s.description      = <<-DESC
                       This is required by all other modules (is automatically imported through dependecny management) 
                       it can also be used in complete isolation. If all you require is to send content to other 
                       devices then this is all that is required.
                       DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           =  { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", 
                          :tag => "v4.8.6.3"}


  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Core/**/*.{h,m}', 'src/modules/Core\ Analytics/**/*.{h,m}'
  
  s.resources = ["src/modules/Core/App\ Settings\ Controller/Resources/DNConfiguration.plist", "src/modules/Core/Data\ Controller/Resources/DNDonkyDataModel.xcdatamodeld", "src/modules/Core/Universal\ Helpers/Localization/DNLocalization.strings"]

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AFNetworking', '~> 2.3'
  
end
