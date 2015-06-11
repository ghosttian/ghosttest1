//
//  NSString+CharCounter.m
//  microChannel
//
//  Created by minghuiji on 13-7-17.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSString+CharCounter.h"

@implementation NSString (CharCounter)
+(NSInteger) calculateCharCounterFor:(NSString*) str
{
    NSUInteger len = [str length];
    NSInteger asicCount = 0;
    NSInteger blankCount = 0;
    NSInteger longCount = 0;
    
    for (uint idx = 0; idx < len; ++idx)
    {
        unichar cha = [str characterAtIndex:idx];
        if(isblank(cha))
        {
            ++blankCount;
        }
        else if(isascii(cha))
        {
            ++asicCount;
        }else
        {
            ++longCount;
        }
    }
    
    if(asicCount ==0 && longCount== 0)
    {
        return 0;
    }
    
    return longCount * 2 + asicCount + blankCount;
}

+ (NSInteger)calculateCharCounterForTag:(NSString *)tag {
    NSUInteger count = 0;
    for (int i=0; i<tag.length; i++) {
        wchar_t uc = [tag characterAtIndex:i];
        if (uc >= 0x4e00 && uc <= 0x9fa5) {
            count+=2;
        }
        else if (isascii(uc)){
            count++;
        } else {
            count+=2;
        }
    }
    return count;
}

+ (NSString *)convertSBC2DBC:(NSString *)text {
    NSMutableString *newText = [[NSMutableString alloc] initWithString:text];
    for (int i=0; i<text.length; i++) {
        wchar_t uc = [text characterAtIndex:i];
        if (uc >= 0xff41 && uc <= 0xff5a) {
            NSString *charString = [NSString stringWithFormat:@"%c", uc-0xff41+'a'];
            [newText replaceCharactersInRange:NSMakeRange(i, 1) withString:charString];
        } else if (uc >= 0xff21 && uc<=0xff3a) { 
            NSString *charString = [NSString stringWithFormat:@"%c", uc-0xff21+'A'];
            [newText replaceCharactersInRange:NSMakeRange(i, 1) withString:charString];
        }
    }
    return newText;
}

//计算字符串需要截取的位置  str 为字符串本身   subLength 为需要的长度
+ (NSInteger)calculateSubStringLength:(NSString*)str length:(NSInteger)subLength;
{
    NSUInteger strLength = [str length];
    
    int length = 0;
    if (strLength == 0) {
        return length;
    }
    
    NSInteger asicCount = 0;
    NSInteger blankCount = 0;
    NSInteger longCount = 0;
    
    for (uint idx = 0; idx < strLength; ++idx)
    {
        unichar cha = [str characterAtIndex:idx];
        if(isblank(cha))
        {
            ++blankCount;
        }
        else if(isascii(cha))
        {
            ++asicCount;
        }else
        {
            ++longCount;
        }
        if ((asicCount + longCount) > 0) {
            length = idx + 1;
            NSInteger len = longCount * 2 + asicCount + blankCount;
            if (len >= subLength * 2 && strLength > subLength) {
                break;
            }
        }
    }
    
    return length;
}

+(NSInteger)calculateCharCounterForWithUtf8Str:(NSString*) str
{
    NSUInteger len = [str length];
    NSInteger asicCount = 0;
    NSInteger blankCount = 0;
    NSInteger longCount = 0;
    
    for (uint idx = 0; idx < len; ++idx)
    {
        unichar cha = [str characterAtIndex:idx];
        if(isblank(cha))
        {
            ++blankCount;
        }
        else if(isascii(cha))
        {
            ++asicCount;
        }else
        {
            ++longCount;
        }
    }
    
    if(asicCount ==0 && longCount== 0)
    {
        return 0;
    }
    
    return longCount * 3 + asicCount + blankCount;
}

@end
