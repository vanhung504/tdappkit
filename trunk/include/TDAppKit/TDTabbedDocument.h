//
//  TDTabbedDocument.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDTabsListViewController.h>

@class TDTabModel;
@class TDTabViewController;

@interface TDTabbedDocument : NSDocument  <TDTabsListViewControllerDelegate> {
    NSMutableArray *tabModels;
    NSMutableArray *tabViewControllers;
    NSUInteger selectedTabIndex;
}

- (IBAction)performClose:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)closeTab:(id)sender;

- (IBAction)newTab:(id)sender;
- (IBAction)newBackgroundTab:(id)sender;

- (void)closeTabAtIndex:(NSUInteger)i;

// subclass
- (void)didAddTabModel:(TDTabModel *)tm;
- (void)selectedTabIndexDidChange;

- (TDTabViewController *)newTabViewController;

@property (nonatomic, retain) NSMutableArray *tabModels;
@property (nonatomic, retain) NSMutableArray *tabViewControllers;
@property (nonatomic, assign) NSUInteger selectedTabIndex;
@property (nonatomic, retain, readonly) TDTabModel *selectedTabModel;
@property (nonatomic, retain, readonly) TDTabViewController *selectedTabViewController;
@end
