//
//  MVVideoPortraitBeautyFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.s
//

#import "MVVideoEngine.h"
#import "GPUImageTwoInputFilter.h"

typedef NS_ENUM(NSInteger, GPUImagePortraitBeautyFilterType){
    BeautyType_QingXinLiRen = 1,//清新丽人
    BeautyType_TianMeiKeRen = 2,//甜美可人
    BeautyType_ShenDuMeiBai = 3,//深度美白
    BeautyType_XiangYanHongChun = 4,//香艳红唇
    BeautyType_TianShengLiZhi = 5,//天生丽质
};

@interface MVVideoPortraitBeautyFilter : GPUImageTwoInputFilter

@property(nonatomic,strong)UIImage *beautyImage;

-(instancetype)initWithPicture:(UIImage *)image Type:(GPUImagePortraitBeautyFilterType)beautyType;

@end
