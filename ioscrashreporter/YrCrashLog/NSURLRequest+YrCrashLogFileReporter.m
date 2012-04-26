//
//  NSURLRequest+YrCrashLogFileReporter.m
//
//  Created by Gdier Zhang on 12-4-26.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import "NSURLRequest+YrCrashLogFileReporter.h"
#import "base64.h"

#pragma error you MUST change this url if you want report logs to somewhere
#define REPORT_URL_FORMAT @"http://xxx.xxxx.com/post.php?ver=%@&addr=%u&code=%u"

@implementation NSURLRequest (YrCrashLogFileReporter)

+ (NSURLRequest *)requestWithYrCrashLogFile:(YrCrashLogFile *)logFile
{
    if (nil == logFile)
        return nil;
    
    NSString *urlString = [NSString stringWithFormat:REPORT_URL_FORMAT, logFile.appVersion, logFile.address, logFile.code];
    
    NSString *stackString = [NSString stringWithFormat:@"type:%d\n%@\n%@", logFile.type, logFile.info, [logFile.callStack componentsJoinedByString:@"\n"]];
    
    NSString *httpBody = [NSString stringWithFormat:@"stack=%@", [stackString encodeBase64]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
    
    return request;
}

@end
