Pod::Spec.new do |s|
  s.name             = "Donky-Assets"
  s.version          = "4.8.6.0"
  s.summary          = "The base code of interacting with assets on the Donky network"
  s.description      = <<-DESC
                      Used when uploading and downloading assets.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", :tag => 'v4.8.5.0' }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Assets/**/*.{h,m}'
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-Core-SDK"
   
end
