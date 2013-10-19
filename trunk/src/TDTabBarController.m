//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <TDAppKit/TDTabBarController.h>
#import <TDAppKit/TDTabBar.h>
#import <TDAppKit/TDTabBarItem.h>
#import <TDAppKit/TDFlippedColorView.h>
#import "TDTabBarControllerView.h"

@interface TDTabBarController ()
- (void)layoutSubviews;
- (void)layoutTabBarItems;
- (void)setUpTabBarItems;
- (void)highlightButtonAtIndex:(NSInteger)i;

@property (nonatomic, readwrite, retain) TDTabBar *tabBar;
@property (nonatomic, retain) NSArray *tabBarItems;
@property (nonatomic, retain) TDTabBarItem *selectedTabBarItem;
@end

@implementation TDTabBarController

- (id)init {
    if (self = [super init]) {
        selectedIndex = -1;
    }
    return self;
}


- (void)dealloc {
    [tabBar removeFromSuperview];
    [containerView removeFromSuperview];
    
    for (TDTabBarItem *item in tabBarItems) {
        [item.button removeFromSuperview];
    }

    self.tabBar = nil;
    self.containerView = nil;
    self.delegate = nil;
    self.selectedViewController = nil;
    self.viewControllers = nil;
    self.tabBarItems = nil;
    self.selectedTabBarItem = nil;
    [super dealloc];
}


- (void)loadView {
    TDTabBarControllerView *tbcv = [[[TDTabBarControllerView alloc] initWithFrame:NSZeroRect] autorelease];
    self.view = tbcv;
    tbcv.color = [NSColor windowBackgroundColor];
    [tbcv setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [tbcv setWantsLayer:NO];
    
    self.tabBar = [[[TDTabBar alloc] initWithFrame:NSMakeRect(0, 0, 0, [TDTabBar defaultHeight])] autorelease];
    [tabBar setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [tbcv addSubview:tabBar];
    
    TDFlippedColorView *cv = [[[TDFlippedColorView alloc] initWithFrame:NSZeroRect] autorelease];
    cv.color = [NSColor windowBackgroundColor];
    [cv setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [tbcv addSubview:cv];
    self.containerView = cv;
    
    tbcv.tabBar = self.tabBar;
    tbcv.containerView = self.containerView;
    
    [self viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutSubviews];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.selectedViewController = nil; // this will trigger -viewWillDisappear: & -viewDidDisappear on the selectedView controller when this tabbarcontroller is popped. 
                                       // this is desireable.
}


- (IBAction)tabBarItemClick:(id)sender {
    //NSParameterAssert([tabBarItems containsObject:sender]);
    NSInteger i = -1;
    for (TDTabBarItem *item in tabBarItems) {
        i++;
        if (item.button == sender) break;
    }
    self.selectedIndex = i;
    [self highlightButtonAtIndex:i]; // force
}


- (void)layoutSubviews {
    TDTabBarControllerView *v = (TDTabBarControllerView *)[self view];
    [v setNeedsLayout];
    [self layoutTabBarItems];
}


- (void)layoutTabBarItems {
    [self.tabBar setNeedsLayout];
    
    [self highlightButtonAtIndex:self.selectedIndex];
    
//    NSUInteger i = 0;
//    NSUInteger selIdx = self.selectedIndex;
//    for (TDTabBarItem *item in self.tabBarItems) {
//        [[item.button cell] setHighlighted:(i == selIdx)];
//        ++i;
//    }
}


#pragma mark -
#pragma mark Properties

- (void)setSelectedIndex:(NSUInteger)i {
    NSParameterAssert(0 == i || i < [viewControllers count]);
    if (i == selectedIndex) return;
    
    selectedIndex = i;
    self.selectedViewController = [viewControllers objectAtIndex:i];
}


- (void)setSelectedViewController:(TDViewController *)vc {
    NSParameterAssert(nil == vc || [viewControllers containsObject:vc]);
    
    if (selectedViewController && vc == selectedViewController) {
        return; // Dont re-show the same view controller
    }
    
    if (delegate && [delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![delegate tabBarController:self shouldSelectViewController:selectedViewController]) {
            return;
        }
    }
    
    if (selectedViewController) {
        [selectedViewController viewWillDisappear:NO];
        [selectedViewController.view removeFromSuperview];
        [selectedViewController viewDidDisappear:NO];
    }
    
    selectedIndex = [viewControllers indexOfObject:vc];
    selectedViewController = vc;
        
    if (delegate && [delegate respondsToSelector:@selector(tabBarController:willSelectViewController:)]) {
        [delegate tabBarController:self willSelectViewController:selectedViewController];
    }
    
    [self view]; // trigger view load if necessary
    
    [selectedViewController.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [selectedViewController.view setFrame:[containerView bounds]];
    
    [selectedViewController viewWillAppear:NO];
    [containerView addSubview:selectedViewController.view];
    [selectedViewController viewDidAppear:NO];
    
    [self highlightButtonAtIndex:selectedIndex];
    
    if (delegate && [delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [delegate tabBarController:self didSelectViewController:selectedViewController]; // TODO NO?
    }
}


- (void)setViewControllers:(NSArray *)vcs animated:(BOOL)animated {
    self.viewControllers = (id)vcs;
}


- (void)setViewControllers:(NSArray *)vcs {
    if (viewControllers != vcs) {
        [viewControllers release];
        viewControllers = [vcs copy];
        self.selectedIndex = 0;
        
        [self setUpTabBarItems];
    }
}


- (void)setUpTabBarItems {
    NSInteger c = [viewControllers count];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:c];
    
    if (c > 0) {
        NSInteger tag = 0;
        for (TDViewController *vc in viewControllers) {
            
            TDTabBarItem *item = [vc tabBarItem];
            if (!item) {
                TDAssert([vc.title length]);
                item = [[[TDTabBarItem alloc] initWithTitle:vc.title image:nil tag:tag++] autorelease];
            }

            [item.button setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin];
            [item.button setTarget:self];
            [item.button setAction:@selector(tabBarItemClick:)];
            
            [tabBar addSubview:item.button];
            [items addObject:item];
        }
    }
    
    self.tabBarItems = [[items copy] autorelease];
    [self highlightButtonAtIndex:selectedIndex];
}


- (void)highlightButtonAtIndex:(NSInteger)i {
    if (i < 0 || ![tabBarItems count] || i > [tabBarItems count] - 1) {
        return;
    }

    TDTabBarItem *newItem = [tabBarItems objectAtIndex:i];
    
    if (selectedTabBarItem != newItem) {
        [selectedTabBarItem.button setState:NSOffState];
        [[selectedTabBarItem.button cell] setHighlighted:NO];
        self.selectedTabBarItem = newItem;
    }
    [selectedTabBarItem.button setState:NSOnState];
    [[selectedTabBarItem.button cell] setHighlighted:YES];
}


@synthesize tabBar;
@synthesize containerView;
@synthesize delegate;
@synthesize viewControllers;
@synthesize selectedViewController;
@synthesize selectedIndex;
@synthesize tabBarItems;
@synthesize selectedTabBarItem;
@end
