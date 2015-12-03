//
//  DNFileHelpers.m
//  Logging
//
//  Created by Donky Networks on 12/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNFileHelpers.h"
#import "DNLoggingController.h"

@implementation DNFileHelpers

#pragma mark -
#pragma mark - Pre-Built Retrievers

+(NSString *)pathForDocumentDirectory {
    return (NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0];
}

+ (NSURL *)urlPathForDocumentDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSString *)pathForDirectory:(NSString *) directory {
    NSString *path = [DNFileHelpers pathForDocumentDirectory];
    path = [path stringByAppendingPathComponent:directory];
    [DNFileHelpers ensureDirectoryExistsAtPath:path];
    return path;
}

+(NSString *)pathForFile:(NSString *)fileName inDirectory:(NSString *) directory {

    NSString *path = [DNFileHelpers pathForDocumentDirectory];
    path = [path stringByAppendingPathComponent:directory];
    [DNFileHelpers ensureDirectoryExistsAtPath:path];
    path = [path stringByAppendingPathComponent:fileName];
    [DNFileHelpers ensureFileExistsAtPath:path];

    return path;
}

+ (NSBundle *)bundleWithName:(NSString *)bundleName {
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"];
    return [[NSBundle alloc] initWithURL:bundleURL];
}

+ (NSURL *)audioFileURLForName:(NSString *)fileName extension:(NSString *)fileExtension inDirectory:(NSString *)directory {

    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension inDirectory:directory];

    if (!resourcePath) {
        DNErrorLog(@"cannot find the resource requested %@ with extension %@ in directory %@", fileName, fileExtension, directory);
        return nil;
    }

    return [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension inDirectory:directory]];
}

#pragma mark -
#pragma mark - Deletion

+(void)removeFileIfExistsAtPath:(NSString *)path {
    //Check the file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        NSError *error;
        //Remove the file
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
            DNErrorLog(@"Failed to remove file at path: %@ due to error - %@", path, error);
    }
}

#pragma mark -
#pragma mark - Checking and Creating

+(BOOL)fileExists:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(void)ensureDirectoryExistsAtPath:(NSString *)path {
    //Check the path doesn't already exist
    if (![DNFileHelpers fileExists:path])
    {
        NSError *err = nil;
        //Create the directory
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&err])
            DNErrorLog(@"Can't create directory: %@", [err localizedDescription]);
    }
}

+ (void)ensureFileExistsAtPath:(NSString *)path {

    if (!path) {
        return;
    }

    if (![DNFileHelpers fileExists:path]) {
        NSError *err = nil;
        //Create the directory
        if (![[NSFileManager defaultManager] createFileAtPath:path
                                                     contents:nil
                                                   attributes:nil])
            DNErrorLog(@"Can't create file: %@", [err localizedDescription]);
    }
}

+ (void)saveData:(NSData *) fileData toPath:(NSString *) filePath {
    if (![fileData writeToFile:filePath atomically:YES]) {
        DNErrorLog(@"Can't save data to path %@...", filePath);
    }
}

+ (BOOL)copyItemAtPath:(NSString *)path1 toPath:(NSString *)path2 {
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:path1 toPath:path2 error:&error]) {
        DNErrorLog(@"Can't copy file: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

+ (CGFloat)sizeForFile:(NSString *)path {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize] floatValue];
}

+ (CGFloat)sizeOfData:(NSData *)data {

    NSString *dataString = [data base64EncodedStringWithOptions:0];

    return [dataString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

@end
