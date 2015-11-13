//
//  DCUIMainController.h
//  PushUI
//
//  Created by Donky Networks on 11/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DCUIMainController : NSObject

/*!
 Helper method to get the size of a string.
 
 @param text      the string for which the size is requested.
 @param font      the font that the text is in.
 @param maxHeight the height the string should be constrained by.
 @param maxWidth  the width the string should be constrained by.
 
 @return the size of the string given the supplied parameters.
 
 @since 2.0.0.0
 */
+ (CGSize)sizeForString:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth;

/*!
 Helper method to get the size of an attributed string.
 
 @param text      the string
 @param maxHeight the maximum height allowed.
 @param maxWidth  the maximum width allowed.
 
 @return the size of the string given the supplied max height, width and string content.
 
 @since 2.6.5.4
 */
+ (CGSize)sizeForAttributedString:(NSAttributedString *)text maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth;

/*!
 Helper method to create an attributed string with a chosen selection of characters hihglighted in a different font/colour.
 
 @param text            the text that should be used for the attributed string.
 @param highlighted     the text that should be highlighted.
 @param normalFont      the font for the 'normal' text.
 @param highlightedFont the font to use for the highlighted text.
 @param colour          the colour to use when highlighting.
 
 @return a new NSAttributed string.
 
 @since 2.2.2.7
 */
+ (NSAttributedString *)attributedText:(NSString *)text highLightedValue:(NSString *)highlighted normalFont:(UIFont *)normalFont highlightedFont:(UIFont *)highlightedFont highLightedColour:(UIColor *)colour;

/*!
 Helper method to add a gesture recognizer to a supplied view.
 
 @param view           the view which should have the gesture recognizer.
 @param delegate       the delegate for the gesture recognizer.
 @param customSelector the selector that should be invoked for the recognizer.
 
 @since 2.0.0.0
 */
+ (void)addGestureToView:(UIView *)view withDelegate:(id)delegate withSelector:(SEL)customSelector;

@end
