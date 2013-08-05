//
//  TDViewController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDViewControllerView.h>

@class TDTabBarItem;

@interface TDViewController : NSViewController

@property (nonatomic, retain, readonly) TDViewControllerView *viewControllerView;
@property (nonatomic, retain) TDTabBarItem *tabBarItem;

- (BOOL)isViewLoaded;

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)viewWillMoveToSuperview:(NSView *)v;
- (void)viewDidMoveToSuperview;
- (void)viewWillMoveToWindow:(NSWindow *)win;
- (void)viewDidMoveToWindow;

@end
