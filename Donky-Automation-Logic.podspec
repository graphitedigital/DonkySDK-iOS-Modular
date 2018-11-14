Pod::Spec.new do |s|
  s.name             = "Donky-Automation-Logic"
  s.version          = "4.9.0.1"

  s.summary          = "The Automation logic"
  s.description      = <<-DESC
                       Use this module to trigger autoatmed events within the Donky Network from your client applications.
					   DESC
  s.homepage         = "https://github.com/Donky-Network/DonkySDK-iOS-Modular"
  s.license          = 'MIT'
  s.author           = { "Donky Networks Ltd" => "sdk@mobiledonky.com" }
  s.source           = { :git => "https://github.com/Donky-Network/DonkySDK-iOS-Modular.git", 
                         :branch => 'swift/4.9.0.0' }
  s.social_media_url = 'https://twitter.com/mobiledonky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'src/modules/Automation/**/*.{h,m}'
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency "Donky-Core-SDK"
  
end
