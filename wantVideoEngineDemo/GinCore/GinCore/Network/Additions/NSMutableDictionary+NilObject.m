//
//  NSMutableDictionary+NilObject.m
//  microChannel
//
//  Created by randyyu on 13-7-6.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSMutableDictionary+NilObject.h"

@implementation NSMutableDictionary (NilObject)
- (void)setObjectOrNil:(id)anObject forKeyOrNil:(id <NSCopying>)aKey{
    
    if(!anObject || !aKey)
    {
        return;
    }
    [self setObject:anObject forKey:aKey];

    
}
- (void)setObjectOrNil:(id)anObject forKey:(id <NSCopying>)aKey{
    
    if(!anObject)
    {
        return;
    }
    [self setObject:anObject forKey:aKey];

}

@end
