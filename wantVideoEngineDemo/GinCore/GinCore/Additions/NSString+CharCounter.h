//
//  NSString+CharCounter.h
//  microChannel
//
//  Created by minghuiji on 13-7-17.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CharCounter)
//计算字符数，汉字为2个字符
+ (NSInteger) calculateCharCounterFor:(NSString*) str;

//计算字符串需要截取的长度  str 为字符串本身   len 为需要的长度
+ (NSInteger)calculateSubStringLength:(NSString*)str length:(NSInteger)subLength;

+ (NSInteger)calculateCharCounterForTag:(NSString *)tag; //只包含数字，英文，中文

//全角转为半角。SBC case -> DBC case.
+ (NSString *)convertSBC2DBC:(NSString *)text;

// 中文三个字符
+(NSInteger)calculateCharCounterForWithUtf8Str:(NSString*) str;

@end
