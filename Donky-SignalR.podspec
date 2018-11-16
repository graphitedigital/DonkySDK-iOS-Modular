Pod::Spec.new do |s|
  s.name             = "Donky-SignalR"
  s.version          = "4.9.0.1"
  s.summary          = "The SignalR wrapper for the Donky SDK"
  s.description      = <<-DESC
                       The SignalR wrapper for the Donky SDK.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :branch => 'swift/4.9.0.0'  }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/SignalR/**/*.{h,m}'
 
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'SignalR-ObjC'
  s.dependency "Donky-Core-SDK"
  
end
