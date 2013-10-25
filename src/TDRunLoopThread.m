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
@property (nonatomic, retain) NSThread *thread;

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
    
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(_threadMain) object:nil];
    [_thread start];
}


- (void)_threadMain {
    assert([NSThread currentThread] == _thread);
    
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    while ([loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        
    }
}


- (void)_runOnThread:(NSArray *)args {
    TDAssertMainThread();
    TDAssert(args);
    TDAssert(_thread);
    [self performSelector:@selector(_run:) onThread:_thread withObject:args waitUntilDone:NO];
}


- (void)_executeOnThread:(NSArray *)args waitUntilDone:(BOOL)wait {
    TDAssertMainThread();
    TDAssert(args);
    TDAssert(_thread);
    [self performSelector:@selector(_execute:) onThread:_thread withObject:args waitUntilDone:wait];
}


- (void)_run:(NSArray *)args {
    TDAssert([NSThread currentThread] == _thread);
    TDAssertNotMainThread();
    TDAssert(2 == [args count]);
    TDRunBlock block = args[0];
    TDCompletionBlock completion = args[1];
    
    NSError *err = nil;
    id result = block(&err);
    //NSLog(@"%@", result);
    
    TDPerformOnMainThread(^{
        completion(result, err);
    });
}


- (void)_execute:(NSArray *)args {
    assert([NSThread currentThread] == _thread);
    TDAssertNotMainThread();
    TDAssert(1 == [args count]);
    TDBlock block = args[0];
    
    block();
}


- (void)runOnThread:(TDRunBlock)block completion:(TDCompletionBlock)completion {
    TDAssertMainThread();
    NSParameterAssert(block);
    NSParameterAssert(completion);
    TDAssert(_thread);
    
    NSArray *args = @[[[block copy] autorelease], [[completion copy] autorelease]];
    [self _runOnThread:args];
}


- (void)executeOnThread:(TDBlock)block {
    [self executeOnThread:block waitUntilDone:NO];
}


- (void)executeOnThread:(TDBlock)block waitUntilDone:(BOOL)wait {
    TDAssertMainThread();
    NSParameterAssert(block);
    TDAssert(_thread);
    
    NSArray *args = @[[[block copy] autorelease]];
    [self _executeOnThread:args waitUntilDone:wait];
}

@end
