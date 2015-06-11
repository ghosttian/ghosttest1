//
//  NSMutableArray+LRU.h
//  Gin
//
//  Created by tianzhe on 13-3-8.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (LRUArray)

- (void)addObjectToLRU:(id)anObject;
- (void)addObjectToLRU:(id)anObject maxItemCount:(NSInteger)maxItemCount;
- (void)removeLRU:(NSInteger)num;

@end
