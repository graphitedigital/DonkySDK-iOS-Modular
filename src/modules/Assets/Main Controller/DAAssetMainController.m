//
//  DAAssetMainController.m
//  AssetsLogic
//
//  Created by Chris Watson on 10/11/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DAAssetMainController.h"
#import "DNNetworkController.h"
#import "DNConstants.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNConfigurationController.h"
#import "DNLoggingController.h"
#import "DNFileHelpers.h"
#import "DNSystemHelpers.h"
#import "DAAsset.h"

static NSString *const DAAssetMessageAsset = @"MessageAsset";
static NSString *const DAType = @"type";
static NSString *const DAData = @"data";
static NSString *const DAMimeType = @"mimeType";
static NSString *const DAClientReference = @"clientReference";
static NSString *const DNAssetURLFormat = @"AssetDownloadUrlFormat";
static NSString *const DATempDir = @"DonkyAssets";
static NSString *const DAAssetID = @"assetId";
static NSString *const DAAccountAvatar = @"AccountAvatar";
static NSString *const DAFileSize = @"sizeInBytes";
static NSString *const DAName = @"name";

@implementation DAAssetMainController

+ (void)uploadAssetData:(NSData *)assetData assetName:(NSString *)name mimeType:(NSString *)mimeType success:(DAAssetUploadSuccessBlock)successBlock failure:(DAAssetUploadFailureBlock)failureBlock {

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary *uploadDict = [[NSMutableDictionary alloc] init];

    [uploadDict dnSetObject:name ? : [NSString stringWithFormat:@"%@.%@", [DNSystemHelpers generateGUID], [[mimeType componentsSeparatedByString:@"/"] lastObject]] forKey:DAClientReference];
    [uploadDict dnSetObject:mimeType forKey:DAMimeType];
    [uploadDict dnSetObject:assetData forKey:DAData];
    [uploadDict dnSetObject:DAAssetMessageAsset forKey:DAType];

    [uploadDict dnSetObject:@([DNFileHelpers sizeOfData:assetData]) forKey:DAFileSize];

    [[DNNetworkController sharedInstance] streamAssetUpload:@[uploadDict] success:^(NSURLSessionDataTask *task, id responseData) {
        NSString *assetID = responseData[DAAssetID];
        if (successBlock) {
            DAAsset *asset = [[DAAsset alloc] init];
            [asset setMimeType:mimeType];
            [asset setName:name];
            [asset setAssetId:assetID];
            [asset setSizeInBytes:[DNFileHelpers sizeOfData:assetData]];
            successBlock(asset);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}


+ (void)uploadMultipleFilePathAssets:(NSArray *)assets success:(DAAssetUploadSuccessBlock)successBlock failure:(DAAssetUploadFailureBlock)failureBlock {

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    __block NSMutableArray *assetsToUpload = [[NSMutableArray alloc] init];

    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        NSString *filePath = obj;

        NSMutableDictionary *uploadDict = [[NSMutableDictionary alloc] init];
        [uploadDict dnSetObject:[DAAssetMainController mimeTypeForFileAtPath:filePath] forKey:DAMimeType];

        NSData *assetData = [NSData dataWithContentsOfFile:filePath];
        [uploadDict dnSetObject:assetData forKey:DAData];
        [uploadDict dnSetObject:[[filePath pathComponents] lastObject] forKey:DAName];

        [uploadDict dnSetObject:DAAssetMessageAsset forKey:DAType];

        [uploadDict dnSetObject:@([DNFileHelpers sizeOfData:assetData]) forKey:DAFileSize];

        [assetsToUpload addObject:uploadDict];

    }];
    
    __block NSMutableArray *assetsUploaded = [[NSMutableArray alloc] init];
    
    [assetsToUpload enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *assetToUpload = obj;

        [[DNNetworkController sharedInstance] streamAssetUpload:assetsToUpload success:^(NSURLSessionDataTask *task, id responseData) {
            NSString *assetID = responseData[DAAssetID];
            if (successBlock) {
                DAAsset *asset = [[DAAsset alloc] init];
                [asset setMimeType:assetToUpload[DAMimeType]];
                [asset setName:assetToUpload[DAName]];
                [asset setAssetId:assetID];
                [asset setSizeInBytes:[assetToUpload[DAFileSize] floatValue]];

                [assetsUploaded addObject:asset];

                if ([assetsUploaded count] == [assets count]) {
                    if (successBlock) {
                        successBlock(assetsUploaded);
                    }
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
            }
        }                                               failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }];
}

+ (void)uploadAvatarImage:(UIImage *)avatarImage success:(DAAssetUploadSuccessBlock)successBlock failure:(DAAssetUploadFailureBlock)failureBlock {

    NSData *assetData = UIImagePNGRepresentation(avatarImage);

    NSMutableDictionary *uploadDict = [[NSMutableDictionary alloc] init];

    NSString *assetToUpload = [NSString stringWithFormat:@"%@.png", [DNSystemHelpers generateGUID]];

    [uploadDict dnSetObject:assetToUpload forKey:DAClientReference];
    [uploadDict dnSetObject:@"image/png" forKey:DAMimeType];
    [uploadDict dnSetObject:assetData forKey:DAData];

    [uploadDict dnSetObject:DAAccountAvatar forKey:DAType];

    [[DNNetworkController sharedInstance] streamAssetUpload:@[uploadDict] success:^(NSURLSessionDataTask *task, id responseData) {
        NSString *assetID = responseData[DAAssetID];
        if (successBlock) {
            DAAsset *asset = [[DAAsset alloc] init];
            [asset setMimeType:@"image/png"];
            [asset setName:assetToUpload];
            [asset setAssetId:assetID];
            [asset setSizeInBytes:[DNFileHelpers sizeOfData:assetData]];
            successBlock(asset);
        }
    }                                               failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (NSString *)assetWithID:(NSString *)assetID fileName:(NSString *)name {
    if (!assetID || ![assetID length]) {
        return nil;
    }

    NSString *assetDownloadUrl = [DAAssetMainController downloadURLForAsset:assetID];

    if (!assetDownloadUrl) {
        return nil;
    }

    NSURL *url = [[NSURL alloc] initWithString:assetDownloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];

    NSString *filePath = nil;
    if (!data) {
        DNErrorLog(@"Couldn't download asset: %@", assetDownloadUrl);
    }
    else {
        [DNFileHelpers ensureDirectoryExistsAtPath:[[DNFileHelpers pathForDocumentDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@", DATempDir]]];
        filePath = [[DNFileHelpers pathForDocumentDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@/%@", DATempDir, name]];
        [DNFileHelpers saveData:data toPath:filePath];
    }

    return filePath;
}

+ (NSData *)assetDataWithID:(NSString *)assetID {

    if (!assetID || ![assetID length]) {
        return nil;
    }

    NSString *assetDownloadUrl = [DAAssetMainController downloadURLForAsset:assetID];

    if (!assetDownloadUrl) {
        return nil;
    }

    NSURL *url = [[NSURL alloc] initWithString:assetDownloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];

    return data;
}

+ (NSString *)mimeTypeForFileAtPath:(NSString *)filePath {

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filePath pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);

    if (!mimeType) {
        return @"application/octet-stream";
    }

    return (__bridge NSString *)mimeType;
}

+ (NSString *)downloadURLForAsset:(NSString *)assetID {

    NSString *assetDownloadUrl =  [DNConfigurationController configuration][DNAssetURLFormat];

    assetDownloadUrl = [assetDownloadUrl stringByReplacingOccurrencesOfString:@"{0}" withString:assetID];

    assetDownloadUrl = [assetDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return assetDownloadUrl;
}

+ (UIImage *)avatarWithID:(NSString *)avatarID {
    if (!avatarID || ![avatarID length]) {
        return nil;
    }

    NSString *assetDownloadUrl = [DNConfigurationController configuration][DNAssetURLFormat];

    assetDownloadUrl = [assetDownloadUrl stringByReplacingOccurrencesOfString:@"{0}" withString:avatarID];

    assetDownloadUrl = [assetDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (!assetDownloadUrl) {
        return nil;
    }

    NSURL *url = [[NSURL alloc] initWithString:assetDownloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];

    if (!data) {
        DNErrorLog(@"Couldn't download asset: %@", assetDownloadUrl);
    }

    return [UIImage imageWithData:data];
}

+ (void)deleteAvatarWithID:(NSString *)avatarID {
    NSString *filePath = [DNFileHelpers pathForFile:avatarID inDirectory:kDNTempDirectory];
    [DNFileHelpers removeFileIfExistsAtPath:filePath];
}

@end