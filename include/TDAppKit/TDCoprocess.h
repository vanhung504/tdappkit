//
//  TDCoprocess.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/15/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDCoprocess : NSObject

+ (instancetype)coprocessWithCommandString:(NSString *)cmd environmentVariables:(NSDictionary *)env;
- (instancetype)initWithCommandString:(NSString *)cmd environmentVariables:(NSDictionary *)env;;

// returns child pid
- (pid_t)spawnWithError:(NSError **)outErr;

// child processes' stdin/stdin
@property (nonatomic, retain, readonly) NSFileHandle *tty;
@end
