//
//  DNAssetController.h
//  Core Container
//
//  Created by Chris Watson on 23/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DNAssetController : NSObject

/*!
 Method to retrieve avatars from the Donky Network. This is performed synchronously and on the main thread.
 
 @param avatarAssetID the asset id for the avatar that should be donwloaded.
 
 @return the avatar asset as a UIImage, will return nil if not found.
 
 @since 2.0.0.0
 */
+ (UIImage *)avatarAssetForID:(NSString *)avatarAssetID;

@end
