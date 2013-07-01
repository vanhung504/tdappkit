//
//  TDStatusBarButton.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 7/1/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDStatusBarButton.h"
#import <TDAppKit/TDStatusBarPopUpView.h>
#import <TDAppKit/TDUtils.h>

#define LABEL_MARGIN_X 8.0
#define VALUE_MARGIN_X 3.0

@interface TDStatusBarButton ()
@property (nonatomic, assign) NSSize titleTextSize;
@end

@implementation TDStatusBarButton

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}



- (BOOL)isFlipped {
    return NO;
}


- (void)viewDidMoveToWindow {
    NSWindow *win = [self window];
    if (win) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:win];
        [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidResignMainNotification object:win];
    }
}


- (void)windowDidBecomeMain:(NSNotification *)n {
    if ([self window]) {
        [self setNeedsDisplay:YES];
    }
}


//- (void)drawRect:(NSRect)dirtyRect {
//    // Drawing code here.
//}


#pragma mark -
#pragma mark Metrics

- (NSRect)titleRectForBounds:(NSRect)bounds {
    CGFloat x = LABEL_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _titleTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(_titleTextSize.width);
    CGFloat h = _titleTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}

#pragma mark -
#pragma mark Properties

- (void)setTitle:(NSString *)s {
    [super setTitle:s];
    if (s) {
        NSDictionary *attrs = [TDStatusBarPopUpView defaultLabelTextAttributes];
        TDAssert([attrs count]);
        self.titleTextSize = [s sizeWithAttributes:attrs];
        
        [self setNeedsDisplay:YES];
    }
}

@end
