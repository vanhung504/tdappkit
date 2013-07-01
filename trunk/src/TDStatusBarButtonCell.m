//
//  TDStatusBarButtonCell.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/23/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import "TDStatusBarButtonCell.h"
#import "TDStatusBarButton.h"
#import "TDStatusBarPopUpView.h"
#import <TDAppKit/TDUtils.h>

@implementation TDStatusBarButtonCell

+ (void)initialize {
    if ([TDStatusBarButtonCell class] == self) {

    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.mainBgGradient = nil;
    self.hiBgGradient = nil;
    self.nonMainBgGradient = nil;
    self.mainTopBorderColor = nil;
    self.nonMainTopBorderColor = nil;
    self.mainTopBevelColor = nil;
    self.nonMainTopBevelColor = nil;
    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSColor *bgColor = [NSColor colorWithDeviceWhite:0.77 alpha:1.0];
    self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:[bgColor colorWithAlphaComponent:0.7] endingColor:bgColor] autorelease];

    bgColor = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
    self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:[bgColor colorWithAlphaComponent:0.7] endingColor:bgColor] autorelease];

    bgColor = [NSColor colorWithDeviceWhite:0.93 alpha:1.0];
    self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:[bgColor colorWithAlphaComponent:0.7] endingColor:bgColor] autorelease];
    
    self.mainTopBorderColor = [NSColor colorWithDeviceWhite:0.53 alpha:1.0];
    self.nonMainTopBorderColor = [NSColor colorWithDeviceWhite:0.78 alpha:1.0];
    self.mainTopBevelColor = [NSColor colorWithDeviceWhite:0.88 alpha:1.0];
    self.nonMainTopBevelColor = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
    self.mainBottomBevelColor = [NSColor lightGrayColor];
    self.nonMainBottomBevelColor = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
}


- (BOOL)shouldDrawTopBorder {
    return YES;
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(TDStatusBarButton *)cv {
    BOOL isMain = [[cv window] isMainWindow];
    BOOL isHi = [self isHighlighted];

    NSGradient *bgGradient = nil;
    NSColor *topBorderColor = nil;
    NSColor *topBevelColor = nil;
    NSColor *bottomBevelColor = nil;
    if (isMain) {
        bgGradient = _mainBgGradient;
        topBorderColor = _mainTopBorderColor;
        topBevelColor = _mainTopBevelColor;
        bottomBevelColor = _mainBottomBevelColor;
    } else {
        bgGradient = _nonMainBgGradient;
        topBorderColor = _nonMainTopBorderColor;
        topBevelColor = _nonMainTopBevelColor;
        bottomBevelColor = _nonMainBottomBevelColor;
    }
    
    if (isHi) {
        bgGradient = _hiBgGradient;
    }
    
    // background
    if (bgGradient) {
        [bgGradient drawInRect:[cv bounds] angle:270.0];
    }
    
    // title
    NSString *title = [self title];
    CGRect titleRect = [cv titleRectForBounds:cellFrame];
    [title drawInRect:titleRect withAttributes:[TDStatusBarPopUpView defaultLabelTextAttributes]];
    
    CGFloat y = NSMaxY(cellFrame) - 1.5;
    NSPoint p1 = NSMakePoint(0.0, y);
    NSPoint p2 = NSMakePoint(NSWidth(cellFrame), y);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:1.0];
    
    // top bevel
    if (topBevelColor) {
        [topBevelColor set];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }
    
    // top border
    if (topBorderColor) {
        [topBorderColor set];
        p1.y += 1.0;
        p2.y += 1.0;
        [path removeAllPoints];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }
    
    // bottom bevel
    if (bottomBevelColor) {
        [bottomBevelColor set];
        p1 = NSMakePoint(0.0, 0.5);
        p2 = NSMakePoint(NSWidth(cellFrame), 0.5);
        [path removeAllPoints];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }
    
    // right border
    NSColor *strokeColor = nil;
    if (isMain) {
        strokeColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
    } else {
        strokeColor = [NSColor colorWithDeviceWhite:0.5 alpha:1.0];
    }
    [strokeColor setStroke];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, NSMinX(cellFrame), NSMinY(cellFrame));
    CGContextAddLineToPoint(ctx, NSMinX(cellFrame), NSMaxY(cellFrame));
    CGContextStrokePath(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, NSMaxX(cellFrame), NSMinY(cellFrame));
    CGContextAddLineToPoint(ctx, NSMaxX(cellFrame), NSMaxY(cellFrame));
    CGContextStrokePath(ctx);

}

@end
