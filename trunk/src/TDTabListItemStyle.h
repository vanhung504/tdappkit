//
//  TDTabListItemStyle.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/3/12.
//  Copyright (c) 2012 Celestial Teapot Software. All rights reserved.
//

#import <TDAppKit/TDTabListItem.h>

@interface TDTabListItemStyle : NSObject {
    
}

+ (NSFont *)titleFont;

- (CGRect)tabListItem:(TDTabListItem *)item borderRectForBounds:(CGRect)bounds;
- (CGRect)tabListItem:(TDTabListItem *)item titleRectForBounds:(CGRect)bounds;
- (CGRect)tabListItem:(TDTabListItem *)item closeButtonRectForBounds:(CGRect)bounds;
- (CGRect)tabListItem:(TDTabListItem *)item progressIndicatorRectForBounds:(CGRect)bounds;
- (CGRect)tabListItem:(TDTabListItem *)item thumbnailRectForBounds:(CGRect)bounds;

- (void)layoutSubviewsInTabListItem:(TDTabListItem *)item;
- (void)drawTabListItem:(TDTabListItem *)item inContext:(CGContextRef)ctx;
@end
