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
    TDAssertMainThread();
    
    self.thread = [[[NSThread alloc] initWithTarget:self selector:@selector(_threadMain) object:nil] autorelease];
    [_thread start];
    TDAssert([_thread isExecuting]);
    TDAssert(![_thread isFinished]);
}


- (void)stop {
    TDAssertMainThread();
    @synchronized(self) {
        self.flag = YES;
    }
}


- (void)_threadMain {
    TDAssertNotMainThread();
    TDAssert([NSThread currentThread] == _thread);
    
    @autoreleasepool {
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [loop addPort:[NSPort port] forMode:NSDefaultRunLoopMode]; // ??
        
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
    TDAssertMainThread();
    TDAssert(args);
    TDAssert(_thread);
    TDAssert([_thread isExecuting]);
    TDAssert(![_thread isFinished]);
    [self performSelector:@selector(_async:) onThread:_thread withObject:args waitUntilDone:NO];
}


- (void)_performSync:(NSArray *)args {
    TDAssertMainThread();
    TDAssert(args);
    TDAssert(_thread);
    TDAssert([_thread isExecuting]);
    TDAssert(![_thread isFinished]);
    [self performSelector:@selector(_sync:) onThread:_thread withObject:args waitUntilDone:YES];
}


- (void)_async:(NSArray *)args {
    TDAssert([NSThread currentThread] == _thread);
    TDAssertNotMainThread();
    
    NSUInteger c = [args count];
    TDAssert(1 == c || 2 == c);
    TDRunBlock block = args[0];
    
    NSError *err = nil;
    id result = block(&err);
    //NSLog(@"%@", result);
    
    TDCompletionBlock completion = nil;
    if (2 == c) {
        completion = args[1];
        TDPerformOnMainThread(^{
            completion(result, err);
        });
    }
}


- (void)_sync:(NSArray *)args {
    assert([NSThread currentThread] == _thread);
    TDAssertNotMainThread();
    TDAssert(1 == [args count]);
    TDBlock block = args[0];
    
    block();
}


- (void)performAsync:(TDBlock)block {
    TDAssertMainThread();
    NSParameterAssert(block);
    TDAssert(_thread);
    TDAssert([_thread isExecuting]);
    TDAssert(![_thread isFinished]);

    NSArray *args = @[[[block copy] autorelease]];
    [self _performAsync:args];
}


- (void)performAsync:(TDRunBlock)block completion:(TDCompletionBlock)completion {
    TDAssertMainThread();
    NSParameterAssert(block);
    NSParameterAssert(completion);
    TDAssert(_thread);
    TDAssert([_thread isExecuting]);
    TDAssert(![_thread isFinished]);

    NSArray *args = @[[[block copy] autorelease], [[completion copy] autorelease]];
    [self _performAsync:args];
}


- (void)performSync:(TDBlock)block {
    TDAssertMainThread();
    NSParameterAssert(block);
    TDAssert(_thread);
    TDAssert([_thread isExecuting]);
    TDAssert(![_thread isFinished]);

    NSArray *args = @[[[block copy] autorelease]];
    [self _performSync:args];
}

@end
