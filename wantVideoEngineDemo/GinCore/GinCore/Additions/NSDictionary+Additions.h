//
//  NSDictionary+Additions.h
//  Gin
//
//  Created by zhaoys on 12-12-30.
//  Copyright (c) 2012年 Gin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

- (BOOL)ginBoolValueForKey:(NSString *)key;
- (BOOL)ginBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

- (int)ginIntValueForKey:(NSString *)key;
- (int)ginIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;

- (float)floatValueForKey:(NSString *)key;
- (float)floatValueForKey:(NSString *)key defaultValue:(int)defaultValue;

- (time_t)timeValueForKey:(NSString *)key;
- (time_t)timeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;

- (long long)longLongValueForKey:(NSString *)key;
- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue;

- (long long)unsignedLongLongValueForKey:(NSString *)key;
- (long long)unsignedLongLongValueForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue;

- (double)doubleValueForKey:(NSString *)key;
- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;

- (NSInteger)ginIntegerValueForKey:(NSString*)key;
- (NSInteger)ginIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

- (NSInteger)unsignedIntegerValueForKey:(NSString*)key;
- (NSInteger)unsignedIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

- (NSString *)ginStringValueForKey:(NSString *)key;
- (NSString *)ginStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

- (NSDictionary *)dictionaryValueForKey:(NSString *)key;
- (NSArray *)arrayValueForKey:(NSString *)key;


@end

