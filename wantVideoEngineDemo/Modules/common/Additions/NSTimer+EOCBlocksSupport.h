//
//  NSTimer+EOCBlocksSupport.h
//  microChannel
//
//  Created by ghosttian on 14-10-11.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (EOCBlocksSupport)

+ (NSTimer *)eoc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                          block:(void(^)())block
                                        repeats:(BOOL)repeats;

@end
