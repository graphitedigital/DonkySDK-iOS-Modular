Pod::Spec.new do |s|
  s.name             = "Donky-Core-Sequencing"
  s.version          = "4.8.6.3"

  s.summary          = "The core sequencing module"
  s.description      = <<-DESC
                       This module allows you to perform multiple calls to some account controller methods without needing to implement call backs or worry about sequencing when
                       changing local and netowrk state.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.8.6.3' }


  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Sequencing/**/*.{h,m}'
  
  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency "Donky-Core-SDK"
  
end
