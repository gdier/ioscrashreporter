//
//  YrCrashReporter.m
//
//  Created by Gdier Zhang on 12-4-18.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import "YrCrashReporter.h"
#import "YrCrashLogger.h"
#import "NSURLRequest+YrCrashLogFileReporter.h"

@interface YrCrashReportOperation : NSOperation
{
@private
    NSString *_fileName;
}

@property(nonatomic,retain) NSOperationQueue *queue;

- (id)initWithFileName:(NSString *)fileName;

@end

@implementation YrCrashReportOperation

@synthesize queue;

- (id)initWithFileName:(NSString *)fileName
{
    if (self = [super init])
    {
        _fileName = [fileName copy];
    }

    return self;
}

- (void)main
{
    YrCrashLogFile *logFile = [YrCrashLogFile createFromLogFileName:_fileName];
    
    NSURLRequest *request = [NSURLRequest requestWithYrCrashLogFile:logFile];
    
    NSHTTPURLResponse *response = nil;
    NSError *err = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        if (200 == [response statusCode])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_fileName error:nil];
        }
    }
    
    self.queue = nil;
}

@end

@implementation YrCrashReporter

+ (void)reportLogs
{
    NSString *logFileDir = [YrCrashLogger getLogPath];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:logFileDir];
    id fileName = nil;
    
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    
    while (fileName = [enumerator nextObject])
    {
        NSString *fullFileName = [logFileDir stringByAppendingPathComponent:fileName];
        
        YrCrashReportOperation *operation = [[YrCrashReportOperation alloc] initWithFileName:fullFileName];
        
        operation.queue = opQueue;
        
        [opQueue addOperation:operation];
        
        [operation release];
        
        NSLog(@"%@", fileName);
    }
    
    [opQueue release];
}

@end


