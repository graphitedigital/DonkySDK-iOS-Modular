//
//  DRITableViewCell.m
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "UIView+AutoLayout.h"
#import "DRITableViewCell.h"
#import "DNAssetController.h"
#import "DRITableViewCellHelper.h"
#import "DRUIThemeConstants.h"
#import "NSDate+DCMDate.h"
#import "DCUIMainController.h"
#import "DNRichMessage+DNRichMessageHelper.h"
#import "DRichMessage+Localization.h"
#import "DCUIConstants.h"
#import "DRIAppearanceHelper.h"
#import "DRITableViewCellExpirationHelper.h"

static NSString *const DRTableCellEditControlClass = @"UITableViewCellEditControl";

@interface DRITableViewCell ()
@property(nonatomic, strong) NSArray *descriptionLabelConstraints;
@property(nonatomic, strong) DRICellPanGestureHelper *panHelper;
@property (nonatomic, strong) DCUINewBannerView *bannerView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) NSArray *dateLabelConstraint;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property(nonatomic, strong) UIView *topContentView;
@property (nonatomic, strong) NSTimer *expiryTimer;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic) BOOL constraintsSetup;
@end

@implementation DRITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [[self contentView] addSubview:[self moreButton]];

        [[self contentView] addSubview:[self topContentView]];

        [[self topContentView] addSubview:[self avatarImageView]];
        [[self topContentView] addSubview:[self titleLabel]];
        [[self topContentView] addSubview:[self descriptionLabel]];
        [[self topContentView] addSubview:[self dateLabel]];
        [[self avatarImageView] addSubview:[self bannerView]];

        UIView *backgroundView = [UIView autoLayoutView];
        [backgroundView setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
        [self setSelectedBackgroundView:backgroundView];

        [[self contentView] setBackgroundColor:[UIColor clearColor]];

    }

    return self;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        return _moreButton = [DRITableViewCellHelper moreButton];
    }
    return _moreButton;
}

- (DCUINewBannerView *)bannerView {
    if (!_bannerView) {
        return _bannerView = [DRITableViewCellHelper bannerView];
    }
    return _bannerView;
}

- (UIView *)topContentView {
    if (!_topContentView) {
        return _topContentView = [DRITableViewCellHelper topContentView];
    }
    return _topContentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        return _titleLabel = [DRITableViewCellHelper textLabelWithNumberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft];
    }
    return _titleLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        return _descriptionLabel = [DRITableViewCellHelper textLabelWithNumberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
    }
    return _descriptionLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        return _avatarImageView = [DRITableViewCellHelper avatarImageViewTheme:self.theme];
    }
    return _avatarImageView;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        return _dateLabel = [DRITableViewCellHelper textLabelWithNumberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentRight];
    }
    return _dateLabel;
}

