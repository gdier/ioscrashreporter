//
//  YrCrashLogger.h
//
//  Created by Gdier Zhang on 12-4-24.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YrCrashLogger : NSObject

+ (BOOL)registerLogger;

+ (NSString *)getLogPath;

@end
