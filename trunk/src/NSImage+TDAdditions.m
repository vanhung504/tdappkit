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

#import <TDAppKit/NSImage+TDAdditions.h>
#import <TDAppKit/TDUtils.h>

@implementation NSImage (TDAdditions)

+ (NSImage *)imageNamed:(NSString *)name inBundleForClass:(Class)cls {
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    NSString *path = [bundle pathForImageResource:name];

    NSImage *image = nil;
    if ([path length]) {
        NSURL *URL = [NSURL fileURLWithPath:path];
        image = [[[NSImage alloc] initWithContentsOfURL:URL] autorelease];
    } 
    
    if (!image) {
        NSLog(@"%s couldnt load image named %@ in bundle %@\npath %@", __PRETTY_FUNCTION__, name, bundle, path);
    }
    
    return image;
}


- (NSImage *)scaledImageOfSize:(NSSize)size {
    return [self scaledImageOfSize:size alpha:1];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha {
    return [self scaledImageOfSize:size alpha:alpha hiRez:YES];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez {
    return [self scaledImageOfSize:size alpha:alpha hiRez:hiRez clip:nil];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez cornerRadius:(CGFloat)radius {
    NSBezierPath *path = TDGetRoundRect(NSMakeRect(0, 0, size.width, size.height), radius, 1);
    return [self scaledImageOfSize:size alpha:alpha hiRez:hiRez clip:path];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez clip:(NSBezierPath *)path {
    NSImage *result = [[[NSImage alloc] initWithSize:size] autorelease];
    [result lockFocus];
    
    // get context
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    
    // store previous state
    BOOL savedAntialias = [currentContext shouldAntialias];
    NSImageInterpolation savedInterpolation = [currentContext imageInterpolation];
    
    // set new state
    [currentContext setShouldAntialias:YES];
    [currentContext setImageInterpolation:hiRez ? NSImageInterpolationHigh : NSImageInterpolationDefault];
    
    // set clip
    [path setClip];
    
    // draw image
    NSSize fromSize = [self size];
    [self drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSMakeRect(0, 0, fromSize.width, fromSize.height) operation:NSCompositeSourceOver fraction:alpha];
    
    // restore state
    [currentContext setShouldAntialias:savedAntialias];
    [currentContext setImageInterpolation:savedInterpolation];
    
    [result unlockFocus];
    return result;
}


- (void)drawStretchableInRect:(NSRect)rect edgeInsets:(TDEdgeInsets)insets operation:(NSCompositingOperation)op fraction:(CGFloat)delta {    
    void (^makeAreas)(NSRect, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *) = ^(NSRect srcRect, NSRect *tl, NSRect *tc, NSRect *tr, NSRect *ml, NSRect *mc, NSRect *mr,     NSRect *bl, NSRect *bc, NSRect *br) {
        CGFloat w = NSWidth(srcRect);
        CGFloat h = NSHeight(srcRect);
        CGFloat cw = (w - insets.left - insets.right);
        CGFloat ch = (h - insets.top - insets.bottom);
        
        CGFloat x0 = NSMinX(srcRect);
        CGFloat x1 = (x0 + insets.left);
        CGFloat x2 = (NSMaxX(srcRect) - insets.right);
        
        CGFloat y0 = NSMinY(srcRect);
        CGFloat y1 = (y0 + insets.bottom);
        CGFloat y2 = (NSMaxY(srcRect) - insets.top);
        
        *tl = NSMakeRect(x0, y2, insets.left, insets.top);
        *tc = NSMakeRect(x1, y2, cw, insets.top);
        *tr = NSMakeRect(x2, y2, insets.right, insets.top);
        
        *ml = NSMakeRect(x0, y1, insets.left, ch);
        *mc = NSMakeRect(x1, y1, cw, ch);
        *mr = NSMakeRect(x2, y1, insets.right, ch);
        
        *bl = NSMakeRect(x0, y0, insets.left, insets.bottom);
        *bc = NSMakeRect(x1, y0, cw, insets.bottom);
        *br = NSMakeRect(x2, y0, insets.right, insets.bottom);
    };
  
    // Source rects
    NSRect srcRect = (NSRect){NSZeroPoint, self.size};
    NSRect srcTopL, srcTopC, srcTopR, srcMidL, srcMidC, srcMidR, srcBotL, srcBotC, srcBotR;
    makeAreas(srcRect, &srcTopL, &srcTopC, &srcTopR, &srcMidL, &srcMidC, &srcMidR, &srcBotL, &srcBotC, &srcBotR);

    // Destinations rects
    NSRect dstTopL, dstTopC, dstTopR, dstMidL, dstMidC, dstMidR, dstBotL, dstBotC, dstBotR;
//    BOOL flipped = [self isFlipped];
//    if (flipped) {
        makeAreas(rect, &dstBotL, &dstBotC, &dstBotR, &dstMidL, &dstMidC, &dstMidR, &dstTopL, &dstTopC, &dstTopR);
//    } else {
//        makeAreas(rect, &dstTopL, &dstTopC, &dstTopR, &dstMidL, &dstMidC, &dstMidR, &dstBotL, &dstBotC, &dstBotR);
//    }

    NSAssert([[NSThread currentThread] isMainThread], @"");
    static NSDictionary *sImageHints = nil;
    if (!sImageHints) {
        sImageHints = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:NSImageInterpolationHigh], NSImageHintInterpolation, nil];
    }
    

    BOOL flipped = YES;
    
    // this is necessary for non-retina devices to always draw the best rep. dunno why. shouldn't have to do this. :(
    NSImageRep *rep = [self bestRepresentationForRect:srcRect context:[NSGraphicsContext currentContext] hints:sImageHints];

    // Draw
    [rep drawInRect:dstTopL fromRect:srcTopL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dstTopC fromRect:srcTopC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dstTopR fromRect:srcTopR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];

    [rep drawInRect:dstMidL fromRect:srcMidL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dstMidC fromRect:srcMidC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dstMidR fromRect:srcMidR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];

    [rep drawInRect:dstBotL fromRect:srcBotL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dstBotC fromRect:srcBotC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dstBotR fromRect:srcBotR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
}

@end
