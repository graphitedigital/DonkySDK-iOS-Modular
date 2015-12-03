//
//  DNFileHelpers.h
//  Logging
//
//  Created by Donky Networks on 12/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 DNFileHelpers is a complete suite of helper methods to: write to, retrieve from & delete in the applications document directory.
    It is important to note that in iOS 8 the documents directory path changes between app life cycles. For this reason it is un-wise to store
    file paths into persistent memory. If this is unavoidable, ensure that the path is updated to reflect the new container location. 
 
 @since 2.0.0.0
 */
@interface DNFileHelpers : NSObject

/*!
 Returns the documents directory path as provided by iOS.
 
 @return the path to the apps documents directory as a string.
 
 @since 2.0.0.0
 */
+ (NSString *)pathForDocumentDirectory;

/*!
 Returns the documents directory in the form of a URL.
 
 @return URL object pointing to applications document directory.
 
 @since 2.4.3.1
 */
+ (NSURL *)urlPathForDocumentDirectory;

/*!
 Returns the full file path to a directory within the apps documents directory.
 
 @param directory    the name of the directory. Without the '/'. If the directory does not exist then the directory will be
 created. This will trigger output via the console.
 
 @return the path to the directory in the local documents storage.
 
 @since 2.0.0.0
 */
+ (NSString *)pathForDirectory:(NSString *)directory;

/*!
 Returns the path for the specified file.
 
 @param fileName  the name and extension of the file that should be retrieved. There is no need to supply a '/'
 @param directory the name of the directory which contains the file.
 
 @return the path to specified file. If the file does not exist then one will be created.
 
 @since 2.0.0.0
 */
+ (NSString *)pathForFile:(NSString *)fileName inDirectory:(NSString *)directory;

/*!
 Method to retrieve a bundle from the applications document directory with the specified name.
 
 @param bundleName the name of the bundle required.
 
 @return a new bundle object, nil if no bundle is found.
 
 @since 2.4.3.1
 */
+ (NSBundle *)bundleWithName:(NSString *)bundleName;

/*!
 Helper method to return a file URL for the specified file name.
 
 @param fileName      the file name for which a file URL should be geenrated.
 @param fileExtension the extension of the file name.
 @param directory     the directory in which the file is
 
 @return NSURL relating to the files path.
 
 @since 2.6.5.4
 */
+ (NSURL *)audioFileURLForName:(NSString *)fileName extension:(NSString *)fileExtension inDirectory:(NSString *)directory;

/*!
 Helper method to save data to a file path.
 
 @param fileData the data that should be saved.
 @param filePath the file path to where the new file should be saved

 @since 2.0.0.0
 */
+ (void)saveData:(NSData *)fileData toPath:(NSString *)filePath;

/*!
 Delete the file/directory at the specified path.
 
 @param path the path to the file or directory that should be deleted. If the file/directory does not
 exist then this will simply be ignored.
 
 @since 2.0.0.0
 */
+ (void)removeFileIfExistsAtPath:(NSString *)path;

/*!
 Returns whether a file/directory exists at the specified path.
 
 @param path the path at which the file/directory is located.
 
 @return BOOL value indicating the file/directories existence.
 
 @since 2.0.0.0
 */
+ (BOOL)fileExists:(NSString *)path;

/*!
 Checks whether a directory exists, utilising the 'fileExists:' method. However, if the directory does
 not exist this method will create it.
 
 @param path the path at which the directory is located.
 
 @since 2.0.0.0
 */
+ (void)ensureDirectoryExistsAtPath:(NSString *)path;

/*!
 Checks whether a file exists, utilising the 'fileExists:' method. However, if the file does
 not exist this method will create it.
 
 @param path the path at which the file is located.

 @since 2.0.0.0
 */
+ (void)ensureFileExistsAtPath:(NSString *)path;

/*!
 A helper method to copy a file from one location to another.
 
 @param path1 the existing path of the file.
 @param path2 the path to where the file should be moved.
 
 @return BOOL indicating whether the copying operation was successful.
 
 @since 2.0.0.0
 */
+ (BOOL)copyItemAtPath:(NSString *)path1 toPath:(NSString *)path2;

/*!
 A helper method to get the size of a file for a given path.
 
 @param path the file path
 
 @return the size of the file in bytes.
 
 @since 2.0.0.0
 */
+ (CGFloat)sizeForFile:(NSString *)path;

@end
