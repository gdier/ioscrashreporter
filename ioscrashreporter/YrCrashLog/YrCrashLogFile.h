//
//  YrCrashLogFile.h
//
//  Created by Gdier Zhang on 12-4-25.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    yrCrashTypeException = 1,
    yrCrashTypeSignal = 2,
};

@interface YrCrashLogFile : NSObject <NSCoding>
{
    int         type;
    void        *address;
    void        *code;
    NSArray     *callStack;
    NSString    *appVersion;
    NSString    *info;
}

@property(nonatomic) int type;
@property(nonatomic) void *address;
@property(nonatomic) void *code;
@property(nonatomic,retain) NSArray *callStack;
@property(nonatomic,retain) NSString *appVersion;
@property(nonatomic,retain) NSString *info;

+ (id)createFromLogFileName:(NSString *)fileName;

- (BOOL)writeToFile:(NSString *)fileName;

@end
