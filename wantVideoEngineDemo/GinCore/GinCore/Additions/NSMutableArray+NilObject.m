//
//  NSMutableArray+NilObject.m
//  microChannel
//
//  Created by randyyu on 13-7-6.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSMutableArray+NilObject.h"

@implementation NSMutableArray (NilObject)
- (void)addObjectOrNil:(id)anObject{
    
    if(anObject==nil){

        return;
    }
    [self addObject:anObject];
    
}

- (void)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index{
    
    if(anObject==nil){

        return;
    }
    if(index > [self count]){

        return;
    }
    [self insertObject:anObject atIndex:index];

}
- (void)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject{
    
    if(anObject==nil){
        return;
    }
    if(index>=[self count]){
        return;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
    
    
}

@end
