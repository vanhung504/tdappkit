//
//  TDViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDViewController.h>
#import <TDAppKit/TDTabBarItem.h>

@implementation TDViewController {
    BOOL _TD_isViewLoaded;
}

- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    
    if ([self isViewLoaded]) {
        TDViewControllerView *v = [self viewControllerView];
        if (v) {
            v.viewController = nil;
        }
    }
    self.tabBarItem = nil;
    [super dealloc];
}


- (void)loadView {
    [super loadView];
    _TD_isViewLoaded = YES;
    [self viewDidLoad];
}


- (void)setView:(NSView *)v {
    if (v) {
        [(TDViewControllerView *)v setViewController:self];
    } else {
        _TD_isViewLoaded = NO;
    }
    [super setView:v];
}


- (TDViewControllerView *)viewControllerView {
    return (TDViewControllerView *)[self view];
}


- (BOOL)isViewLoaded {
    return _TD_isViewLoaded;
}


- (void)viewDidLoad {
    
}


- (void)viewWillAppear:(BOOL)animated {
    
}


- (void)viewDidAppear:(BOOL)animated {
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
}


- (void)viewDidDisappear:(BOOL)animated {
    
}


- (void)viewWillMoveToSuperview:(NSView *)v {
    
}


- (void)viewDidMoveToSuperview {
    
}


- (void)viewWillMoveToWindow:(NSWindow *)win {
    
}


- (void)viewDidMoveToWindow {
    
}

@end
