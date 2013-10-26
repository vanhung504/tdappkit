//
//  TDRunLoopThread.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/25/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDRunLoopThread.h>
#import <TDAppKit/TDUtils.h>

@interface TDRunLoopThread ()
@property (retain) NSThread *thread;
@property (assign) BOOL flag;
@end

@implementation TDRunLoopThread

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)dealloc {
    self.thread = nil;
    [super dealloc];
}


- (void)start {
    NSAssert([NSThread isMainThread], @"");
    
    self.thread = [[[NSThread alloc] initWithTarget:self selector:@selector(_threadMain) object:nil] autorelease];
    [_thread start];
    NSAssert([_thread isExecuting], @"");
    NSAssert(![_thread isFinished], @"");
}


- (void)stop {
    NSAssert([NSThread isMainThread], @"");
    @synchronized(self) {
        self.flag = YES;
    }
}


- (void)_threadMain {
    NSAssert(![NSThread isMainThread], @"");
    NSAssert([NSThread currentThread] == _thread, @"");
    
    @autoreleasepool {
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        NSTimer *dummySrc = [[[NSTimer alloc] initWithFireDate:[NSDate distantFuture]
                                                      interval:0.0
                                                        target:self
                                                      selector:@selector(_threadMain)
                                                      userInfo:nil
                                                       repeats:NO] autorelease];
        [loop addTimer:dummySrc forMode:NSDefaultRunLoopMode];
        
        while ([loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
            @synchronized(self) {
                if (self.flag) {
                    self.flag = NO;
                    break;
                }
            }
        }
    }
}


- (void)_performAsync:(NSArray *)args {
    NSAssert([NSThread isMainThread], @"");
    NSAssert(args, @"");
    NSAssert(_thread, @"");
    NSAssert([_thread isExecuting], @"");
    NSAssert(![_thread isFinished], @"");
    [self performSelector:@selector(_async:) onThread:_thread withObject:args waitUntilDone:NO];
}


- (void)_performSync:(NSArray *)args {
    NSAssert([NSThread isMainThread], @"");
    NSAssert(args, @"");
    NSAssert(_thread, @"");
    NSAssert([_thread isExecuting], @"");
    NSAssert(![_thread isFinished], @"");
    [self performSelector:@selector(_sync:) onThread:_thread withObject:args waitUntilDone:YES];
}


- (void)_async:(NSArray *)args {
    NSAssert([NSThread currentThread] == _thread, @"");
    NSAssert(![NSThread isMainThread], @"");
    
    NSUInteger c = [args count];
    NSAssert(1 == c || 2 == c, @"");
    TDRunBlock block = args[0];
    
    NSError *err = nil;
    id result = block(&err);
    //NSLog(@"%@", result);
    
    TDCompletionBlock completion = nil;
    if (2 == c) {
        completion = args[1];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result, err);
        });
    }
}


- (void)_sync:(NSArray *)args {
    NSAssert([NSThread currentThread] == _thread, @"");
    NSAssert(![NSThread isMainThread], @"");
    NSAssert(1 == [args count], @"");
    TDBlock block = args[0];
    
    block();
}


- (void)performAsync:(TDBlock)block {
    NSAssert([NSThread isMainThread], @"");
    NSParameterAssert(block);
    NSAssert(_thread, @"");
    NSAssert([_thread isExecuting], @"");
    NSAssert(![_thread isFinished], @"");

    NSArray *args = @[[[block copy] autorelease]];
    [self _performAsync:args];
}


- (void)performAsync:(TDRunBlock)block completion:(TDCompletionBlock)completion {
    NSAssert([NSThread isMainThread], @"");
    NSParameterAssert(block);
    NSParameterAssert(completion);
    NSAssert(_thread, @"");
    NSAssert([_thread isExecuting], @"");
    NSAssert(![_thread isFinished], @"");

    NSArray *args = @[[[block copy] autorelease], [[completion copy] autorelease]];
    [self _performAsync:args];
}


- (void)performSync:(TDBlock)block {
    NSAssert([NSThread isMainThread], @"");
    NSParameterAssert(block);
    NSAssert(_thread, @"");
    NSAssert([_thread isExecuting], @"");
    NSAssert(![_thread isFinished], @"");

    NSArray *args = @[[[block copy] autorelease]];
    [self _performSync:args];
}

@end
