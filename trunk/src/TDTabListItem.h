//
//  TDTabListItem.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDListItem.h>

@class TDTabModel;
@class TDTabsListViewController;

@interface TDTabListItem : TDListItem {
    TDTabModel *tabModel;
    NSButton *closeButton;
    NSProgressIndicator *progressIndicator;
    TDTabsListViewController *tabsListViewController;
    
    BOOL showsCloseButton;
    BOOL showsProgressIndicator;
    
    NSTimer *drawHiRezTimer;
    BOOL drawHiRez;
}

+ (NSString *)reuseIdentifier;

- (void)drawHiRezLater;

- (CGRect)borderRectForBounds:(CGRect)bounds;
- (CGRect)titleRectForBounds:(CGRect)bounds;
- (CGRect)closeButtonRectForBounds:(CGRect)bounds;
- (CGRect)progressIndicatorRectForBounds:(CGRect)bounds;
- (CGRect)thumbnailRectForBounds:(CGRect)bounds;

@property (nonatomic, retain) TDTabModel *tabModel;
@property (nonatomic, retain) NSButton *closeButton;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) TDTabsListViewController *tabsListViewController; // weakref
@property (nonatomic, assign) BOOL showsCloseButton;
@property (nonatomic, assign) BOOL showsProgressIndicator;
@end
