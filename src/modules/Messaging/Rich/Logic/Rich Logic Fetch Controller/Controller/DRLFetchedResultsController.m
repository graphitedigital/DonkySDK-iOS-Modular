//
//  DRLFetchedResultsController.m
//  RichInbox
//
//  Created by Donky Networks on 24/07/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRLFetchedResultsController.h"
#import "DNRichMessage.h"
#import "DNDataController.h"
#import "NSManagedObject+DNHelper.h"
#import "DNSystemHelpers.h"
#import "DNLoggingController.h"

@interface DRLFetchedResultsController ()
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation DRLFetchedResultsController

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        [self setTableView:tableView];
        
    }

    return self;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {

        NSFetchRequest *request = [DNRichMessage fetchRequestWithContext:[[DNDataController sharedInstance] mainContext]];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentTimestamp" ascending:NO]]];

        if ([self isSearching]) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"messageDescription CONTAINS[cd] %@ || senderDisplayName CONTAINS[cd] %@", [self searchString], [self searchString]]];
        }

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DNDataController sharedInstance] mainContext] sectionNameKeyPath:nil cacheName:nil];
        [_fetchedResultsController setDelegate:self];

        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            DNErrorLog(@"Problem fetching comments for request: %@\nError: %@", request, [error localizedDescription]);
        }
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {

        case NSFetchedResultsChangeInsert: {
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if ([[self delegate] respondsToSelector:@selector(insertRowsAtIndexPaths:)]) {
                [[self delegate] insertRowsAtIndexPaths:@[newIndexPath]];
            }
        }
            break;

        case NSFetchedResultsChangeDelete: {
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

            if ([[self delegate] respondsToSelector:@selector(deleteRowsAtIndexPath:)]) {
                [[self delegate] deleteRowsAtIndexPath:indexPath];
            }
        }
            break;

        case NSFetchedResultsChangeUpdate: {

            if ([[self delegate] respondsToSelector:@selector(reloadRowsAtIndexPaths:)]) {
                [[self delegate] reloadRowsAtIndexPaths:@[indexPath]];
            }

            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;

        case NSFetchedResultsChangeMove:
            if (indexPath != newIndexPath) {
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

@end
