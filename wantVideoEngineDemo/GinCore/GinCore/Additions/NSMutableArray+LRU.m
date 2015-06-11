//
//  NSMutableArray+LRU.m
//  Gin
//
//  Created by tianzhe on 13-3-8.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import "NSMutableArray+LRU.h"

@implementation NSMutableArray (LRUArray)

- (void)addObjectToLRU:(id)anObject
{
    [self removeObject:anObject];
    [self insertObject:anObject atIndex:0];
}

- (void) addObjectToLRU:(id)anObject maxItemCount:(NSInteger)maxItemCount
{
    if (self.count > maxItemCount) {
        [self removeLRU:self.count - maxItemCount];
    }
    
    [self addObjectToLRU:anObject];
}

- (void)removeLRU:(NSInteger)num
{
    num = num > self.count ? self.count : num;
    for (int i = 0; i < num; ++i) {
        [self removeObjectAtIndex:self.count-1];
    }
}

@end
