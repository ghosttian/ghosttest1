//
//  GinLogDataAccessGuard.h
//  GinCore
//
//  Created by wangqi on 14-12-17.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinLogDataAccessGuard : NSObject

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *keyName;

+ (GinLogDataAccessGuard *)sharedInstance;
- (NSMutableArray *)getAllItems;
- (void)insertItem:(id)item;

@end
