//
//  TDCoprocess.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/15/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDCoprocess : NSObject

+ (instancetype)coprocessWithCommandString:(NSString *)cmdString;
- (instancetype)initWithCommandString:(NSString *)cmdString;

- (int)spawnWithError:(NSError **)outErr;

- (NSFileHandle *)fileHandleForWriting; // child processes' stdin
- (NSFileHandle *)fileHandleForReading; // child processes' stdout
@end
