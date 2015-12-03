<p align="center" >
  <img src="https://avatars2.githubusercontent.com/u/11334935?v=3&s=200" alt="Donky Networks LTD" title="Donky Network SDK">
</p>

# Donky Modular SDK (V2.6.5.6)

The modular SDK exposes all of the network functionality in a way that means developers can consume only the pieces they need in order to:

<ul>
<li>Send custom notifications</li>
<li>Use Donky's messaging features</li>
<li>Automate actions and messaging</li>
<li>Track in app analytics</li>
<li>Build complex M2M, A2P and P2P applications</li>
</ul>

Using Donky as a data network allows developers to focus on writing the apps code rather than having to worry about building a reliable and secure network. The complexities of transferring data across the internet are taken care of, allowing developers to just build their applications.

##Requirements

The minimal technical requirements for the Donky Module SDK are:

<ul>
<li>Xcode 5.0+</li>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


Read our complete documentation [here](http://docs.mobiledonky.com)

## Author

Donky Networks Ltd, sdk@mobiledonky.com

## License

DonkySDK-iOS-Modular is available under the MIT license. See the LICENSE file for more info.


##Installation

To install please use one of the following methods:

Cloning the Git Repo:

	git clone git@github.com:Donky-Network/DonkySDK-iOS-Modular.git 
	
Using [CocoaPods](https://cocoapods.org)

	Please see below for all the information specific to the CocoaPods
	
##Support

Please contact sdk@mobiledonky.com if you have any issues with integrating or using this SDK.

##Contribute

We accept pull requests!


##CocoaPods


# Donky-Core-SDK

[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-Core-SDK.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-Core-SDK)
[![Version](https://img.shields.io/cocoapods/v/Donky-Core-SDK.svg?style=flat)](http://cocoapods.org/pods/Donky-Core-SDK)
[![License](https://img.shields.io/cocoapods/l/Donky-Core-SDK.svg?style=flat)](http://cocoapods.org/pods/Donky-Core-SDK)
[![Platform](https://img.shields.io/cocoapods/p/Donky-Core-SDK.svg?style=flat)](http://cocoapods.org/pods/Donky-Core-SDK)

## Usage

Only add this to your 'PodFile' if this is the only part of the SDK you are going to use. Adding this to your ‘Podfile’ is not necessary if using any of the additional optional modules. 

## Initialise anonymously

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	//Start analytics (optional)
    [[DCAAnalyticsController sharedInstance] start];

    //Initialise Donky with API key.
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY"];
	return YES;
}
```

## Initialise with a known user
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	//Start analytics (optional)
    [[DCAAnalyticsController sharedInstance] start];

    //Create a new user and populate with details. Country code is optional is NO mobile number is provided. If a 
    //mobile number is provided then a country code is mandatory. Failing to provide a country code that matches the
    //mobile number will result in a server validation error. 
    DNUserDetails *userDetails = [[DNUserDetails alloc] initWithUserID:@"" 
                                                           displayName:@""
                                                          emailAddress:@"" 
                                                          mobileNumber:@"" 
                                                           countryCode:@"" 
                                                             firstName:@"" 
                                                              lastName:@"" 
                                                              avatarID:@"" 
                                                          selectedTags:@[] 
                                                  additionalProperties:@{}];
    
    //Initialise Donky with API key.
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY" userDetails:userDetails success:^(NSURLSessionDataTask *task, id responseData) {
        NSLog(@"Successfully Initialised with user...");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
	return YES
}
````
You must also invoke the following of your applications delegate to ensure that custom content notifications are received and processed promptly:

To ensure that your device token is sent to the Donky Network:
```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}
```

To handle incoming notifications, using this method allows your application to process content enabled notifications:
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}
```

To handle interactive notifications (iOS 8+ only)
```objective-c
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}
```

##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Core SDK Demo
```
	
## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


#Third Party Dependencies

[AFNetworking](https://github.com/AFNetworking/AFNetworking)

## Installation

Donky-Core-SDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Donky-Core-SDK"
```


# Donky-SimplePush-Logic

[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-SimplePush-Logic.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-SimplePush-Logic)
[![Version](https://img.shields.io/cocoapods/v/Donky-SimplePush-Logic.svg?style=flat)](http://cocoapods.org/pods/Donky-SimplePush-Logic)
[![License](https://img.shields.io/cocoapods/l/Donky-SimplePush-Logic.svg?style=flat)](http://cocoapods.org/pods/Donky-SimplePush-Logic)
[![Platform](https://img.shields.io/cocoapods/p/Donky-SimplePush-Logic.svg?style=flat)](http://cocoapods.org/pods/Donky-SimplePush-Logic)

## Usage

Use the Simple Push module to enable your application to receive Simple Push messages.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //Start analytics (optional)
    [[DCAAnalyticsController sharedInstance] start];

    //Start push logic:
    [[DPPushNotificationController sharedInstance] start];
    
    //Initialise Donky
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY"];
	
	return YES;
}
```

You must also invoke the following of your applications delegate:

To ensure that your device token is sent to the Donky Network:
```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}
```

To handle incoming notifications, using this method allows your application to process content enabled notifications:
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}
```

To handle interactive notifications (iOS 8+ only)
```objective-c
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}
```

##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Simple Push Logic Demo
```
	
	
## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
<li>For Interactive notifications iOS 8.0+ is required.</li>
</ul>


## Installation


```ruby
pod "Donky-SimplePush-Logic"
```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
<li>Donky Common Messaging Logic</li>
</ul>


# Donky-SimplePush-UI


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-SimplePush-UI.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-SimplePush-UI)
[![Version](https://img.shields.io/cocoapods/v/Donky-SimplePush-UI.svg?style=flat)](http://cocoapods.org/pods/Donky-SimplePush-UI)
[![License](https://img.shields.io/cocoapods/l/Donky-SimplePush-UI.svg?style=flat)](http://cocoapods.org/pods/Donky-SimplePush-UI)
[![Platform](https://img.shields.io/cocoapods/p/Donky-SimplePush-UI.svg?style=flat)](http://cocoapods.org/pods/Donky-SimplePush-UI)

## Usage

The following code samples is the minimum required to start receiving simple push messages from the Donky network as well as utilising our pre-built UI
to display the message(s) to the user while their application is open. It includes a pre-built UI to display button options and reporting against which button a user selectes
for interative notifications. 

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   //Start analytics (optional)
    [[DCAAnalyticsController sharedInstance] start];

    //Start the Push UI controller, there is no need to start the logic controller as well:
    [[DPUINotificationController sharedInstance] start];

    //Initialise Donky
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY"];
	
	return YES;
}
```
You must also invoke the following of your applications delegate:

To ensure that your device token is sent to the Donky Network:
```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}
```

To handle incoming notifications, using this method allows your application to process content enabled notifications:
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}
```

To handle interactive notifications (iOS 8+ only)
```objective-c
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}
```

##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Simple Push UI Demo
```

## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


## Installation


```ruby
pod "Donky-SimplePush-UI"

```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
<li>Donky Simple Push Logic</li>
<li>Donky Common Messaging Logic</li>
<li>Donky Common Messaging UI</li>
</ul>


# Donky-RichMessage-Logic


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-RichMessage-Logic.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-RichMessage-Logic)
[![Version](https://img.shields.io/cocoapods/v/Donky-RichMessage-Logic.svg?style=flat)](http://cocoapods.org/pods/Donky-RichMessage-Logic)
[![License](https://img.shields.io/cocoapods/l/Donky-RichMessage-Logic.svg?style=flat)](http://cocoapods.org/pods/Donky-RichMessage-Logic)
[![Platform](https://img.shields.io/cocoapods/p/Donky-RichMessage-Logic.svg?style=flat)](http://cocoapods.org/pods/Donky-RichMessage-Logic)

## Usage

Use the Rich Message module to enable your application to receive Rich Messages from the netowrk and save them to Donky's local database. You can then retrieve and delete messages 
through the APIs provided in the ```objective-c DRLogicMainController```.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Start analytics controller (optional)
    [[DCAAnalyticsController sharedInstance] start];
    
    //Start the Rich Logic
    [[DRLogicMainController sharedInstance] start];
    
    //Initialise Donky
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-Key"];
    
    return YES;
}
```
You must also invoke the following of your applications delegate:

To ensure that your device token is sent to the Donky Network:
```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}
```

To handle incoming notifications, using this method allows your application to process content enabled notifications:
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}
```

To handle interactive notifications (iOS 8+ only)
```objective-c
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}
```

##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Rich Message Logic Demo
```

## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


## Installation

```ruby
pod "Donky-RichMessage-Logic"

```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
<li>Donky Common Messaging Logic</li>
</ul>

# Donky-RichMessage-PopUp


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-RichMessage-PopUp.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-RichMessage-PopUp)
[![Version](https://img.shields.io/cocoapods/v/Donky-RichMessage-PopUp.svg?style=flat)](https://cocoapods.org/pods/Donky-RichMessage-PopUp)
[![License](https://img.shields.io/cocoapods/l/Donky-RichMessage-PopUp.svg?style=flat)](https://cocoapods.org/pods/Donky-RichMessage-PopUp)
[![Platform](https://img.shields.io/cocoapods/p/Donky-RichMessage-PopUp.svg?style=flat)](https://cocoapods.org/pods/Donky-RichMessage-PopUp)

## Usage

Use the Rich Message module to enable your application to receive rich messages and display them automatically to the user in the form of a pop up.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Start the analytics controller (optional)
    [[DCAAnalyticsController sharedInstance] start];
    
    //Start the Rich Pop Up UI controller:
    [[DRUIPopUpMainController sharedInstance] start];
    
    //Optional Settings:
    //Whether rich messages should be automatically deleted from the database after the user has dismissed the pop up (default = YES):
    [[DRUIPopUpMainController sharedInstance] setAutoDelete:YES];
    
    //The style in which the pop up should be presented for iPads (default = UIModalPresentationFormSheet):
    [[DRUIPopUpMainController sharedInstance] setRichPopUpPresentationStyle:UIModalPresentationFormSheet];

    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY"];
    
    return YES;
}
```
You must also invoke the following of your applications delegate:

To ensure that your device token is sent to the Donky Network:
```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}
```

To handle incoming notifications, using this method allows your application to process content enabled notifications:
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}
```

To handle interactive notifications (iOS 8+ only)
```objective-c
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}
```

##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Rich Message PopUp Demo
```

## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>

## Installation

```ruby
pod "Donky-RichMessage-PopUp"

```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
<li>Donky Rich Message Logic</li>
<li>Donky Common Messaging Logic</li>
<li>Donky Common Messaging UI</li>
</ul>

# Donky-RichMessage-Inbox


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-RichMessage-Inbox.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-RichMessage-Inbox)
[![Version](https://img.shields.io/cocoapods/v/Donky-RichMessage-Inbox.svg?style=flat)](https://cocoapods.org/pods/Donky-RichMessage-Inbox)
[![License](https://img.shields.io/cocoapods/l/Donky-RichMessage-Inbox.svg?style=flat)](https://cocoapods.org/pods/Donky-RichMessage-Inbox)
[![Platform](https://img.shields.io/cocoapods/p/Donky-RichMessage-Inbox.svg?style=flat)](https://cocoapods.org/pods/Donky-RichMessage-Inbox)

## Usage

Use the Rich Message module to enable your application to receive and display rich message in our pre-built UI.


##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Rich Message Inbox Demo
```
## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


## Installation


```ruby
pod "Donky-RichMessage-Inbox"

```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
<li>Donky Rich Message Logic</li>
<li>Donky Common Messaging Logic</li>
<li>Donky Common Messaging UI</li>
</ul>

# Donky-Automation-Logic


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-Automation-Logic.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-Automation-Logic)
[![Version](https://img.shields.io/cocoapods/v/Donky-Automation-Logic.svg?style=flat)](https://cocoapods.org/pods/Donky-Automation-Logic)
[![License](https://img.shields.io/cocoapods/l/Donky-Automation-Logic.svg?style=flat)](https://cocoapods.org/pods/Donky-Automation-Logic)
[![Platform](https://img.shields.io/cocoapods/p/Donky-Automation-Logic.svg?style=flat)](https://cocoapods.org/pods/Donky-Automation-Logic)

## Usage

Use the Automation module to enable to trigger campaigns setup on Campaign Builder/Donky Control   [here](http://docs.mobiledonky.com).

Start the Donky SDK and analytics controller as normal. 

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //Start analytics module (optional)
    [[DCAAnalyticsController sharedInstance] start];

    //Initialise Donky
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY"];

    return YES;
}
```

To fire a trigger use either of the following methods:

```objective-c
[DAAutomationController executeThirdPartyTriggerWithKey:@"Trigger-Key" customData:@{}];
```

```objective-c
[DAAutomationController executeThirdPartyTriggerWithKeyImmediately:@"Trigger-Key" customData:@{}];
```

##Samples

The sample project can be found:

```
│
├───src
	├───workspaces
		├───Donky Automation Demo
```

## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


## Installation


```ruby
pod "Donky-Automation-Logic"

```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
</ul>

# Donky-CommonMessaging-Audio


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-CommonMessaging-Audio.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-CommonMessaging-Audio)
[![Version](https://img.shields.io/cocoapods/v/Donky-CommonMessaging-Audio.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-Audio)
[![License](https://img.shields.io/cocoapods/l/Donky-CommonMessaging-Audio.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-Audio)
[![Platform](https://img.shields.io/cocoapods/p/Donky-CommonMessaging-Audio.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-Audio)

## Usage

Use of this module allows you to save audio files against various message types and allow them to be play automatically when that type of message is recevied.  [here](http://docs.mobiledonky.com).

Start the controller:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
	[[DAMainController sharedInstance] start];
    
	//Other donky modules or custom code:

    return YES;
}
```
To set a sound file, this method accepts an NSURL to the file.
```objective-c
[[DAMainController sharedInstance] setAudioFile:<#(NSURL *)#> forMessageType:<#(DonkyAudioMessageTypes)#>];
```

To play a sound file:
```objective-c
[[DAMainController sharedInstance] playAudioFileForMessage:<#(DonkyAudioMessageTypes)#>];
```
##Samples

```
│
├───src
	├───workspaces
		├───Donky Audio
```

## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


## Installation


```ruby
pod "Donky-CommonMessaging-Audio"

```

## Pod Dependencies

None

# Donky-Core-Sequencing


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-Core-Sequencing.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/Donky-Core-Sequencing)
[![Version](https://img.shields.io/cocoapods/v/Donky-Core-Sequencing.svg?style=flat)](https://cocoapods.org/pods/Donky-Core-Sequencing)
[![License](https://img.shields.io/cocoapods/l/Donky-Core-Sequencing.svg?style=flat)](https://cocoapods.org/pods/Donky-Core-Sequencing)
[![Platform](https://img.shields.io/cocoapods/p/Donky-Core-Sequencing.svg?style=flat)](https://cocoapods.org/pods/Donky-Core-Sequencing)

## Usage

Use of this module allows you to perform multiple calls to some account controller methods without needing to implement call backs or worry about sequencing when changing local and network state.

This module overides the following methods inside
 ```objective-c
DNSequencingAccountController
```

```objective-c
+ (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;
```

```objective-c
+ (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;
```

```objective-c
+ (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;
```

```objective-c
+ (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;
```

```objective-c
+ (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;
```
##Samples


## Requirements

<ul>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>


## Installation


```ruby
pod "Donky-Core-Sequencing"

```

## Pod Dependencies

Including this in your podfile will automatically pull in the following other modules, as they are hard dependent. There is no need to manually incldue any of the below manually:

<ul>
<li>Donky Core SDK</li>
</ul>

# Donky-CommonMessaging-Logic

[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-CommonMessaging-Logic.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/CommonMessaging-Logic)
[![Version](https://img.shields.io/cocoapods/v/Donky-CommonMessaging-Logic.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-Logic)
[![License](https://img.shields.io/cocoapods/l/Donky-CommonMessaging-Logic.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-Logic)
[![Platform](https://img.shields.io/cocoapods/p/Donky-CommonMessaging-Logic.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-Logic)

## Usage

You will never need to manually add the common logic module into your application, it is a PodSpec dependency and therefore isn't required to be manually added to your 
PodFile.

# Donky-CommonMessaging-UI


[![CI Status](http://img.shields.io/travis/Dynmark LtD/Donky-CommonMessaging-UI.svg?style=flat)](https://travis-ci.org/Donky Networks Ltd/CommonMessaging-UI)
[![Version](https://img.shields.io/cocoapods/v/Donky-CommonMessaging-UI.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-UI)
[![License](https://img.shields.io/cocoapods/l/Donky-CommonMessaging-UI.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-UI)
[![Platform](https://img.shields.io/cocoapods/p/Donky-CommonMessaging-UI.svg?style=flat)](https://cocoapods.org/pods/Donky-CommonMessaging-UI)

## Usage

You will never need to manually add the common UI module into your application, it is a PodSpec dependency and therefore isn't required to be manually added to your 
PodFile.

