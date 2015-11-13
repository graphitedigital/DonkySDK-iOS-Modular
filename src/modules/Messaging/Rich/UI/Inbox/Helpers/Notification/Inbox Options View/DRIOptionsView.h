//
//  DRIOptionsView.h
//  RichInbox
//
//  Created by Donky Networks on 07/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DRIOptionsShare = 0,
    DRIOptionsDelete
} DRIOptions;

@protocol DRIOptionsViewDelegate <NSObject>

- (void)deleteButtonTapped;

@end

@interface DRIOptionsView : UIView

@property (nonatomic, weak) id <DRIOptionsViewDelegate> delegate;

- (instancetype)init;

- (void)updateDelete:(BOOL)enabled;

@end
