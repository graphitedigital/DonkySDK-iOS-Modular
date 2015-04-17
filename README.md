# DonkySDK-Modular-iOS

The Modular Donky SDK. Inside this repository are the following Donky Network SDK elements:

<ul>
<li>Donky Core SDK (Requried for all implementations of the Donky SDK. If using Cocoapods, each module pod spec has a dependency on Core.)</li>
</ul>


#Modules

<ul>
<li>Simple Push Module (Logic + UI)</li>
<li>Rich Messaging (Logic + Pop-UP)</li>
<li>Core Analytics</li>
<li>Automation</li>
</ul>

# Donky-Core-SDK

[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-Core-SDK.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-Core-SDK)
[![Version](https://img.shields.io/cocoapods/v/Donky-Core-SDK.svg?style=flat)](http://cocoapods.org/pods/Donky-Core-SDK)
[![License](https://img.shields.io/cocoapods/l/Donky-Core-SDK.svg?style=flat)](http://cocoapods.org/pods/Donky-Core-SDK)
[![Platform](https://img.shields.io/cocoapods/p/Donky-Core-SDK.svg?style=flat)](http://cocoapods.org/pods/Donky-Core-SDK)

## Usage

Only add this to your Pod File if this is the only part of the SDk you are going to use. Adding this to your podfile is not necessary if using any of the modules. 

## Requirements

<ul>
<li>iOS 7.1+</li>
<li>Arc must be enabled.</li>
<li>Core Analytics</li>
<li>Any third party dependencies will be imported automatically when using cocoapods, otherwise see below:</li>
<ul>
	<li>[AFNetworking](https://github.com/AFNetworking/AFNetworking)</li>
</ul>
</ul>







## Installation

Donky-Core-SDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Donky-Core-SDK"
```

## Author

Donky Networks Ltd, sdk@mobiledonky.com

## License

Donky-Core-SDK is available under the MIT license. See the LICENSE file for more info.



# Donky-SinplePush-SDK