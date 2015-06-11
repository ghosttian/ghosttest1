//
//  MVImageCache.h
//  microChannel
//
//  Created by alankong on 4/15/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MVImageCache : NSObject

+ (MVImageCache*) sharedInstance;
- (void)clear;
- (void)setImage:(UIImage*)image forPath:(NSString*)path;
- (UIImage*)getImageForPath:(NSString*)path;

@end
