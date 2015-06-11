//
//  MVEditVideoViewController.h
//  wantVideoEngineDemo
//
//  Created by ghost on 15-6-2.
//  Copyright (c) 2015年 ghost. All rights reserved.
//

#import "GinPortraitViewController.h"
#import "MVVideoEffectModel.h"

@interface MVEditVideoViewController : GinPortraitViewController

@property (nonatomic, strong)MVVideoEffectModel *effectModel;

- (instancetype)initWithOriginalVideoPath:(NSString *)originalVideoPath;
- (instancetype)initWithOriginalVideoPath:(NSString *)originalVideoPath
                                videoType:(MVCompositiongDataVideoType)videoType;

- (void)playVideo;

@end
