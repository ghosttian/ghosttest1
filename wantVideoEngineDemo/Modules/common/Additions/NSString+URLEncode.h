//
//  NSString+URLEncode.h
//  microChannel
//
//  Created by randyyu on 13-11-19.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncode)
- (NSString *)URLEncodedString;
- (NSString*) urlDecode:(NSStringEncoding)stringEncoding;

@end
