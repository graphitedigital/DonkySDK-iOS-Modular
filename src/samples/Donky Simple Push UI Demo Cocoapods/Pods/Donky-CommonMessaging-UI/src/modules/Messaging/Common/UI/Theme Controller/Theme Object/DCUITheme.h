//
//  DCUITheme.h
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DCUITheme : NSObject

/*!
 The name of the theme. Used when retrieving the theme from the controller.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *themeName;

/*!
 Dictionary of colours for the theme.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) NSMutableDictionary *themeColours;

/*!
 Dictionary of the fonts for the theme.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) NSMutableDictionary *themeFonts;

/*!
 Dictioanry of images for the theme. NOTE: you should add the images file name NOT 
 UIIMages. e.g. "donky_example.png"
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) NSMutableDictionary *themeImages;

/*!
 Initialiser to create a new theme with a supplied name.
 
 @param themeName the name for this theme.
 
 @return a new instance of DCUITheme.
 
 @since 2.2.2.7
 */
- (instancetype)initWithThemeName:(NSString *)themeName;

/*!
 Helper method to retrieve the saved colour in this theme based on it's key.
 
 @param key the key for the colour as it was saved in the themeColours.
 
 @return a new UIColor object.
 
 @since 2.2.2.7
 */
- (UIColor *)colourForKey:(NSString *)key;

/*!
 Helper method to retrieve the saved font in this theme based on it's key.
 
 @param key the key for the font as it was saved in the themeFonts.
 
 @return a new UIFont object
 
 @since 2.2.2.7
 */
- (UIFont *)fontForKey:(NSString *)key;

/*!
 Helper method to retrieve the saved image name in this theme based on it's key.
 
 @param key the key for the image name as it was saved in the themeImages.
 
 @return a NSString of the file name.
 
 @since 2.2.2.7
 */
- (UIImage *)imageForKey:(NSString *)key;

@end
