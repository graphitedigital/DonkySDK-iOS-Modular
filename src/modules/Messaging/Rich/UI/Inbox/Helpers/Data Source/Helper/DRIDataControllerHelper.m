//
//  DRIDataControllerHelper.m
//  RichInbox
//
//  Created by Donky Networks on 27/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "DRIDataControllerHelper.h"
#import "DNSystemHelpers.h"
#import "DNRichMessage+DNRichMessageHelper.h"
#import "DCUIMainController.h"
#import "DRUIThemeConstants.h"
#import "DCUIConstants.h"

@implementation DRIDataControllerHelper

+ (NSIndexPath *)handleRowSelectedState:(NSIndexPath *)indexPath richMessage:(DNRichMessage *)richMessage tableView:(UITableView *)tableView selectedMessages:(NSArray *)selectedMessages delegate:(id)delegate dataSource:(DRIDataController *)dataSource originnalIndexPath:(NSIndexPath *)originalIndexPath {

    DRITableViewCell *cell = (DRITableViewCell *) [tableView cellForRowAtIndexPath:indexPath];

    if (tableView.isEditing) {
        if ([selectedMessages containsObject:indexPath]) {
            [cell setSelected:YES];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [cell setSelected:NO];
        }

        if ([delegate respondsToSelector:@selector(messagesSelected:)]) {
            [delegate messagesSelected:[selectedMessages count] > 0];
        }

        return originalIndexPath;
    }
    else {

        [dataSource closeAllCells];
        [cell setSelected:YES];

        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        originalIndexPath = indexPath;
    }

    //We only deselect if we are not on an iPad or landscape iPhone 6+:
    if (![DNSystemHelpers isDeviceIPad] && ![DNSystemHelpers isDeviceSixPlusLandscape]) {
        [dataSource closeAllCells];
        [cell setSelected:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    return originalIndexPath;
}


+ (DRITableViewCell *)attemptToSelectNextRow:(NSIndexPath *)indexPath fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView {

    //Check for cell above:
    __block DRITableViewCell *cell = nil;
    [[fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *message = obj;
        if (![message richHasCompletelyExpired] && (idx > indexPath.row || idx == indexPath.row - 1)) {
            cell = (DRITableViewCell *) [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            *stop = YES;
        }
    }];

    return cell;
}

+ (NSIndexPath *)toggleSelectedCell:(DRITableViewCell *)cell tableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController dataSource:(DRIDataController *)controller delegate:(id <DRIDataControllerDelegate>)delegate originalIndexPath:(NSIndexPath *)originalIndexPath {

    NSIndexPath *newIndexPath = [tableView indexPathForCell:cell];

    DNRichMessage *richMessage = [fetchedResultsController objectAtIndexPath:newIndexPath];

    if (!newIndexPath) {
        return originalIndexPath;
    }

    if ([[fetchedResultsController fetchedObjects] count] && !richMessage) {
        richMessage = [fetchedResultsController objectAtIndexPath:newIndexPath];
    }

    if ([richMessage richHasCompletelyExpired]) {
        //We don't select old messages, so we look for a new one:
        originalIndexPath = nil;
        [DRIDataControllerHelper attemptToSelectNextRow:newIndexPath fetchedResultsController:fetchedResultsController tableView:tableView];
        return originalIndexPath;
    }

    [tableView deselectRowAtIndexPath:originalIndexPath animated:NO];

    [controller closeAllCells];

    [cell setSelected:YES];

    //If we are on the first, we scroll to the top:
    [tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    originalIndexPath = newIndexPath;

    if ([delegate respondsToSelector:@selector(richInboxMessageSelected:)] && ![richMessage richHasCompletelyExpired]) {
        [delegate richInboxMessageSelected:richMessage];
    }

    return originalIndexPath;
}

+ (CGFloat)sizeOfTableViewRowWithMessage:(DNRichMessage *)richMessage tableView:(UITableView *)tableView theme:(DRUITheme *)theme {
    CGFloat stringHeight = [DCUIMainController sizeForString:[richMessage senderDisplayName]
                                                     font:[theme fontForKey:kDRUIInboxCellTitleFont]
                                                maxHeight:CGFLOAT_MAX
                                                 maxWidth:(tableView.frame.size.width - kDCUIAvatarHeightWithTenPixelInsets)].height;
    stringHeight += [DCUIMainController sizeForString:[richMessage messageDescription]
                                                 font:[theme fontForKey:kDRUIInboxCellDescriptionFont]
                                            maxHeight:CGFLOAT_MAX
                                             maxWidth:(tableView.frame.size.width - kDCUIAvatarHeightWithTenPixelInsets)].height;
    //We add the buffer to account for the insets and gap between title and description:
    stringHeight += 30;

    CGFloat minimumHeight = kDCUIAvatarHeightWithTenPixelInsets; //This equates to the height of the avatars and the insets of the avatar

    if (stringHeight < minimumHeight)
        return minimumHeight;

    return stringHeight;
}

@end
