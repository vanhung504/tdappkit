//
//  TDTabListItemStyle.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/3/12.
//  Copyright (c) 2012 Celestial Teapot Software. All rights reserved.
//

#import "TDTabListItemStyle.h"

@implementation TDTabListItemStyle

+ (NSFont *)titleFont {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


- (CGRect)tabListItem:(TDTabListItem *)item borderRectForBounds:(CGRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return CGRectZero;
}


- (CGRect)tabListItem:(TDTabListItem *)item titleRectForBounds:(CGRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return CGRectZero;
}


- (CGRect)tabListItem:(TDTabListItem *)item closeButtonRectForBounds:(CGRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return CGRectZero;
}


- (CGRect)tabListItem:(TDTabListItem *)item progressIndicatorRectForBounds:(CGRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return CGRectZero;
}


- (CGRect)tabListItem:(TDTabListItem *)item thumbnailRectForBounds:(CGRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return CGRectZero;
}


- (void)layoutSubviewsInTabListItem:(TDTabListItem *)item {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
}


- (void)drawTabListItem:(TDTabListItem *)item inContext:(CGContextRef)ctx {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
}

@end
