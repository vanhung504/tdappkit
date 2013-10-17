//
//  TDCoprocess.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/15/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDCoprocess.h"
#import <util.h>

static void sig_pipe(int signo) {
    NSLog(@"SIGPIPE Caught!");
    exit(1);
}

@interface TDCoprocess ()
@property (nonatomic, copy) NSString *commandString;
@property (nonatomic, retain) NSFileHandle *childReader;
@property (nonatomic, retain) NSFileHandle *childWriter;

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
    printf("in coprocess child dealloc\n"); fflush(stdout);

    self.commandString = nil;

    self.childReader = nil;
    self.childWriter = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public



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


- (void)spawnWithCompletion:(void (^)(int status, NSError *err))completion {
    
}


- (NSFileHandle *)fileHandleForWriting {
    return _childWriter;
}


- (NSFileHandle *)fileHandleForReading {
    return _childReader;
}


- (int)spawnWithError:(NSError **)outErr {
    NSAssert(!_hasRun, @"");
    
    // programmer error.
    if (_hasRun) {
        [NSException raise:@"NSException" format:@"each %@ object is one-shot. this one has already run. you should create a new one for running instead of reusing this one.", NSStringFromClass([self class])];
        return -1;
    }
    
    self.hasRun = YES;
    
    NSLog(@"%@", _commandString);
    
    NSAssert([_commandString length], @"");
    NSAssert(!_childReader, @"");
    NSAssert(!_childWriter, @"");
    
    if (signal(SIGPIPE, sig_pipe) < 0) {
        if (outErr) *outErr = [self errorWithFormat:@"could not set SIGPIE handler: %s", strerror(errno)];
        return -1;
    }

    pid_t pid;
//    pid = fork();
    
    int master[2];
    struct winsize win = {
        .ws_col = 80, .ws_row = 24,
        .ws_xpixel = 480, .ws_ypixel = 192,
    };
    pid = forkpty(master, NULL, NULL, &win);
    
    if (pid < 0) {
        if (outErr) *outErr = [self errorWithFormat:@"could not fork coprocess"];
        return -1;
    }
    
    // parent
    else if (pid > 0) {
        // close unused file descs

        self.childReader = [[[NSFileHandle alloc] initWithFileDescriptor:master[0] closeOnDealloc:NO] autorelease];
        self.childWriter = [[[NSFileHandle alloc] initWithFileDescriptor:master[0] closeOnDealloc:NO] autorelease];
        
        return 0;
        
//        int status;
//        if (waitpid(pid, &status, 0) != pid) {
//            if (outErr) *outErr = [self errorWithFormat:@"waitpid error"];
//            return -1;
//        } else {
//            if (status != 0) {
//                char *errstr = strerror(errno);
//                if (outErr) *outErr = [self errorWithFormat:@"child process exit status: %d: %s", status, errstr];
//            }
//            return status;
//        }
    }
    
    // child
    else {
        @autoreleasepool {
            NSAssert(0 == pid, @"");
            
            printf("in coprocess child 1:\n");
            printf("in coprocess child 5, _commandString: %s\n", [_commandString UTF8String]); //fflush(stdout);
            // exec
            NSArray *args = [_commandString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSUInteger argc = [args count];
            NSAssert(argc > 1, @"");
            printf("in coprocess 6: len: %lu\n", argc); //fflush(stdout);
            
            NSString *exePath = args[0];
            NSString *exeName = [exePath lastPathComponent];
            printf("in coprocess: %s %s\n", [exePath UTF8String], [exeName UTF8String]); //fflush(stdout);
            
            const char *argv[argc+1];
            argv[0] = [exeName UTF8String];
            
            NSUInteger i = 1;
            for (NSString *arg in [args subarrayWithRange:NSMakeRange(1, argc-1)]) {
                NSAssert([arg isKindOfClass:[NSString class]], @"");
                arg = [arg stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""]];
                printf("arg %lu: %s\n", i, [arg UTF8String]); //fflush(stdout);
                argv[i++] = [arg UTF8String];
            }
            argv[i] = NULL;
            
            for (NSUInteger i =0 ; i < argc+1; ++i) {
                const char *s = argv[i];
                printf("arg %lu: %s\n", i, s); //fflush(stdout);
            }
            
            if (execv([exePath UTF8String], (char * const *)argv)) {
                printf("error while execing command string: `%s`\n%s\n", [_commandString UTF8String], strerror(errno));
            }
            printf("did exec string: `%s`\n", [_commandString UTF8String]);
        }
    }

    return 0;
}

@end
