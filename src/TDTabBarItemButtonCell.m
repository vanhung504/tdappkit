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

#import "TDTabBarItemButtonCell.h"
#import <TDAppKit/TDTabBarItem.h>

#define MIN_WIDTH 40
#define TITLE_OFFSET_X 2
#define TITLE_OFFSET_Y 1
#define IMAGE_OFFSET_Y 4

static NSShadow *sTitleShadow = nil;

@interface TDTabBarItemButtonCell ()
- (void)commonInit;
@end

@implementation TDTabBarItemButtonCell

+ (void)initialize {
    if ([TDTabBarItemButtonCell class] == self) {
        
        sTitleShadow = [[NSShadow alloc] init];
        [sTitleShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
        [sTitleShadow setShadowOffset:NSMakeSize(0, 1)];
        [sTitleShadow setShadowBlurRadius:0];
        
    }
}


- (id)initTextCell:(NSString *)s {
    if (self = [super initTextCell:s]) {
        [self commonInit];
    }
    return self;
}


- (id)initImageCell:(NSImage *)i {
    if (self = [super initImageCell:i]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    [self setImagePosition:NSImageAbove];
}


- (void)dealloc {
    [super dealloc];
}


- (BOOL)isOpaque {
    return YES;
}


- (void)drawWithFrame:(NSRect)r inView:(NSView *)cv {
    [self drawInteriorWithFrame:r inView:cv];
}


//- (void)drawInteriorWithFrame:(NSRect)r inView:(NSView *)cv { 
//    //TDTabBarItemButton *b = (TDTabBarItemButton *)cv;
//    //TDTabBarItem *item = b.item;
//    
//    // if below the min width, just clear and return (dont draw borked background image)
//    if (r.size.width < MIN_WIDTH) {
//        return;
//    }    
//    
//    NSDrawThreePartImage(r, TDIMG(@"tabbar_bg"), TDIMG(@"tabbar_bg"), TDIMG(@"tabbar_bg"), NO, NSCompositeSourceOver, 1, YES);
//    
//    // draw bg image
//    if (NSOnState == [self state]) {
//        NSImage *leftImage = TDIMG(@"tabbar_button_bg_hi_01");
//        NSImage *centerImage = TDIMG(@"tabbar_button_bg_hi_02");
//        NSImage *rightImage = TDIMG(@"tabbar_button_bg_hi_03");
//        
//        [leftImage setFlipped:[cv isFlipped]];
//        [centerImage setFlipped:[cv isFlipped]];
//        [rightImage setFlipped:[cv isFlipped]];
//        
//        NSDrawThreePartImage(r, leftImage, centerImage, rightImage, NO, NSCompositeSourceOver, 1, NO);
//    }
//    
//    // draw image
//    if ([self imagePosition] != NSNoImage) {
//        NSImage *img = nil;
//        if (NSOnState == [self state]) {
//            img = [self alternateImage];
//        } else {
//            img = [self image];
//        }
//        
//        [img setFlipped:[cv isFlipped]];
//        
//        NSSize size = [img size];
//        NSPoint p = NSMakePoint(r.origin.x + round((r.size.width - size.width) / 2.0) + TITLE_OFFSET_X, IMAGE_OFFSET_Y);
//        
//        [img drawAtPoint:p fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositeSourceOver fraction:1];
//    }
//    
//    // draw title
//    if ([self imagePosition] != NSImageOnly) {
//        NSString *title = [self title];
//        if ([title length]) {
//            NSColor *color = nil;
//            if ([self isEnabled]) {
//                if (NSOnState == [self state]) {
//                    color = [NSColor whiteColor];
//                } else {
//                    color = [NSColor colorWithCalibratedWhite:1.0 alpha:0.6];
//                }
//            } else {
//                color = [NSColor colorWithCalibratedWhite:1.0 alpha:0.4];
//            }
//            
//            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                        [self font], NSFontAttributeName, 
//                                        color, NSForegroundColorAttributeName, 
//                                        sTitleShadow, NSShadowAttributeName, 
//                                        nil];
//            
//            NSSize size = [title sizeWithAttributes:attributes];
//            
////            NSPoint p = NSMakePoint(r.origin.x + round((r.size.width - size.width) / 2.0) + TITLE_OFFSET_X,
////                                    r.size.height - size.height - TITLE_OFFSET_Y);
////            
////            [title drawAtPoint:p withAttributes:attributes];
//
//            NSRect d = NSMakeRect(r.origin.x + round((r.size.width - size.width) / 2.0) + TITLE_OFFSET_X,
//                                  r.size.height - size.height - TITLE_OFFSET_Y,
//                                  r.size.width - TITLE_OFFSET_X * 2, size.height);
//            
//            [title drawWithRect:d options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attributes];
//        }
//    }
//}

@end
