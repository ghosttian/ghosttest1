//
//  NSMutableArray+NilObject.h
//  microChannel
//
//  Created by randyyu on 13-7-6.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (NilObject)

- (void)addObjectOrNil:(id)anObject;
- (void)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject;

@end
