//
//  TDStatusBarPopUpControl.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarPopUpView.h>
#import <TDAppKit/TDUtils.h>

#define D2R(d) (M_PI * (d) / 180.0)

#define DEBUG_DRAW 0

#define LABEL_MARGIN_X 8.0
#define VALUE_MARGIN_X 3.0
#define POPUP_MARGIN_X 3.0
#define MENU_OFFSET_Y 1.0
#define ARROWS_MARGIN_X 3.0
#define ARROWS_MARGIN_Y 1.0

static NSDictionary *sLabelTextAttrs = nil;
static NSDictionary *sValueTextAttrs = nil;

@interface TDStatusBarPopUpView ()
- (void)setUpSubviews;
- (void)updateValueTextFromPopUpSelection;
- (void)updateGradientsForMenuVisible;
- (void)drawArrowsInRect:(NSRect)arrowsRect dirtyRect:(NSRect)dirtyRect;
@property (nonatomic, assign) NSSize labelTextSize;
@property (nonatomic, assign) NSSize valueTextSize;
@property (nonatomic, assign) BOOL menuVisible;
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
        self.labelTextSize = CGSizeZero;
        self.valueTextSize = CGSizeZero;
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
    self.menuVisible = YES;
    
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        NSFont *font = [[[self class] defaultValueTextAttributes] objectForKey:NSFontAttributeName];
        [menu setFont:font];
        NSInteger idx = [_popUpButton indexOfSelectedItem];
        NSMenuItem *item = [menu itemAtIndex:idx];
        
        NSSize menuSize = [menu size];
        NSRect bounds = [self bounds];
        NSRect valueRect = [self valueTextRectForBounds:bounds];
        
        NSPoint p = NSMakePoint(floor(NSMidX(valueRect) - menuSize.width / 2.0) - 0.5, NSMaxY(valueRect) - MENU_OFFSET_Y);
        [menu popUpMenuPositioningItem:item atLocation:p inView:self];

    });
}


#pragma mark -
#pragma mark NSView

- (BOOL)isFlipped {
    return NO;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = [self bounds];
    
    if (_labelText) {
        NSRect labelRect = [self labelTextRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor redColor] setFill];
        NSRectFill(labelRect);
#endif
        [_labelText drawInRect:labelRect withAttributes:[[self class] defaultLabelTextAttributes]];
    }
    
    if (_valueText) {
        NSRect valueRect = [self valueTextRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor greenColor] setFill];
        NSRectFill(valueRect);
#endif
        [_valueText drawInRect:valueRect withAttributes:[[self class] defaultValueTextAttributes]];
        
        NSRect arrowsRect = [self arrowsRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor whiteColor] setFill];
        NSRectFill(arrowsRect);
#endif
        [self drawArrowsInRect:arrowsRect dirtyRect:dirtyRect];
    }
    
    BOOL isMain = [[self window] isMainWindow];
    NSColor *strokeColor = nil;
    if (isMain) {
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


- (void)drawArrowsInRect:(NSRect)arrowsRect dirtyRect:(NSRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    NSPoint arrowsMidPoint = NSMakePoint(NSMidX(arrowsRect), NSMidY(arrowsRect));
    
    // begin
    CGContextSaveGState(ctx);

    [[NSColor colorWithDeviceWhite:0.2 alpha:1.0] setFill];
    
    // translate to center of arrows rect
    CGContextTranslateCTM(ctx, arrowsMidPoint.x, arrowsMidPoint.y);
    
    // draw top arrow path
    CGContextSaveGState(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, TDFloorAlign(-(NSWidth(arrowsRect) / 2.0)), (1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(NSWidth(arrowsRect) / 2.0), (1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(0.0), ((NSHeight(arrowsRect) / 2.0)));
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);

    // draw bottom arrow path
    CGContextSaveGState(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, TDFloorAlign(-(NSWidth(arrowsRect) / 2.0)), (-1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(NSWidth(arrowsRect) / 2.0), (-1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(0.0), (-(NSHeight(arrowsRect) / 2.0)));
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);

    // done
    CGContextRestoreGState(ctx);
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
    CGFloat w = TDRoundAlign(_labelTextSize.width);
    CGFloat h = _labelTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (NSRect)valueTextRectForBounds:(NSRect)bounds {
    CGRect labelRect = [self labelTextRectForBounds:bounds];
    BOOL hasLabelText = [_labelText length] > 0;
    CGFloat marginX = hasLabelText ? VALUE_MARGIN_X : 0.0;
    
    CGFloat x = TDRoundAlign(CGRectGetMaxX(labelRect) + marginX);
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _valueTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(_valueTextSize.width);
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


- (NSRect)arrowsRectForBounds:(NSRect)bounds {
    CGRect valueRect = [self valueTextRectForBounds:bounds];
    
    CGFloat h = [[[[self class] defaultValueTextAttributes] objectForKey:NSFontAttributeName] pointSize];

    CGFloat x = TDRoundAlign(CGRectGetMaxX(valueRect) + ARROWS_MARGIN_X);
    CGFloat y = valueRect.origin.y + ARROWS_MARGIN_Y;
    CGFloat w = round(0.66 * h);
    
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
    [self updateGradientsForMenuVisible];

    NSColor *topColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
    NSColor *botColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];

    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    
    [_popUpButton setHidden:YES];
    
    NSMenu *menu = [_popUpButton menu];
    [menu setFont:[NSFont systemFontOfSize:9.0]];
    [menu setDelegate:self];
}


- (void)updateGradientsForMenuVisible {
    NSColor *topColor = nil;
    NSColor *botColor = nil;
    
    if (_menuVisible) {
        topColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
        botColor = [NSColor colorWithDeviceWhite:0.55 alpha:1.0];
    } else {
        topColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
        botColor = [NSColor colorWithDeviceWhite:0.65 alpha:1.0];
    }

    self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];

    [self setNeedsDisplay:YES];
}


- (void)updateValueTextFromPopUpSelection {
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        [_popUpButton synchronizeTitleAndSelectedItem];
        self.valueText = [_popUpButton titleOfSelectedItem];
        self.menuVisible = NO;
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


- (void)setMenuVisible:(BOOL)yn {
    if (yn != _menuVisible) {
        _menuVisible = yn;
        
        [self updateGradientsForMenuVisible];
    }
}

@end
