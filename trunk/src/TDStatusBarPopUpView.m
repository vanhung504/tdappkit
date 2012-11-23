//
//  TDStatusBarPopUpControl.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarPopUpView.h>
#import <TDAppKit/TDUtils.h>

#define DEBUG_DRAW 0

#define LABEL_MARGIN_X 3.0
#define VALUE_MARGIN_X 3.0
#define POPUP_MARGIN_X 3.0
#define MENU_OFFSET_Y 2.0

static NSDictionary *sLabelTextAttrs = nil;
static NSDictionary *sValueTextAttrs = nil;

@interface TDStatusBarPopUpView ()
- (void)setUpSubviews;
- (void)updateValueTextFromPopUpSelection;
@property (nonatomic, assign) NSSize labelTextSize;
@property (nonatomic, assign) NSSize valueTextSize;
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
        
        sLabelTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                           [NSColor textColor], NSForegroundColorAttributeName,
                           //shadow, NSShadowAttributeName,
                           paraStyle, NSParagraphStyleAttributeName,
                           nil];

        sValueTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                           [NSColor textColor], NSForegroundColorAttributeName,
                           //shadow, NSShadowAttributeName,
                           paraStyle, NSParagraphStyleAttributeName,
                           nil];
    }
}


+ (NSDictionary *)defaultLabelTextAttributes {
    return sLabelTextAttrs;
}


+ (NSDictionary *)defaultValueTextAttributes {
    return sValueTextAttrs;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubviews];
    }
    
    return self;
}


- (void)dealloc {
    self.labelText = nil;
    self.valueText = nil;
    self.popUpButton = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpSubviews];
    [self updateValueTextFromPopUpSelection];
}


#pragma mark -
#pragma mark NSResponder

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


#pragma mark -
#pragma mark NSView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = [self bounds];
    
#if DEBUG_DRAW
    [[NSColor redColor] setFill];
    NSRectFill(bounds);
#endif
    
    if (_labelText) {
        NSRect labelRect = [self labelTextRectForBounds:bounds];
        [_labelText drawInRect:labelRect withAttributes:[[self class] defaultLabelTextAttributes]];
    }
    
    if (_valueText) {
        NSRect valueRect = [self valueTextRectForBounds:bounds];
        [_valueText drawInRect:valueRect withAttributes:[[self class] defaultValueTextAttributes]];
    }
    
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


#pragma mark -
#pragma mark Metrics

- (NSRect)labelTextRectForBounds:(NSRect)bounds {
    CGFloat x = LABEL_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _labelTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(bounds.size.width - LABEL_MARGIN_X * 2.0);
    CGFloat h = _labelTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (NSRect)valueTextRectForBounds:(NSRect)bounds {
    CGFloat x = VALUE_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _valueTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(bounds.size.width - VALUE_MARGIN_X * 2.0);
    CGFloat h = _valueTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
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


#pragma mark -
#pragma mark NSMenuDelegate

- (void)menuDidClose:(NSMenu *)menu {
    [self updateValueTextFromPopUpSelection];
}


#pragma mark -
#pragma mark Private

- (void)setUpSubviews {
    NSColor *topColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    NSColor *botColor = [NSColor colorWithDeviceWhite:0.65 alpha:1.0];
    self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    
    topColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
    botColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    
    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    
    [_popUpButton setHidden:YES];
    
    NSMenu *menu = [_popUpButton menu];
    [menu setFont:[NSFont systemFontOfSize:9.0]];
    [menu setDelegate:self];
}


- (void)updateValueTextFromPopUpSelection {
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        [_popUpButton synchronizeTitleAndSelectedItem];
        self.valueText = [_popUpButton titleOfSelectedItem];
    });
}


#pragma mark -
#pragma mark Properties

- (void)setLabelText:(NSString *)s {
    if (s != _labelText) {
        [_labelText release];
        _labelText = [s retain];
        
        self.labelTextSize = [self.labelText sizeWithAttributes:[[self class] defaultLabelTextAttributes]];
        
        [self setNeedsDisplay:YES];
    }
}


- (void)setValueText:(NSString *)s {
    if (s != _valueText) {
        [_valueText release];
        _valueText = [s retain];
        
        self.valueTextSize = [self.valueText sizeWithAttributes:[[self class] defaultValueTextAttributes]];
        
        [self setNeedsDisplay:YES];
    }
}

@end




