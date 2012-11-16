//
//  TDStatusBarPopUpControl.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarLabel.h>

@interface TDStatusBarPopUpControl : TDStatusBarLabel <NSMenuDelegate>

- (NSRect)popUpButtonRectForBounds:(NSRect)bounds;

@property (nonatomic, retain) IBOutlet NSPopUpButton *popUpButton;
@end
