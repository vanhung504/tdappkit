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
@property (nonatomic, copy) NSString *commandString;
@property (nonatomic, retain, readwrite) NSFileHandle *tty;
@property (nonatomic, assign) BOOL hasRun;
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
    self.tty = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

- (NSError *)errorWithFormat:(NSString *)fmt, ... {
    NSAssert([fmt length], @"");
    
    va_list vargs;
    va_start(vargs, fmt);
    NSString *msg = [[[NSString alloc] initWithFormat:fmt arguments:vargs] autorelease];
    va_end(vargs);
    
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: msg};
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:-1 userInfo:userInfo];
}


- (const char **)getArgumentsAndExePath:(const char **)outExePath {
    NSAssert([_commandString length], @"");
    
    NSArray *args = [_commandString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSUInteger argc = [args count];
    NSAssert(argc > 1, @"");
    
    NSString *exePath = args[0];
    NSString *exeName = [exePath lastPathComponent];
    
    const char **argv = malloc(argc+1 * sizeof(char *)); // +1 for NULL terminator
    argv[0] = [exeName UTF8String];
    
    NSUInteger i = 1;
    for (NSString *arg in [args subarrayWithRange:NSMakeRange(1, argc-1)]) {
        NSAssert([arg isKindOfClass:[NSString class]], @"");
        arg = [arg stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""]];
        argv[i++] = [arg UTF8String];
    }
    argv[i] = NULL;
    
    if (outExePath) *outExePath = [exePath UTF8String];

    return argv;
}


#pragma mark -
#pragma mark Public

- (pid_t)spawnWithError:(NSError **)outErr {
    NSAssert(!_hasRun, @"");
    NSAssert([_commandString length], @"");
    NSAssert(!_tty, @"");
    
    pid_t pid = -1;
    
    // programmer error.
    if (_hasRun) {
        [NSException raise:@"NSException" format:@"each %@ object is one-shot. this one has already run. you should create a new one for running instead of reusing this one.", NSStringFromClass([self class])];
        return pid;
    }
    
    self.hasRun = YES;
    
    // parse exec args. yes, do this in the parent, cuz using Cocoa in the child after-fork/before-exec is scary.
    const char *exePath;
    const char **argv = [self getArgumentsAndExePath:&exePath];
    if (!argv) {
        [NSException raise:@"NSException" format:@"invalid comand string"];
        return pid;
    }
    
    // fork pseudo terminal
    int master;
    pid = forkpty(&master, NULL, NULL, NULL);
    
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
            printf("error while execing command string: `%s`\n%s\n", [_commandString UTF8String], strerror(errno));
        }
        assert(0); // should not reach
    }
    
    if (argv) free(argv);
    return pid;
}

@end
