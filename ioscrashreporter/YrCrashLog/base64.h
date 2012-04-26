//
//  base64.h
//
//  Created by Gdier Zhang on 12-4-26.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (base64)

- (NSString *)encodeBase64;
- (NSString *)encodeBase64UsingEncoding:(NSStringEncoding)encoding;

+ (NSString *)base64StringWithString:(NSString *)string;
+ (NSString *)base64StringWithString:(NSString *)string usingEncoding:(NSStringEncoding)encoding;

@end

@interface NSData (base64)

+ (NSData *)dataWithBase64String:(NSString *)string;

@end