- (void)setTheme:(DRUITheme *)theme {
    if (theme != _theme) {
        _theme = theme;
    }

    [[self titleLabel] setFont:[[self theme] fontForKey:kDRUIInboxCellTitleFont]];
    [[self descriptionLabel] setFont:[[self theme] fontForKey:kDRUIInboxCellDescriptionFont]];
    [[self dateLabel] setFont:[[self theme] fontForKey:kDRUIInboxCellDateFont]];

    [[self topContentView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];

    [[self moreButton] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellMoreButtonColour]];

    [[self bannerView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxNewBannerColour]];
    [[[self bannerView] textLabel] setFont:[[self theme] fontForKey:kDRUIInboxNewBannerFont]];
    [[[self bannerView] textLabel] setTextColor:[[self theme] colourForKey:kDRUInboxNewBannerTextColour]];

    [[self titleLabel] setTextColor:[[self theme] colourForKey:kDRUIInboxUnreadTitleColour]];
    [[self descriptionLabel] setTextColor:[[self theme] colourForKey:kDRUIInboxUnreadDescriptionColour]];
    [[self dateLabel] setTextColor:[[self theme] colourForKey:kDRUIInboxUnreadDateColour]];
    [[self bannerView] setHidden:NO];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (![self constraintsSetup]) {

        [self setPanHelper:[[DRICellPanGestureHelper alloc] initWithContentView:[self contentView] moreButton:[self moreButton] topContent:[self topContentView] isEditing:[self istableViewEditing]]];
        [[self panHelper] setPanHelperDelegate:self];

        [[self topContentView] pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinBottomEdge inset:0.0];

        [[self panHelper] setContentViewRightConstraint:[[self topContentView] pinAttribute:NSLayoutAttributeRight toSameAttributeOfItem:[self contentView]]];
        [[self panHelper] setContentViewLeftConstraint:[[self topContentView] pinAttribute:NSLayoutAttributeLeft toSameAttributeOfItem:[self contentView]]];

        [[self moreButton] pinToSuperviewEdges:JRTViewPinRightEdge | JRTViewPinTopEdge | JRTViewPinBottomEdge inset:0.0];
        [[self moreButton] constrainToWidth:96];

        [[self moreButton] addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        //Get avatar image
        [[self avatarImageView] pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge inset:10.0];
        [[self avatarImageView] constrainToSize:CGSizeMake(kDCUIAvatarHeight, kDCUIAvatarHeight)];

        [[self dateLabel] pinAttribute:NSLayoutAttributeTop toSameAttributeOfItem:[self avatarImageView]];
        [[self dateLabel] pinToSuperviewEdges:JRTViewPinRightEdge inset:10.0];

        [[self titleLabel] pinAttribute:NSLayoutAttributeTop toSameAttributeOfItem:[self avatarImageView]];
        [[self titleLabel] pinAttribute:NSLayoutAttributeRight toAttribute:NSLayoutAttributeLeft ofItem:[self dateLabel] withConstant:-10];
        [[self titleLabel] pinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeRight ofItem:[self avatarImageView] withConstant:10];

        [[self descriptionLabel] pinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeRight ofItem:[self avatarImageView] withConstant:10];
        [[self descriptionLabel] pinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeBottom ofItem:[self titleLabel] withConstant:0];
        [[self descriptionLabel] pinToSuperviewEdges:JRTViewPinRightEdge inset:10];

        [[self bannerView] pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];

        [self setConstraintsSetup:YES];
    }
}

- (void)prepareForReuse {

    [super prepareForReuse];

    [[self refreshTimer] invalidate];
    [self setRefreshTimer:nil];

    [[self expiryTimer] invalidate];
    [self setExpiryTimer:nil];

    [[self titleLabel] setAlpha:1.0];
    [[self descriptionLabel] setAlpha:1.0];
    [[self avatarImageView] setAlpha:1.0];
    [[self bannerView] setAlpha:1.0];
    [[self dateLabel] setAlpha:1.0];
    [[self moreButton] setEnabled:YES];

    [self closeCell];
}

- (void)configureCell {

    //Avatar:
    [self loadRichMessageAvatar];

    //Title
    [[self titleLabel] setText:[[self richMessage] senderDisplayName]];

    //Description:
    [[self descriptionLabel] setText:[[self richMessage] messageDescription]];

    //Date label
    [[self dateLabel] setText:[DRITableViewCellHelper dateWithMessage:[self richMessage]]];

    if ([self dateLabelConstraint]) {
        [[self dateLabel] removeConstraints:[self dateLabelConstraint]];
        [[self dateLabel] layoutIfNeeded];
    }

    CGFloat stringWidth = [DCUIMainController sizeForString:[[self dateLabel] text] font:[[self theme] fontForKey:kDRUIInboxCellDateFont] maxHeight:CGFLOAT_MAX maxWidth:CGFLOAT_MAX].width;
    [self setDateLabelConstraint:[[self dateLabel] constrainToMinimumSize:CGSizeMake(stringWidth, 0)]];

    [self resetLayouts];

    if ([[[self richMessage] read] boolValue]) {
        [self setReadAppearance];
    }

    if ([[self richMessage] richHasCompletelyExpired]) {
       [self setExpiredAppearance];
    }
    else {
        [[self panHelper] setEnabled:YES];
        [self calculateExpiryDate];

        [self startTimer:[self richMessage]];
    }

    [[self panHelper] setEditing:[self istableViewEditing]];
}

- (void)loadRichMessageAvatar {
    UIImage *temp = [DNAssetController imageFromTempDir:[[self richMessage] messageID]];
    UIImage *avatarImage =  temp ? : [[[self richMessage] read] boolValue] ? [UIImage imageNamed:@"donky_default_avatar_open.png"] : [UIImage imageNamed:@"donky_default_avatar_closed.png"];
    [[self avatarImageView] setImage:avatarImage];

    if ([[self richMessage] avatarAssetID] && !temp) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *avatar = [DNAssetController avatarAssetForID:[[self richMessage] avatarAssetID]];
            //Save to disk:
            [DNAssetController saveImageToTempDir:avatar withImageName:[[self richMessage] messageID]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if (avatar) {
                    [[self avatarImageView] setImage:avatar];
                }
                [[self avatarImageView] setNeedsDisplay];
            });
        });
    }
}

