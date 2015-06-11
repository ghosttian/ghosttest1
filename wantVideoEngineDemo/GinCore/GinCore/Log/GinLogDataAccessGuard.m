//
//  GinLogDataAccessGuard.m
//  GinCore
//
//  Created by wangqi on 14-12-17.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinLogDataAccessGuard.h"

NSString *const kErrorsEncouteredInCurrentVersion   = @"errors_encountered_in_current_version";

@implementation GinLogDataAccessGuard

+ (GinLogDataAccessGuard *)sharedInstance
{
    static GinLogDataAccessGuard *_singleInst;
    if (!_singleInst) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _singleInst = [[GinLogDataAccessGuard alloc]initWithKey:kErrorsEncouteredInCurrentVersion];
        });
    }
    
    return _singleInst;
}

- (instancetype)initWithKey:(NSString *)key
{
    if (self = [super init])
    {
        self.keyName = key;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.dataArray = [[defaults objectForKey:self.keyName] mutableCopy];
    }
    
    return self;
}

- (NSMutableArray *)getAllItems
{
    @synchronized (self.dataArray)
    {
        return self.dataArray;
    }
}

- (void)insertItem:(id)item
{
    if (!item)
    {
        return;
    }
    
    @synchronized (self.dataArray)
    {
        if (nil == self.dataArray || 0 == [self.dataArray count])
        {
            self.dataArray = [@[item] mutableCopy];
        }
        else
        {
            [self.dataArray addObject:item];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.dataArray forKey:self.keyName];
    }
}

@end
