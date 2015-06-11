//
//  MicroVideoQueryResult.h
//  microChannel
//
//  Created by aidenluo on 7/19/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MicroVideoQueryResult : NSObject<NSCoding>

@property(nonatomic, assign) NSInteger errCode;
@property(nonatomic, assign) NSInteger ret;
@property(nonatomic, copy) NSString *msg;
@property(nonatomic, strong) NSMutableArray *arrayInfo;
@property(nonatomic, strong) id data;

- (id)initWithDictionary:(NSDictionary*)dic;

@end
