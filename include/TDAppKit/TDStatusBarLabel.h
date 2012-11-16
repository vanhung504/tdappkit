//
//  TDStatusBarLabel.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDFlippedView.h>

@interface TDStatusBarLabel : TDFlippedView

- (NSRect)textRectForBounds:(NSRect)bounds;

@property (nonatomic, copy) NSString *text;
@end
