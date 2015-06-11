//
//  GinJSONUtils.m
//  microChannel
//
//  Created by eson on 14-12-9.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinJSONUtils.h"

@implementation NSString (GinJSONUtils)

- (id)gin_objectFromJSONString
{
    return [self gin_objectFromJSONStringWithError:nil];
}

- (id)gin_mutableObjectFromJSONString
{
    return [self gin_mutableObjectFromJSONStringWithError:nil];
}

- (id)gin_objectFromJSONStringWithError:(NSError **)error
{
    NSData *JSONData = [self dataUsingEncoding:NSUTF8StringEncoding];
    id     JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:error];

    return JSONObject;
}

- (id)gin_mutableObjectFromJSONStringWithError:(NSError **)error
{
    NSData *JSONData = [self dataUsingEncoding:NSUTF8StringEncoding];
    id     JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:error];

    return JSONObject;
}

+ (NSString *)gin_JSONString:(id)object
{
    if (!object) {
        return nil;
    }

    NSData *json = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

+ (NSString *)gin_prettyJSONString:(id)object
{
    if (!object) {
        return nil;
    }

    NSData *json = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (GinJSONUtils)

- (id)gin_objectFromJSONData
{
    return [self gin_objectFromJSONDataWithError:nil];
}

- (id)gin_objectFromJSONDataWithError:(NSError **)error
{
    id JSONObject = [NSJSONSerialization JSONObjectWithData:self options:0 error:error];

    return JSONObject;
}

- (id)gin_mutableObjectFromJSONData
{
    return [self gin_mutableObjectFromJSONDataWithError:nil];
}

- (id)gin_mutableObjectFromJSONDataWithError:(NSError **)error
{
    id JSONObject = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:error];

    return JSONObject;
}

@end

@implementation NSDictionary (GinJSONUtils)

- (NSString *)gin_JSONString
{
    return [NSString gin_JSONString:self];
}

- (NSString *)gin_prettyJSONString
{
    return [NSString gin_prettyJSONString:self];
}

@end

@implementation NSArray (GinJSONUtils)

- (NSString *)gin_JSONString
{
    return [NSString gin_JSONString:self];
}

- (NSString *)gin_prettyJSONString
{
    return [NSString gin_prettyJSONString:self];
}

@end
