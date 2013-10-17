//
//  TDCoprocess.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/15/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDCoprocess.h"
#import <util.h>

@interface TDCoprocess ()
@property (nonatomic, retain) NSString *exePath;
@property (nonatomic, retain) NSArray *args;
@property (nonatomic, retain, readwrite) NSFileHandle *tty;
@end

@implementation TDCoprocess

+ (instancetype)coprocessWithCommandString:(NSString *)cmdString {
    return [[[TDCoprocess alloc] initWithCommandString:cmdString] autorelease];
}


- (instancetype)init {
    NSAssert(0, @"use `-initWithCommandString:` instead");
    return nil;
}


- (instancetype)initWithCommandString:(NSString *)cmdString {
    self = [super init];
    if (self) {
        NSArray *comps = [cmdString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSUInteger c = [comps count];
        NSAssert(c > 0 && NSNotFound != c, @"");
        
        self.exePath = comps[0];
        NSString *exeName = [_exePath lastPathComponent];
        
        // parse args
        if (c > 1) {
            NSCharacterSet *quoteSet = [NSCharacterSet characterSetWithCharactersInString:@"'\""];
            NSMutableArray *margs = [NSMutableArray arrayWithCapacity:c];
            
            for (NSUInteger i = 1; i < c; ++i) { // skip exePath at index 0
                NSString *comp = comps[i];
                NSAssert([comp isKindOfClass:[NSString class]], @"");
                
                NSString *arg = [comp stringByTrimmingCharactersInSet:quoteSet]; // trim quotes
                [margs addObject:arg];
            }

            [margs insertObject:exeName atIndex:0]; // insert exeName
            self.args = [[margs copy] autorelease];
            NSAssert([_args count] == c, @"");
        }
    }
    return self;
}


- (void)dealloc {
    self.exePath = nil;
    self.args = nil;
    self.tty = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

- (NSError *)errorWithFormat:(NSString *)fmt, ... {
    NSParameterAssert([fmt length]);
    
    va_list vargs;
    va_start(vargs, fmt);
    NSString *msg = [[[NSString alloc] initWithFormat:fmt arguments:vargs] autorelease];
    va_end(vargs);
    
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: msg};
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:-1 userInfo:userInfo];
}


#pragma mark -
#pragma mark Public

- (pid_t)spawnWithError:(NSError **)outErr {
    NSAssert([_exePath length], @"");
    NSAssert(!_tty, @"");
    
    // parse exec args. yes, do this in the parent, cuz doing Cocoa (or anything, really) in the child process after-fork/before-exec is scary.
    const char *exePath = [_exePath UTF8String];
    
    NSUInteger argc = [_args count];
    const char *argv[argc+1]; // +1 for NULL terminator
    
    NSUInteger i = 0;
    for (NSString *arg in _args) {
        NSAssert([arg isKindOfClass:[NSString class]], @"");
        argv[i++] = [arg UTF8String];
    }
    NSAssert(i == argc, @"");
    argv[i] = NULL; // add NULL terminator
    
    // fork pseudo terminal
    int master;
    pid_t pid = forkpty(&master, NULL, NULL, NULL);
    
    if (pid < 0) {
        if (outErr) *outErr = [self errorWithFormat:@"could not fork coprocess"];
    }
    
    // parent
    else if (pid > 0) {
        self.tty = [[[NSFileHandle alloc] initWithFileDescriptor:master closeOnDealloc:YES] autorelease];
    }
    
    // child
    else {
        assert(0 == pid);
        
        // exec
        if (execv(exePath, (char * const *)argv)) {
            printf("error while execing : `%s`\n%s\n", exePath, strerror(errno));
        }
        assert(0); // should not reach
    }
    
    return pid;
}

@end
