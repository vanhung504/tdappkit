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

- (BOOL)attempt; // returns success
- (BOOL)attemptBeforeDate:(NSDate *)limit; // returns success. can block up to limit
- (void)take; // blocks forever
- (void)put; // can block briefly, but never for long. essentially returns immediately.
@end
