//
//  DRISearchController.m
//  RichInbox
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRISearchController.h"
#import "DRIDataController.h"
#import "DRLogicMainController.h"
#import "DNRichMessage.h"

@interface DRISearchController ()
@property(nonatomic, strong) DRIDataController *inboxDataController;

@end

@implementation DRISearchController

- (instancetype)initWithTableViewDataController:(DRIDataController *)inboxDataController {

    self = [super init];
    
    if (self) {

        [self setInboxDataController:inboxDataController];

    }

    return self;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [[self inboxDataController] searchDidStart];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [[self inboxDataController] searchDidEnd];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [[self inboxDataController] searchTableView:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [searchBar setText:nil];

    [searchBar resignFirstResponder];

    [[self inboxDataController] resetSearch];

}

@end
