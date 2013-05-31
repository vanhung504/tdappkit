//
//  TDSemaphore.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSemaphore : NSObject

- (id)initWithValue:(NSInteger)value;

- (BOOL)attempt;
- (void)take;
- (void)put;
@end
