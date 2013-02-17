//
//  TDViewController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDViewControllerView.h>

@interface TDViewController : NSViewController {

}

@property (nonatomic, retain, readonly) TDViewControllerView *viewControllerView;

- (void)viewDidLoad;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;

- (void)viewWillMoveToSuperview:(NSView *)v;
- (void)viewDidMoveToSuperview;
- (void)viewWillMoveToWindow:(NSWindow *)win;
- (void)viewDidMoveToWindow;

@end
