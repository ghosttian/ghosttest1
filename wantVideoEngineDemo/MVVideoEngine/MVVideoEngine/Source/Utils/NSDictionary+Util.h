//
//  NSDictionary+Additions.h
//  Gin
//
//  Created by zhaoys on 12-12-30.
//  Copyright (c) 2012年 Gin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Util)

- (BOOL)mvBoolValueForKey:(NSString *)key;
- (BOOL)mvBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

- (int)mvIntValueForKey:(NSString *)key;
- (int)mvIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;

- (float)mvFloatValueForKey:(NSString *)key;
- (float)mvFloatValueForKey:(NSString *)key defaultValue:(int)defaultValue;

- (time_t)mvTimeValueForKey:(NSString *)key;
- (time_t)mvTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;

- (long long)mvLongLongValueForKey:(NSString *)key;
- (long long)mvLongLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue;

- (long long)mvUnsignedLongLongValueForKey:(NSString *)key;
- (long long)mvUnsignedLongLongValueForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue;

- (double)mvDoubleValueForKey:(NSString *)key;
- (double)mvDoubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;

- (NSInteger)mvIntegerValueForKey:(NSString*)key;
- (NSInteger)mvIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

- (NSInteger)mvUnsignedIntegerValueForKey:(NSString*)key;
- (NSInteger)mvUnsignedIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

- (NSString *)mvStringValueForKey:(NSString *)key;
- (NSString *)mvStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

- (NSDictionary *)mvDictionaryValueForKey:(NSString *)key;
- (NSArray *)mvArrayValueForKey:(NSString *)key;


@end

