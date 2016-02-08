//
//  DAAsset.h
//  AssetsLogic
//
//  Created by Chris Watson on 23/11/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 The object that is returned from all of the asset upload methods. Also use this object when sending attachments in 
 chat messages.
 
 @since 2.6.6.5
 */
@interface DAAsset : NSObject

/*!
 The ID of the asset, this is used to retrieve the original image from the network.
 
 @since 2.6.6.5
 */
@property (nonatomic, copy) NSString *assetId;

/*!
 The mime type of the asset, this is used when saving the asset to local storage and must
 also be set when sending assets.
 
 @since 2.6.6.5
 */
@property (nonatomic, copy) NSString *mimeType;

/*!
 The human-readable name for the asset, this is primarly used to in the UI.
 
 @since 2.6.6.5
 */
@property (nonatomic, copy) NSString *name;

/*!
 The size of the asset in bytes, this is calculated but inspecting the byte data.
 
 @since 2.6.6.5
 */
@property (nonatomic) CGFloat sizeInBytes;

@end