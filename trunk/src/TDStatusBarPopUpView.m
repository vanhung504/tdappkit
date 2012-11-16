//
//  TDStatusBarPopUpControl.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarPopUpView.h>
#import <TDAppKit/TDUtils.h>

#define POPUP_MARGIN_X 3.0
#define MENU_OFFSET_Y 2.0

static NSDictionary *sTextAttrs = nil;

@interface TDStatusBarPopUpView ()
- (void)updateTextFromPopUpSelection;
@end

@implementation TDStatusBarPopUpView

+ (void)initialize {
    if ([TDStatusBarPopUpView class] == self) {
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSCenterTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByClipping];
        
        //        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        //        [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.2]];
        //        [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        //        [shadow setShadowBlurRadius:1.0];
        
        sTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                      [NSColor textColor], NSForegroundColorAttributeName,
                      //                      shadow, NSShadowAttributeName,
                      paraStyle, NSParagraphStyleAttributeName,
                      nil];
    }
}


+ (NSDictionary *)defaultTextAttributes {
    return sTextAttrs;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubviews];
    }
    
    return self;
}


- (void)dealloc {
    self.popUpButton = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpSubviews];
    [self updateTextFromPopUpSelection];
}


- (BOOL)acceptsFirstResponder {
    return YES;
}


- (void)mouseDown:(NSEvent *)evt {
    NSMenu *menu = [_popUpButton menu];
    if (![[menu itemArray] count]) return;
    
    [menu setFont:[NSFont systemFontOfSize:9.0]];
    NSInteger idx = [_popUpButton indexOfSelectedItem];
    NSMenuItem *item = [menu itemAtIndex:idx];
    
    NSSize menuSize = [menu size];
    NSRect bounds = [self bounds];
    NSRect popUpRect = [self popUpButtonRectForBounds:bounds];
    NSPoint p = NSMakePoint(NSMidX(popUpRect) - menuSize.width / 2.0, NSMaxY(popUpRect) - MENU_OFFSET_Y);
    [menu popUpMenuPositioningItem:item atLocation:p inView:self];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSRect bounds = [self bounds];

    BOOL isMain = [[self window] isMainWindow];
    NSColor *strokeColor = nil;
    if (isMain ) {
        strokeColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
    } else {
        strokeColor = [NSColor colorWithDeviceWhite:0.5 alpha:1.0];
    }
    [strokeColor setStroke];
    
    NSPoint botLef = NSMakePoint(NSMinX(bounds), NSMinY(bounds));
    NSPoint topLef = NSMakePoint(NSMinX(bounds), NSMaxY(bounds));
    [NSBezierPath strokeLineFromPoint:topLef toPoint:botLef];
    
    NSPoint botRit = NSMakePoint(NSMaxX(bounds), NSMinY(bounds));
    NSPoint topRit = NSMakePoint(NSMaxX(bounds), NSMaxY(bounds));
    [NSBezierPath strokeLineFromPoint:topRit toPoint:botRit];
}


- (void)layoutSubviews {
    NSRect bounds = [self bounds];
    
    self.popUpButton.frame = [self popUpButtonRectForBounds:bounds];
}


- (void)setUpSubviews {
    NSColor *topColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
    NSColor *botColor = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
    self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    
    topColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
    botColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
    self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    
    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    
    [_popUpButton setHidden:YES];

    NSMenu *menu = [_popUpButton menu];
    [menu setFont:[NSFont systemFontOfSize:9.0]];
    [menu setDelegate:self];
}


- (NSRect)popUpButtonRectForBounds:(NSRect)bounds {
    NSRect popUpBounds = [_popUpButton bounds];
    
    CGFloat x = POPUP_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - popUpBounds.size.height / 2.0);
    CGFloat w = TDRoundAlign(bounds.size.width - POPUP_MARGIN_X * 2.0);
    CGFloat h = popUpBounds.size.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (void)updateTextFromPopUpSelection {
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        [_popUpButton synchronizeTitleAndSelectedItem];
        self.text = [_popUpButton titleOfSelectedItem];
    });
}


#pragma mark -
#pragma mark NSMenuDelegate

- (void)menuDidClose:(NSMenu *)menu {
    [self updateTextFromPopUpSelection];
}

@end
