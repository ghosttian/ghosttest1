//
//  NSMutableDictionary+NilObject.h
//  microChannel
//
//  Created by randyyu on 13-7-6.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NilObject)
- (void)setObjectOrNil:(id)anObject forKeyOrNil:(id <NSCopying>)aKey;
- (void)setObjectOrNil:(id)anObject forKey:(id <NSCopying>)aKey;
@end
