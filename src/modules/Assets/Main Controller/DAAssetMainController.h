//
//  DAAssetMainController.h
//  AssetsLogic
//
//  Created by Chris Watson on 10/11/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DNBlockDefinitions.h"

@interface DAAssetMainController : NSObject

/*!
 Method to upload a single piece of asset data to the network. If successful the asset ID is returned
 in the success block. Pass this int he +assetWithID: method to retrieve it, alternatively, send this ID
 to another user for them to retrieve it.
 
 @param assetData the NSData that should be sent
 @param assetName the name of the asset (optional, if none provided a random GUID will be assigned).
 @param mimeType  the mime type of the data, this must match the data otherwise a validation failure is returned
 @param success   block called upon successful upload of the asset.
 @param failure   block called upon failure to upload, the error reason is returned.
 
 @see DAAsset
 
 @since 2.6.6.5
 */
+ (void)uploadAssetData:(NSData *)assetData assetName:(NSString *)name mimeType:(NSString *)mimeType success:(DAAssetUploadSuccessBlock)successBlock failure:(DAAssetUploadFailureBlock)failureBlock;

/*!
 Method to upload multiple assets at once. Unlike the +uploadAssesData: api, this method accepts an array of
 file paths rather than the data. The array should consist of string file paths for the file that should be uploaded.
 The Mime type is inferred from the files extension, if none found, the default application/octet-stream is used.
 
 @param assets  the collection of file paths corresponding to the assets to upload.
 @param success block called upon successful upload of the assets.
 @param failure block called upon the failure of hte asset upload.
 
  @see DAAsset
 
 @since 2.6.6.5
 */
+ (void)uploadMultipleFilePathAssets:(NSArray *)assets success:(DAAssetUploadSuccessBlock)successBlock failure:(DAAssetUploadFailureBlock)failureBlock;

/*!
 Convenience method to upload an avatar image. The result of this will be an DAAsset object, the ID for which should 
 be assigned to the user who's avatar it is.
 
 @param avatarImage  the image, this should be a PNG.
 @param success block called upon successful upload of the assets.
 @param failure block called upon the failure of hte asset upload.
 
 @see DAAsset
 
 @since 2.6.6.5
 */
+ (void)uploadAvatarImage:(UIImage *)avatarImage success:(DAAssetUploadSuccessBlock)successBlock failure:(DAAssetUploadFailureBlock)failureBlock;

/*!
 Method to retrieve the asset from the network given a specific ID. THis will return the file path to
 where the image has been downloaded. This is a temp dir within the SDK. You must manually delete these files when they are no longer needed.
 
 @param assetId the asset that should be downloaded and saved.
 
 @return the NSString file path of the file.
 
 @since 2.6.6.5
 */
+ (NSString *)assetWithID:(NSString *)assetID fileName:(NSString *)name;

/*!
 Method to retrieve the data of an asset, this method does NOT save the asset to local storage.
 
 @param assetId the ID of that asset that should be retrieved.
 
 @return NSData for the asset.
 
 @since 2.6.6.5
 */
+ (NSData *)assetDataWithID:(NSString *)assetID;

/*!
 Method to discover the mime type of a particular file.
 
 @param filePath the path where the file is located.
 
 @return the mime type for that file.
 
 @since 2.6.6.5
 */
+ (NSString *)mimeTypeForFileAtPath:(NSString *)filePath;

/*!
 Method to retrieve the URL to an asset for the provided UI.
 
 @param assetId the assetId for the asset required.
 
 @return an NSString representing the URl to the asset.
 
 @since 2.6.6.5
 */
+ (NSString *)downloadURLForAsset:(NSString *)assetID;

/*!
 Convenience method to retrieve an avatar from the file system given the provided ID.
 
 @param avatarID the ID for the avatar image.
 
 @return the resultant UIImage.
 
 @since 2.6.6.5
 */
+ (UIImage *)avatarWithID:(NSString *)avatarID;

/*!
 Method to delete an avatar image from the file system. NOTE: this will NOT delete
 the original image from the network.
 
 @param avatarID the avatar ID that should be deleted.
 
 @since 2.6.6.5
 */
+ (void)deleteAvatarWithID:(NSString *)avatarID;

@end