//
//  NSURLRequest+YrCrashLogFileReporter.h
//
//  Created by Gdier Zhang on 12-4-26.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import "YrCrashLogFile.h"

@interface NSURLRequest (YrCrashLogFileReporter)

+ (NSURLRequest *)requestWithYrCrashLogFile:(YrCrashLogFile *)logFile;

@end
