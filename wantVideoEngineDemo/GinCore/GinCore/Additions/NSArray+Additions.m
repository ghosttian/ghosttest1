//
//  NSArray+Additions.m
//  microChannel
//
//  Created by ricky on 13-10-31.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)
- (id)objectValueAtIndex:(NSUInteger)index
{
        
    if ((int)index < 0 || index >= [self count]) {

        return nil;
    }
    else
    {
        return [self objectAtIndex:index];
    }
    
    
}

@end
