//
//  DNRichMessage+DNRichMessageHelper.h
//  RichInbox
//
//  Created by Chris Watson on 13/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DNRichMessage.h"

@interface DNRichMessage (DNRichMessageHelper)

/*!
 Helper method to determine if a rich message has completey expired. This means 
 a rich message that has a custom expiration date but NO expired content OR the rich message
 has exceeded the maximum message life time condigured on the app space.
 
 @return bool determining whether a rich message has fully expired.
 
 @since 2.2.2.7
 */
- (BOOL)richHasCompletelyExpired;

@end

