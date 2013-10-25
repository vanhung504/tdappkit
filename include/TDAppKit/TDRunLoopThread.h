//
//  TDRunLoopThread.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/25/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TDBlock)(void);
typedef id (^TDRunBlock)(NSError **outErr);
typedef void (^TDCompletionBlock)(id result, NSError *err);

@interface TDRunLoopThread : NSObject

- (void)start;
- (void)stop;

- (void)runOnThread:(TDRunBlock)block completion:(TDCompletionBlock)completion;

- (void)executeOnThread:(TDBlock)block; // wait=NO
- (void)executeOnThread:(TDBlock)block waitUntilDone:(BOOL)wait;
@end
