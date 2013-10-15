//
//  TDCoprocess.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/15/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDCoprocess.h"

static void sig_pipe(int signo) {
    NSLog(@"SIGPIPE Caught!");
    exit(1);
}

@interface TDCoprocess ()
@property (nonatomic, copy) NSString *commandString;
@property (nonatomic, retain) NSPipe *childStdinPipe;
@property (nonatomic, retain) NSPipe *childStdoutPipe;
@end

@implementation TDCoprocess

+ (instancetype)coprocessWithCommandString:(NSString *)cmdString {
    return [[[TDCoprocess alloc] initWithCommandString:cmdString] autorelease];
}


- (instancetype)initWithCommandString:(NSString *)cmdString {
    self = [super init];
    if (self) {
        self.commandString = cmdString;
    }
    return self;
}


- (void)dealloc {
    self.commandString = nil;
    self.childStdinPipe = nil;
    self.childStdoutPipe = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (NSFileHandle *)fileHandleForReading {
    TDAssert(_childStdoutPipe);
    return [_childStdoutPipe fileHandleForReading];
}


- (NSFileHandle *)fileHandleForWriting {
    TDAssert(_childStdinPipe);
    return [_childStdinPipe fileHandleForReading];
    
}


#pragma mark -
#pragma mark Private

- (NSError *)errorWithFormat:(NSString *)fmt, ... {
    TDAssert([fmt length]);
    
    va_list vargs;
    va_start(vargs, fmt);
    NSString *msg = [[[NSString alloc] initWithFormat:fmt arguments:vargs] autorelease];
    va_end(vargs);
    
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: msg};
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:-1 userInfo:userInfo];
}


- (BOOL)forkAndExecWithError:(NSError **)outErr {
    TDAssert([_commandString length]);
    TDAssert(!_childStdinPipe);
    TDAssert(!_childStdoutPipe);
    
    if (signal(SIGPIPE, sig_pipe) < 0) {
        if (outErr) *outErr = [self errorWithFormat:@"could not set SIGPIE handler"];
        return NO;
    }
    
    self.childStdinPipe = [NSPipe pipe];
    self.childStdoutPipe = [NSPipe pipe];
    
    pid_t pid;
    
    if ((pid = fork()) < 0) {
        if (outErr) *outErr = [self errorWithFormat:@"could not fork coprocess"];
        return NO;
    }
    
    // parent
    else if (pid > 0) {
        // close unused file descs
        [[_childStdinPipe fileHandleForReading] closeFile];
        [[_childStdoutPipe fileHandleForWriting] closeFile];
        
    }
    
    // child
    else {
        TDAssert(0 == pid);
        // close unused file descs
        [[_childStdinPipe fileHandleForWriting] closeFile];
        [[_childStdoutPipe fileHandleForReading] closeFile];

        // attach pipe to stdin
        NSFileHandle *childStdinHandle = [_childStdinPipe fileHandleForReading];
        if ([childStdinHandle fileDescriptor] != STDIN_FILENO) {
            if (dup2([childStdinHandle fileDescriptor], STDIN_FILENO)) {
                NSLog(@"error while attching pipe to child stdin");
            }
            [childStdinHandle closeFile];
        }
        
        // attach pipe to stdout
        NSFileHandle *childStdoutHandle = [_childStdoutPipe fileHandleForWriting];
        if ([childStdoutHandle fileDescriptor] != STDOUT_FILENO) {
            if (dup2([childStdoutHandle fileDescriptor], STDOUT_FILENO)) {
                NSLog(@"error while attching pipe to child stdout");
            }
            [childStdoutHandle closeFile];
        }
        
        // exec
        if (execl([_commandString UTF8String], [[_commandString lastPathComponent] UTF8String], (char *)0)) {
            NSLog(@"error while attching exec'ing command string: `%@`", _commandString);
        }
    }

    return YES;
}

@end
