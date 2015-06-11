//
//  NSDictionary+Additions.m
//  Gin
//
//  Created by zhaoys on 12-12-30.
//  Copyright (c) 2012年 Gin. All rights reserved.
//

#import "NSDictionary+Util.h"

@implementation NSDictionary (Util)

#pragma mark -- bool

- (BOOL)mvBoolValueForKey:(NSString *)key
{
    
    return [self mvBoolValueForKey:key defaultValue:NO];
    
}

- (BOOL)mvBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj boolValue];

}

#pragma mark -- int
- (int)mvIntValueForKey:(NSString *)key
{
    
    return [self mvIntValueForKey:key defaultValue:0];
    
}

- (int)mvIntValueForKey:(NSString *)key defaultValue:(int)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj intValue];
    
}


#pragma mark -- float
- (float)mvFloatValueForKey:(NSString *)key
{
    
    return [self mvFloatValueForKey:key defaultValue:0];
    
}
- (float)mvFloatValueForKey:(NSString *)key defaultValue:(int)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj floatValue];

}


#pragma mark -- time
- (time_t)mvTimeValueForKey:(NSString *)key
{
    return [self mvTimeValueForKey:key defaultValue:0];
}

- (time_t)mvTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue
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
- (long long)mvLongLongValueForKey:(NSString *)key
{
    
    return [self mvLongLongValueForKey:key defaultValue:0];
    
}

- (long long)mvLongLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj longLongValue] ;
    
}

#pragma mark -- ull
- (long long)mvUnsignedLongLongValueForKey:(NSString *)key
{
    
    return [self mvUnsignedLongLongValueForKey:key defaultValue:0];
    
}
- (long long)mvUnsignedLongLongValueForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue
{
    
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj unsignedLongLongValue] ;
    
}

#pragma mark -- double
- (double)mvDoubleValueForKey:(NSString *)key
{
    
    return [self mvDoubleValueForKey:key defaultValue:0];
    
}

- (double)mvDoubleValueForKey:(NSString *)key defaultValue:(double)defaultValue
{
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj doubleValue] ;
    
}

#pragma mark -- NSInteger
- (NSInteger)mvIntegerValueForKey:(NSString *)key
{
    
    return [self mvIntegerValueForKey:key defaultValue:0];
    
}

- (NSInteger)mvIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    id obj = [self objectForKey:key];
    
    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    
    return [obj integerValue] ;

}

#pragma mark -- NSUInteger
- (NSInteger)mvUnsignedIntegerValueForKey:(NSString*)key
{
    
    return [self mvUnsignedIntegerValueForKey:key defaultValue:0];
    
}

- (NSInteger)mvUnsignedIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    id obj = [self objectForKey:key];

    if (!obj || obj == [NSNull null]) {
//        GCRITICAL(LogModuleGeneralCatchedException, @"the value should not be null callstack:%@", [NSThread callStackSymbols]);
        return defaultValue;
    }
    return [obj unsignedIntegerValue];
}

#pragma mark -- string
- (NSString *)mvStringValueForKey:(NSString *)key
{

    return [self mvStringValueForKey:key defaultValue:nil];

}

- (NSString *)mvStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue
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
- (NSDictionary *)mvDictionaryValueForKey:(NSString *)key
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
- (NSArray *)mvArrayValueForKey:(NSString *)key
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
