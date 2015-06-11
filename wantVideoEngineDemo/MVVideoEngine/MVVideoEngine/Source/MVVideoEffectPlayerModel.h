//
//  MVVideoEffectPlayerModel.h
//  microChannel
//
//  Created by aidenluo on 11/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MVVideoEffectPlayerModel : NSObject

@property(nonatomic, strong) NSArray *combineAssets;
@property(nonatomic, strong) AVAsset *originAsset;
@property(nonatomic, copy) NSString *originVideoPath;
@property(nonatomic, copy) NSString *effectVideoPath;
@property(nonatomic, copy) NSString *finalVideoPath;

@property(nonatomic, copy) NSString *musicPath;
@property(nonatomic, assign) CGFloat musicVolume;
@property(nonatomic, assign) BOOL isSilent;
@property(nonatomic, assign) BOOL isLongVideo;
@property (nonatomic, strong) NSNumber* videoBitrate; //使用该码率导出，如果设置了

@property(nonatomic, strong) NSDictionary *effectUserData;
@property(nonatomic, strong) CALayer *waterMarkLayer;

@end
