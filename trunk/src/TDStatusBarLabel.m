//
//  TDStatusBarLabel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import "TDStatusBarLabel.h"

#define TDAlign(x) (round((x)) + 0.0)

#define TEXT_MARGIN_X 3.0

static NSStringDrawingOptions sTextOpts = 0;
static NSDictionary *sTextAttrs = nil;

@interface TDStatusBarLabel ()
@property (nonatomic, assign) NSSize textSize;
@end

@implementation TDStatusBarLabel

+ (void)initialize {
    if ([TDStatusBarLabel class] == self) {        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSCenterTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.2]];
        [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [shadow setShadowBlurRadius:1.0];
        
        sTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSFont boldSystemFontOfSize:12.0], NSFontAttributeName,
                      [NSColor whiteColor], NSForegroundColorAttributeName,
                      shadow, NSShadowAttributeName,
                      paraStyle, NSParagraphStyleAttributeName,
                      nil];
    }
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}


- (void)dealloc {
    self.text = nil;
    [super dealloc];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    
}


- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    
    [[NSColor redColor] setFill];
    NSRectFill(bounds);
    
    [[NSColor blackColor] setStroke];
    
    NSPoint topLef = NSMakePoint(NSMinX(bounds), NSMinY(bounds));
    NSPoint botLef = NSMakePoint(NSMinX(bounds), NSMaxY(bounds));
    [NSBezierPath strokeLineFromPoint:topLef toPoint:botLef];

    NSPoint topRit = NSMakePoint(NSMaxX(bounds), NSMinY(bounds));
    NSPoint botRit = NSMakePoint(NSMaxX(bounds), NSMaxY(bounds));
    [NSBezierPath strokeLineFromPoint:topRit toPoint:botRit];
    
    if (_text) {
        NSRect textRect = [self textRectForBounds:bounds];
        [_text drawWithRect:textRect options:sTextOpts attributes:sTextAttrs];
    }
}


//- (void)layoutSubviews {
//    [super layoutSubviews];
//}
//

- (NSRect)textRectForBounds:(NSRect)bounds {
    CGFloat x = TEXT_MARGIN_X;
    CGFloat y = TDAlign(NSMidY(bounds) - _textSize.height / 2.0);
    CGFloat w = TDAlign(bounds.size.width - TEXT_MARGIN_X * 2.0);
    CGFloat h = _textSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


#pragma mark -
#pragma mark Properties

- (void)setText:(NSString *)s {
    if (s != _text) {
        [_text release];
        _text = [s retain];
        
        self.textSize = [self.text sizeWithAttributes:sTextAttrs];

        [self setNeedsDisplay:YES];
    }
}
@end
