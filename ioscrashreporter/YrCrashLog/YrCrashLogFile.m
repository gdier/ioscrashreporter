//
//  YrCrashLogFile.m
//
//  Created by Gdier Zhang on 12-4-25.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import "YrCrashLogFile.h"

@implementation YrCrashLogFile

@synthesize type;
@synthesize address;
@synthesize code;
@synthesize callStack;
@synthesize appVersion;
@synthesize info;

- (void)dealloc
{
    self.callStack = nil;
    self.appVersion = nil;
    self.info = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.type       = [[aDecoder decodeObjectForKey:@"type"] intValue];
        self.address    = (void *)[[aDecoder decodeObjectForKey:@"address"] unsignedIntValue];
        self.code       = (void *)[[aDecoder decodeObjectForKey:@"code"] intValue];
        self.callStack  = [aDecoder decodeObjectForKey:@"callStack"];
        self.appVersion = [aDecoder decodeObjectForKey:@"appVersion"];
        self.info       = [aDecoder decodeObjectForKey:@"info"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInt:(int)address] forKey:@"address"];
    [aCoder encodeObject:[NSNumber numberWithInt:(int)code] forKey:@"code"];
    [aCoder encodeObject:callStack forKey:@"callStack"];
    [aCoder encodeObject:appVersion forKey:@"appVersion"];
    [aCoder encodeObject:info forKey:@"info"];
}

+ (id)createFromLogFileName:(NSString *)fileName
{
    @try {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
    }
}

- (BOOL)writeToFile:(NSString *)fileName
{
    return [NSKeyedArchiver archiveRootObject:self toFile:fileName];
}

@end
