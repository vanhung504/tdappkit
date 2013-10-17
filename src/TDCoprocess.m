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
@property (nonatomic, assign) BOOL hasRun;
@end

@implementation TDCoprocess

+ (instancetype)coprocessWithCommandString:(NSString *)cmdString {
    return [[[TDCoprocess alloc] initWithCommandString:cmdString] autorelease];
}


- (id)init {
    TDAssert(0);
    return nil;
}


- (instancetype)initWithCommandString:(NSString *)cmdString {
    self = [super init];
    if (self) {
        NSArray *comps = [cmdString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSUInteger c = [comps count];
        TDAssert(c > 0 && NSNotFound != c);
        
        self.exePath = comps[0];
        NSString *exeName = [_exePath lastPathComponent];
        
        if (c > 1) {
            NSMutableArray *margs = [NSMutableArray arrayWithArray:[comps subarrayWithRange:NSMakeRange(1, c-1)]]; // trim exePath
            [margs insertObject:exeName atIndex:0]; // insert exeName
            self.args = [[margs copy] autorelease];
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
    NSAssert([fmt length], @"");
    
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
    NSAssert(!_hasRun, @"");
    NSAssert([_exePath length], @"");
    NSAssert(!_tty, @"");
    
    pid_t pid = -1;
    
    // programmer error.
    if (_hasRun) {
        [NSException raise:@"NSException" format:@"each %@ object is one-shot. this one has already run. you should create a new one for running instead of reusing this one.", NSStringFromClass([self class])];
        return pid;
    }
    
    self.hasRun = YES;
    
    // parse exec args. yes, do this in the parent, cuz doing Cocoa (or anything, really) in the child process after-fork/before-exec is scary.
    const char *exePath = [_exePath UTF8String];
    
    NSUInteger argc = [_args count];
    const char *argv[argc+1]; // +1 for NULL terminator
    
    NSCharacterSet *quoteSet = [NSCharacterSet characterSetWithCharactersInString:@"'\""];
    
    NSUInteger i = 0;
    for (NSString *arg in _args) {
        TDAssert([arg isKindOfClass:[NSString class]]);
        argv[i++] = [[arg stringByTrimmingCharactersInSet:quoteSet] UTF8String];
    }
    TDAssert(i == argc);
    argv[i] = NULL; // add NULL terminator
    
//    NSLog(@"%s", exePath);
//    NSLog(@"%s", argv[0]);
//    NSLog(@"%s", argv[1]);
//    NSLog(@"%s", argv[2]);
//    NSLog(@"%s", argv[3]);
    
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
            printf("error while execing : `%s`\n%s\n", exePath, strerror(errno));
        }
        assert(0); // should not reach
    }
    
    return pid;
}

@end
