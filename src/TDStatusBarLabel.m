//
//  TDStatusBarLabel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarLabel.h>
#import <TDAppKit/TDUtils.h>

#define DEBUG_DRAW 0

#define TEXT_MARGIN_X 3.0

static NSDictionary *sTextAttrs = nil;

@interface TDStatusBarLabel ()
@property (nonatomic, assign) NSSize textSize;
@end

@implementation TDStatusBarLabel

+ (void)initialize {
    if ([TDStatusBarLabel class] == self) {        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSRightTextAlignment];
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

    }
    
    return self;
}


- (void)dealloc {
    self.text = nil;
    [super dealloc];
}


//- (void)awakeFromNib {
//    [super awakeFromNib];
//    
//}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSRect bounds = [self bounds];

#if DEBUG_DRAW
    [[NSColor redColor] setFill];
    NSRectFill(bounds);
#endif
    
    if (_text) {
        NSRect textRect = [self textRectForBounds:bounds];
        [_text drawInRect:textRect withAttributes:[[self class] defaultTextAttributes]];
    }
}


//- (void)layoutSubviews {
//    [super layoutSubviews];
//}
//

- (NSRect)textRectForBounds:(NSRect)bounds {
    CGFloat x = TEXT_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _textSize.height / 2.0);
    CGFloat w = TDRoundAlign(bounds.size.width - TEXT_MARGIN_X * 2.0);
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
        
        self.textSize = [self.text sizeWithAttributes:[[self class] defaultTextAttributes]];

        [self setNeedsDisplay:YES];
    }
}

@end
