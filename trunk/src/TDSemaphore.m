//
//  TDSemaphore.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDSemaphore.h"

@interface TDSemaphore ()
- (void)lock;
- (void)unlock;

- (void)decrement;
- (void)increment;

- (BOOL)available;
- (void)signal;

- (BOOL)isValidDate:(NSDate *)limit;

@property (assign) NSInteger value;
@property (retain) NSCondition *condition;
@end

@implementation TDSemaphore

- (id)initWithValue:(NSInteger)value {
    self = [super init];
    if (self) {
        self.value = value;
        self.condition = [[[NSCondition alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.condition = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (BOOL)attempt {
    [self lock];
    
    BOOL success = [self available];
    
    if (success) {
        [self decrement];
    }
    
    [self unlock];

    return success;
}


- (BOOL)attemptBeforeDate:(NSDate *)limit {
    [self lock];
    
    while ([self isValidDate:limit] && ![self available]) {
        [_condition waitUntilDate:limit];
    }
    
    BOOL success = [self available];
    
    if (success) {
        [self decrement];
    }

    [self unlock];
    
    return success;
}


- (void)take {
    [self lock];
    
    while (![self available]) {
        [_condition wait];
    }
    
    [self decrement];
    [self unlock];
}


- (void)put {
    [self lock];
    [self increment];

    if ([self available]) {
        [self signal];
    }
    
    [self unlock];
}


#pragma mark -
#pragma mark Private

- (void)lock {
    [_condition lock];
}


- (void)unlock {
    [_condition unlock];
}


- (void)decrement {
    self.value--;
}


- (void)increment {
    self.value++;
}


- (BOOL)available {
    return _value > 0;
}


- (void)wait {
    [_condition wait];
}


- (void)signal {
    [_condition signal];
}


- (BOOL)isValidDate:(NSDate *)limit {
    return [limit timeIntervalSinceNow] > 0.0;
}

@end
