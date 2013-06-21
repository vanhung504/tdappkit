//
//  TDViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDViewController.h>

@implementation TDViewController {
    BOOL _TD_isViewLoaded;
}

- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    NSView *v = [self view];
    if (v) {
        [(TDViewControllerView *)v setViewController:nil];
    }
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


- (void)viewWillAppear {
    
}


- (void)viewDidAppear {
    
}


- (void)viewWillDisappear {
    
}


- (void)viewDidDisappear {
    
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
