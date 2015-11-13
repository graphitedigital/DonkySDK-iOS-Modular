//
//  DNRichMessage+DNRichMessageHelper.h
//  RichInbox
//
//  Created by Donky Networks on 13/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "DNRichMessage.h"

@interface DNRichMessage (DNRichMessageHelper)

/*!
 Helper method to determine if a rich message has completely expired. This means
 a rich message that has a custom expiration date but NO expired content OR the rich message
 has exceeded the maximum message life time configured on the app space.
 
 @return BOOL determining whether a rich message has fully expired.
 
 @since 2.2.2.7
 */
- (BOOL)richHasCompletelyExpired;

/*!
 Helper to determine if a rich message has reached it's maximum expiration time.
 
 @return BOOL determining if rich message has reached it's maximum expieration.
 
 @since 2.5.4.3
 */
- (BOOL)richHasReachedExpiration;

/*!
 Whether the rich message can be shared, this depends on several variables. Whether there is a link,
 whether it can be shared and if it is expired or not.
 
 @return BOOL determining if the message can be shared.
 
 @since 2.4.3.1
 */
- (BOOL)canBeShared;

@end

