//
//  TDStatusBarButtonCell.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/23/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDStatusBarButtonCell : NSButtonCell

- (BOOL)shouldDrawTopBorder;

@property (nonatomic, retain) NSGradient *mainBgGradient;
@property (nonatomic, retain) NSGradient *hiBgGradient;
@property (nonatomic, retain) NSGradient *nonMainBgGradient;
@property (nonatomic, retain) NSColor *mainTopBorderColor;
@property (nonatomic, retain) NSColor *nonMainTopBorderColor;
@property (nonatomic, retain) NSColor *mainTopBevelColor;
@property (nonatomic, retain) NSColor *hiTopBevelColor;
@property (nonatomic, retain) NSColor *nonMainTopBevelColor;
@property (nonatomic, retain) NSColor *mainBottomBevelColor;
@property (nonatomic, retain) NSColor *nonMainBottomBevelColor;
@end