- (void)setReadAppearance {
    [DRIAppearanceHelper setReadAppearance:[self titleLabel] description:[self descriptionLabel] dateLabel:[self dateLabel] bannerView:[self bannerView] theme:[self theme]];
}

- (void)setExpiredAppearance {
    [[self titleLabel] setAlpha:0.5];
    [[self descriptionLabel] setAlpha:0.5];
    [[self avatarImageView] setAlpha:0.5];
    [[self bannerView] setAlpha:0.5];
    [[self dateLabel] setAlpha:0.75];
    [[self moreButton] setEnabled:NO];
    [[self panHelper] setEnabled:NO];
    [[self dateLabel] setText:DRichMessageLocalizedString(@"rich_inbox_expired_time_stamp")];
    if ([[self delegate] respondsToSelector:@selector(messageExpired:)]) {
        [[self delegate] messageExpired:self];
    }
}

- (void)resetLayouts {
    if ([self descriptionLabelConstraints]) {
        [[self descriptionLabel] removeConstraints:[self descriptionLabelConstraints]];
    }
    
    [self setDescriptionLabelConstraints:[[self descriptionLabel] constrainToMinimumSize:CGSizeMake(0, 0) maximumSize:CGSizeMake(0, [DRITableViewCellHelper messageHeight:[[self descriptionLabel] text] theme:[self theme] cellWidth:[self frame] editMode:![self istableViewEditing]])]];
    [[self descriptionLabel] layoutIfNeeded];
}

#pragma mark -
#pragma mark - Expiration Handling

- (void)calculateExpiryDate {
   self.expiryTimer = [DRITableViewCellExpirationHelper expiryTimerForMessage:[self richMessage] target:self];
}

- (void)setTableViewEditing:(BOOL)tableViewEditing {
    if (tableViewEditing != _tableViewEditing) {
        _tableViewEditing = tableViewEditing;

        [[self panHelper] setEditing:_tableViewEditing];
    }

    if (![self istableViewEditing]) {
        [self setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];
    }
}

#pragma mark -
#pragma mark - Date Label:

- (void)refreshDateLabel:(NSTimer *)timer {
    DNRichMessage *richMessage = [timer userInfo];
    if (![richMessage richHasCompletelyExpired]) {
        [[self dateLabel] setText:[DRITableViewCellHelper dateWithMessage:richMessage]];
        [self startTimer:richMessage];
    }
}

