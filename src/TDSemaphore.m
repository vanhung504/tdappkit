//
//  TDSemaphore.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDSemaphore.h"

#define TDAssertLocked() NSAssert1(self.locked , @"%s should be called while locked only.", __PRETTY_FUNCTION__);
#define TDAssertNotLocked() NSAssert1(!self.locked , @"%s should not be called while locked.", __PRETTY_FUNCTION__);

@interface TDSemaphore ()
- (void)lock;
- (void)unlock;

- (void)decrement;
- (void)increment;

- (BOOL)available;

- (void)wait;
- (void)signal;

@property (assign) NSInteger value;
@property (retain) NSLock *vlock;
@property (retain) NSCondition *condition;
@property (assign) BOOL locked;
@end

@implementation TDSemaphore

- (id)initWithValue:(NSInteger)value {
    NSParameterAssert(value > -1);
    self = [super init];
    if (self) {
        self.value = value;
        self.vlock = [[[NSLock alloc] init] autorelease];
        self.condition = [[[NSCondition alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.vlock = nil;
    self.condition = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (BOOL)attempt {
    [self lock];
    [self decrement];
    
    BOOL available = [self available];
    
    if (!available) {
        [self increment];
    }
    
    [self unlock];

    return available;
}


- (void)take {
    NSLog(@"%@ taking", [[NSThread currentThread] name]);
    
    [_condition lock];
    
    while (![self attempt]) {
        // race condition here?
        [_condition wait];
    }
    
    [_condition unlock];
}


- (void)put {
    NSLog(@"%@ putting", [[NSThread currentThread] name]);

    [self lock];
    [self increment];
    BOOL available = [self available];
    [self unlock];
    
    if (available) {
        [_condition signal];
    }
}


#pragma mark -
#pragma mark Private

- (void)lock {
    TDAssertNotLocked();
    [_vlock lock];
    self.locked = YES;
}


- (void)unlock {
    TDAssertLocked();
    self.locked = NO;
    [_vlock unlock];
}


- (void)decrement {
    TDAssertLocked();
    self.value--;
}


- (void)increment {
    TDAssertLocked();
    self.value++;
}


- (BOOL)available {
    TDAssertLocked();
    return _value >= 0;
}


- (void)wait {
    TDAssertNotLocked();
    [_condition wait];
}


- (void)signal {
    TDAssertNotLocked();
    [_condition lock];
    [_condition signal];
    [_condition unlock];
}

@end
