//
//  MicroVideoQueryResult.m
//  microChannel
//
//  Created by aidenluo on 7/19/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import "MicroVideoQueryResult.h"
#import "NSDictionary+Additions.h"

@implementation MicroVideoQueryResult

- (NSString *)description{
    return [NSString stringWithFormat:@"errCode = %ld, ret = %ld, msg = %@, data = %@",(long)_errCode, (long)_ret, _msg, _data];
}


- (id)initWithDictionary:(NSDictionary*)dic
{
    self = [super init];
    if (self)
    {
        //TODO 返回json为int，delete接口返回数据解析后的responseObject中errorcode为string？？？
        self.errCode = [dic ginIntegerValueForKey:@"errcode"];
        self.ret = [dic ginIntegerValueForKey:@"ret"];
        self.msg = [dic ginStringValueForKey:@"msg"];
        self.arrayInfo = [dic objectForKey:@"arrayInfo"];
        self.data = [dic objectForKey:@"data"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.errCode = [aDecoder decodeIntegerForKey:@"errCode"];
        self.ret = [aDecoder decodeIntegerForKey:@"ret"];
        self.msg = [aDecoder decodeObjectForKey:@"msg"];
        self.arrayInfo = [aDecoder decodeObjectForKey:@"arrayInfo"];
        self.data = [aDecoder decodeObjectForKey:@"data"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.errCode forKey:@"errCode"];
    [aCoder encodeInteger:self.ret forKey:@"ret"];
    [aCoder encodeObject:self.msg forKey:@"msg"];
    [aCoder encodeObject:self.arrayInfo forKey:@"arrayInfo"];
    [aCoder encodeObject:self.data forKey:@"data"];
}

@end
