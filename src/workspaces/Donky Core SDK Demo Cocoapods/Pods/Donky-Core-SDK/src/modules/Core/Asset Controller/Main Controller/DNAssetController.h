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

/*!
 Method to same an image to a temporary directory inside the application documents folder. 
 Use this if you wish to temporatily store some images.
 
 @param image     the image to be saved.
 @param imageName the name of the image.
 
 @return BOOL indicating if it was successfull
 
 @since 2.2.2.7
 */
+ (BOOL)saveImageToTempDir:(UIImage *)image withImageName:(NSString *)imageName;

/*!
 Method to retrieve a temporary image from the documents directory.
 
 @param imageName the name of the image.
 
 @return the image, nil if image could not be found.
 
 @since 2.2.2.7
 */
+ (UIImage *)imageFromTempDir:(NSString *)imageName;

/*!
 Method to delete an image from the temporary document folder.
 
 @param imageName the name of the image to delete.
 
 @since 2.2.2.7
 */
+ (void)deleteImageAtTempDir:(NSString *)imageName;

@end
