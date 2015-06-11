//
//  NSDictionary+Additions.m
//  Gin
//
//  Created by zhaoys on 12-12-30.
//  Copyright (c) 2012年 Gin. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

#pragma mark -- bool

- (BOOL)ginBoolValueForKey:(NSString *)key
{
    
    return [self ginBoolValueForKey:key defaultValue:NO];
    
}

- (BOOL)ginBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj boolValue];

}

#pragma mark -- int
- (int)ginIntValueForKey:(NSString *)key
{
    
    return [self ginIntValueForKey:key defaultValue:0];
    
}

- (int)ginIntValueForKey:(NSString *)key defaultValue:(int)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj intValue];
    
}


#pragma mark -- float
- (float)floatValueForKey:(NSString *)key
{
    
    return [self floatValueForKey:key defaultValue:0];
    
}
- (float)floatValueForKey:(NSString *)key defaultValue:(int)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj floatValue];

}


#pragma mark -- time
- (time_t)timeValueForKey:(NSString *)key
{
    return [self timeValueForKey:key defaultValue:0];
}

- (time_t)timeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue
{
	id timeObject = [self objectForKey:key];
    if ([timeObject isKindOfClass:[NSNumber class]])
    {
        NSNumber *n = (NSNumber *)timeObject;
        CFNumberType numberType = CFNumberGetType((CFNumberRef)n);
        NSTimeInterval t;
        if (numberType == kCFNumberLongLongType) {
            t = [n longLongValue] / 1000;
        }
        else {
            t = [n longValue];
        }
        return t;
    }
    else if ([timeObject isKindOfClass:[NSString class]])
    {
        NSString *stringTime   = timeObject;
        if (stringTime.length == 13)
        {
            long long llt = [stringTime longLongValue];
            NSTimeInterval t = llt / 1000;
            return t;
        }
        else if (stringTime.length == 10)
        {
            long long lt = [stringTime longLongValue];
            NSTimeInterval t = lt;
            return t;
        }
        else
        {
            if (!stringTime || (id)stringTime == [NSNull null])
            {
                stringTime = @"";
            }
            struct tm created;
            time_t now;
            time(&now);
            
            if (stringTime)
            {
                if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL)
                {
                    strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
                }
                return mktime(&created);
            }
        }
    }
	return defaultValue;
}

#pragma mark -- ll
- (long long)longLongValueForKey:(NSString *)key
{
    
    return [self longLongValueForKey:key defaultValue:0];
    
}

- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj longLongValue] ;
    
}

#pragma mark -- ull
- (long long)unsignedLongLongValueForKey:(NSString *)key
{
    
    return [self unsignedLongLongValueForKey:key defaultValue:0];
    
}
- (long long)unsignedLongLongValueForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj unsignedLongLongValue] ;
    
}

#pragma mark -- double
- (double)doubleValueForKey:(NSString *)key
{
    
    return [self doubleValueForKey:key defaultValue:0];
    
}

- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue
{
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj doubleValue] ;
    
}

#pragma mark -- NSInteger
- (NSInteger)ginIntegerValueForKey:(NSString*)key
{
    
    return [self ginIntegerValueForKey:key defaultValue:0];
    
}

- (NSInteger)ginIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj integerValue] ;

}

#pragma mark -- NSUInteger
- (NSInteger)unsignedIntegerValueForKey:(NSString*)key
{
    
    return [self unsignedIntegerValueForKey:key defaultValue:0];
    
}

- (NSInteger)unsignedIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    id obj = [self objectForKey:key];

    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    return [obj unsignedIntegerValue];
}

#pragma mark -- string
- (NSString *)ginStringValueForKey:(NSString *)key
{

    return [self ginStringValueForKey:key defaultValue:nil];

}

- (NSString *)ginStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null])
    {
        if ([self objectForKey:key] == [NSNull null]) {
//            GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        }
        return defaultValue;
    }
    id result = [self objectForKey:key];
    if ([result isKindOfClass:[NSNumber class]])
    {
        return [result stringValue];
    }
    return result;
    
}


#pragma mark -- dict
- (NSDictionary *)dictionaryValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    
    if (obj && [obj isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)obj;
    }else if(obj){
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should be NSDictionary callstack:%@", [NSThread callStackSymbols]);
    }
    return nil;
    
}


#pragma mark -- array
- (NSArray *)arrayValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    
    if (obj && [obj isKindOfClass:[NSArray class]])
    {
        return (NSArray *)obj;
    }else if(obj){
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should be NSArray callstack:%@", [NSThread callStackSymbols]);
    }
    return nil;

}

@end
