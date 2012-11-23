//
//  TDStatusBarPopUpControl.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarLabel.h>

@interface TDStatusBarPopUpView : TDBar <NSMenuDelegate>

+ (NSDictionary *)defaultTextAttributes;

- (NSRect)textRectForBounds:(NSRect)bounds;
- (NSRect)popUpButtonRectForBounds:(NSRect)bounds;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) IBOutlet NSPopUpButton *popUpButton;
@end
