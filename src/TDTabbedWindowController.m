//
//  TDTabbedWindowController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedWindowController.h>
#import <TDAppKit/TDTabsListViewController.h>
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>

@interface TDTabbedDocument ()
- (void)tabListViewWasSetUp:(TDTabbedWindowController *)wc;
@end

@interface TDTabbedWindowController ()
- (void)setUpTabsListView;
@end

@implementation TDTabbedWindowController

- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    self.tabsListViewController = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Actions

- (BOOL)shouldCloseDocument {
    return [super shouldCloseDocument];
    
}


//- (IBAction)performClose:(id)sender {
//    [[self document] closeTab:sender];
//}


//- (void)close {
//    [[self document] closeTab:nil];
//}


#pragma mark -
#pragma mark NSWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
}


- (void)setUpTabsListView {
    if (tabsListViewController) return;
    
    self.tabsListViewController = [[[TDTabsListViewController alloc] init] autorelease];
    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
    tabsListViewController.delegate = doc;
    [doc tabListViewWasSetUp:self];
}


#pragma mark -
#pragma mark Lion FullScreen

//NSWindowWillEnterFullScreenNotification
//NSWindowDidEnterFullScreenNotification
//NSWindowWillExitFullScreenNotification
//NSWindowDidExitFullScreenNotification

- (void)windowWillEnterFullScreen:(NSNotification *)n {
    fullScreenTransitioning = YES;
}


- (void)windowDidEnterFullScreen:(NSNotification *)n {
    fullScreen = YES;
    fullScreenTransitioning = NO;
}


- (void)windowWillExitFullScreen:(NSNotification *)n {
    fullScreenTransitioning = YES;

}


- (void)windowDidExitFullScreen:(NSNotification *)n {
    fullScreen = NO;
    fullScreenTransitioning = NO;
}


//#pragma mark -
//#pragma mark TDTabsListViewControllerDelegate
//
//- (NSUInteger)numberOfTabsInTabsViewController:(TDTabsListViewController *)tvc {
//    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
//    NSUInteger c = [doc.tabModels count];
//    return c;
//}
//
//
//- (TDTabModel *)tabsViewController:(TDTabsListViewController *)tvc tabModelAtIndex:(NSUInteger)i {
//    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
//    TDTabModel *tabModel = [doc.tabModels objectAtIndex:i];
//    return tabModel;
//}
//
//
//- (NSMenu *)tabsViewController:(TDTabsListViewController *)tvc contextMenuForTabModelAtIndex:(NSUInteger)i {
//    return nil;
//}
//
//
//- (void)tabsViewController:(TDTabsListViewController *)tvc didSelectTabModelAtIndex:(NSUInteger)i {
//    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
//    doc.selectedTabIndex = i;
//}
//
//
//- (void)tabsViewController:(TDTabsListViewController *)tvc didCloseTabModelAtIndex:(NSUInteger)i {
//    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
//    [doc closeTabAtIndex:i];
//}
//
//
//- (void)tabsViewControllerWantsNewTab:(TDTabsListViewController *)tvc {
//    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
//    [doc newTab:nil];
//}
//

- (BOOL)isFullScreen {
    return fullScreen;
}


- (BOOL)isFullScreenTransitioning {
    return fullScreenTransitioning;
}

@synthesize tabsListViewController;
@end
