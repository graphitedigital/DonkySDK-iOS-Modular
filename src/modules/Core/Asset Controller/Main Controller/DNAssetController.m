//
//  DNAssetController.m
//  Core Container
//
//  Created by Chris Watson on 23/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNAssetController.h"
#import "DNConfigurationController.h"
#import "DNLoggingController.h"

static NSString *const DNAssetURLFormat = @"AssetDownloadUrlFormat";

@implementation DNAssetController

+ (UIImage *) avatarAssetForID:(NSString *)avatarAssetID {

    if (!avatarAssetID)
        return nil;
    
    NSString *assetDownloadUrl = [DNConfigurationController configuration][DNAssetURLFormat];

    assetDownloadUrl = [assetDownloadUrl stringByReplacingOccurrencesOfString:@"{0}" withString:avatarAssetID];

    assetDownloadUrl = [assetDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [[NSURL alloc] initWithString:assetDownloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];

    if (!data)
        DNErrorLog(@"Couldn't download asset: %@", assetDownloadUrl);

    return [UIImage imageWithData:data];
}

@end