- (void)startTimer:(DNRichMessage *)richMessage {
    //Does the date cell need to refresh:
    BOOL refresh = [[richMessage sentTimestamp] needsRefresh];

    if (refresh) {
        //Calculate when:
        NSInteger nextRefresh = [[richMessage sentTimestamp] nextRefresh];
        [self setRefreshTimer:[NSTimer scheduledTimerWithTimeInterval:nextRefresh target:self selector:@selector(refreshDateLabel:) userInfo:richMessage repeats:NO]];
    }
}

#pragma mark -
#pragma mark - Delegates

- (void)moreButtonTapped:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(cellButtonWasTapped:)]) {
        [[self delegate] cellButtonWasTapped:sender];
    }
}

- (void)disableScrollView:(BOOL)disable {
    if ([[self delegate] respondsToSelector:@selector(shouldDisableScroll:leaveCells:)]) {
        [[self delegate] shouldDisableScroll:disable leaveCells:self];
    }
}

- (void)closeCell {
    [[self panHelper] resetConstraintConstantsToZero];
}

- (void)cellWasOpened:(BOOL)opened {
    if ([[self delegate] respondsToSelector:@selector(cell:wasOpened:)]) {
        [[self delegate] cell:self wasOpened:opened];
    }

    if (self.selected && !opened) {
        [[self contentView] setBackgroundColor:[UIColor whiteColor]];
        [[self topContentView] setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
    }
}

- (void)cellWasPanned {
    if (self.selected && ![self istableViewEditing]) {
        [[self topContentView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];
    }
}

#pragma mark -
#pragma mark - State Handlers

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    __block id editingControlView = nil;
    __block UIImageView *selectionImage = nil;
    if ([self istableViewEditing]) {
        [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:NSClassFromString(DRTableCellEditControlClass)]) {
                editingControlView = obj;
                selectionImage = [[editingControlView subviews] firstObject];
            }
        }];
    }

    if (selected) {
        [[self topContentView] setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
        if ([self istableViewEditing]) {
            [self setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
        }

        [editingControlView setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
        if ([[self theme] imageForKey:kDRUIInboxSelectionTickSelected]) {
            [selectionImage setImage:[UIImage imageNamed:[[self theme] imageForKey:kDRUIInboxSelectionTickSelected]]];
        }
    }
    else {
        [[self topContentView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];
        [self setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];

        [editingControlView setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];
        if ([[self theme] imageForKey:kDRUIInboxSelectionTickUnSelected]) {
            [selectionImage setImage:[UIImage imageNamed:[[self theme] imageForKey:kDRUIInboxSelectionTickUnSelected]]];
        }
    }

    [[self bannerView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxNewBannerColour]];
    [[self moreButton] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellMoreButtonColour]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    __block id editingControlView = nil;
    __block UIImageView *selectionImage = nil;
    if ([self istableViewEditing]) {
        [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:NSClassFromString(DRTableCellEditControlClass)]) {
                editingControlView = obj;
                selectionImage = [[editingControlView subviews] firstObject];
            }
        }];
    }

    if (highlighted) {
        [self setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
        [[self topContentView] setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];

        [editingControlView setBackgroundColor:[[self theme] colourForKey:kDRUInboxCellSelectedColour]];
        if ([[self theme] imageForKey:kDRUIInboxSelectionTickHighlighted]) {
            [selectionImage setImage:[UIImage imageNamed:[[self theme] imageForKey:kDRUIInboxSelectionTickHighlighted]]];
        }
    }
    else if (![self istableViewEditing] || ![self isSelected]) {

        if ([[self theme] imageForKey:kDRUIInboxSelectionTickUnHighlighted]) {
            [selectionImage setImage:[UIImage imageNamed:[[self theme] imageForKey:kDRUIInboxSelectionTickUnHighlighted]]];
        }
        [self setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellBackgroundColour]];
    }

    [[self bannerView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxNewBannerColour]];
    [[self moreButton] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxCellMoreButtonColour]];
}

@end