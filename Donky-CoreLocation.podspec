Pod::Spec.new do |s|
  s.name             = "Donky-CoreLocation"
  s.version          = "4.9.0.1"

  s.summary          = "The location services module"
  s.description      = <<-DESC
                       This module allows you to access the location services with the Donky Network.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.9.0.1'  }


  s.social_media_url = 'https://twitter.com/mobiledonky'
  
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  
  s.source_files = 'src/modules/Location Services/**/*.{h,m}'

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-Core-SDK"
  
end
