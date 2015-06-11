//
//  CALayer+addtion.m
//  microChannel
//
//  Created by minghuiji on 15/1/15.
//  Copyright (c) 2015年 wbdev. All rights reserved.
//

#import "CALayer+addtion.h"

@implementation CALayer (addtion)
- (CALayer*)subLayerForName:(NSString *)name
{
    __block CALayer *retLayer = nil;
    [self.sublayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CALayer *subLayer = (CALayer*)obj;
        
        if ([subLayer.name isEqualToString:name]) {
            retLayer = subLayer;
            *stop = YES;
        }
    }];
    
    return retLayer;
}

@end
