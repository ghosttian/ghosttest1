//
//  MVVideoEffectSkinBeautyFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectSkinBeautyFilterExcutor.h"
#import "MVVideoSkinSandingFilter.h"
#import "MVVideoSkinBeautyFilter.h"
#import "GPUImagePicture.h"
#import "MVVideoCurveFilter.h"
#import "MVVideoSkinRedFilter.h"
#import "MVVideoCurveDarkCornerFilter.h"
#import "MVVideoCurveFilter.h"

@interface MVVideoEffectSkinBeautyFilterExcutor ()

@property(nonatomic,strong) GPUImageOutput<GPUImageInput> *skinFilter;
@property(nonatomic,strong) NSArray *pictures;

@end

@implementation MVVideoEffectSkinBeautyFilterExcutor

- (GPUImageOutput<GPUImageInput> *)getFilter
{
    if (self.skinFilter) {
        return self.skinFilter;
    }
    GPUImageOutput<GPUImageInput> *filter = nil;
    GPUImageFilter *sanding = [[GPUImageFilter alloc] init];
    switch (self.filterId) {
        case 11301:
        {
            filter = sanding;
            break;
        }
        case 11302:
        {
            GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
            GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"]];
            MVVideoSkinBeautyFilter *beauty = [[MVVideoSkinBeautyFilter alloc] init];
            [beauty setFactor:0.5];
            [beauty setRed:0.05];
            [beauty setGreen:-0.1];
            [beauty setBlue:-0.05];
            [picture addTarget:beauty atTextureLocation:1];
            [beauty disableSecondFrameCheck];
            [picture processImage];
            [sanding addTarget:beauty atTextureLocation:0];
            [group addFilter:sanding];
            [group addFilter:beauty];
            group.initialFilters = @[sanding];
            group.terminalFilter = beauty;
            filter = group;
            NSArray *array = [NSArray arrayWithObject:picture];
            self.pictures = array;
            break;
        }
        case 11303:
        {
            GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
            GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"]];
            MVVideoSkinBeautyFilter *beauty = [[MVVideoSkinBeautyFilter alloc] init];
            [beauty setFactor:0.7];
            [beauty setRed:-0.05];
            [beauty setGreen:-0.10];
            [beauty setBlue:-0.15];
            [picture addTarget:beauty atTextureLocation:1];
            [beauty disableSecondFrameCheck];
            [picture processImage];
            [sanding addTarget:beauty atTextureLocation:0];
            [group addFilter:sanding];
            [group addFilter:beauty];
            group.initialFilters = @[sanding];
            group.terminalFilter = beauty;
            filter = group;
            NSArray *array = [NSArray arrayWithObject:picture];
            self.pictures = array;
            break;
        }
        case 11304:
        {
            GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
            GPUImagePicture *picture1 = [[GPUImagePicture alloc] initWithImage:[MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"]];
            MVVideoSkinBeautyFilter *beauty = [[MVVideoSkinBeautyFilter alloc] init];
            [beauty setFactor:0.7];
            [beauty setRed:-0.05];
            [beauty setGreen:-0.05];
            [beauty setBlue:-0.08];
            [picture1 addTarget:beauty atTextureLocation:1];
            [beauty disableSecondFrameCheck];
            [picture1 processImage];

            UIImage *image = [MVVideoCurveFilter decodeImageByName:@"lomo.png"];
            GPUImagePicture *picture2 = [[GPUImagePicture alloc] initWithImage:image];
            GPUMatrix4x4  matix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            MVVideoCurveDarkCornerFilter *curveDark = [[MVVideoCurveDarkCornerFilter alloc] initWithPicture:image Matix:matix gradientStart:0.35 gradientEnd:1.721429];
            [picture2 addTarget:curveDark atTextureLocation:1];
            [curveDark disableSecondFrameCheck];
            [picture2 processImage];
            
            MVVideoSkinRedFilter *red = [[MVVideoSkinRedFilter alloc] init];
            
            [sanding addTarget:curveDark atTextureLocation:0];
            [curveDark addInputTarget:red];
            [red addTarget:beauty atTextureLocation:0];
            
            [group addFilter:sanding];
            [group addFilter:beauty];
            [group addFilter:curveDark];
            [group addFilter:red];
            group.initialFilters = @[sanding];
            group.terminalFilter = beauty;
            filter = group;
            
            NSArray *array = [NSArray arrayWithObjects:picture1,picture2, nil];
            self.pictures = array;
            break;
        }
        case 11305:
        {
            GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
            GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[MVVideoCurveFilter decodeImageByName:@"qingxiheibai.png"]];
            GPUMatrix4x4  matix = { 0.299f, 0.299f, 0.299f, 0, 0.587f, 0.587f, 0.587f, 0, 0.114f, 0.114f, 0.114f, 0, 0, 0, 0, 1 };
            MVVideoCurveFilter *curve = [[MVVideoCurveFilter alloc] initWithMatix:matix resourceImage:nil];
            [picture addTarget:curve atTextureLocation:1];
            [curve disableSecondFrameCheck];
            [picture processImage];
            [sanding addTarget:curve atTextureLocation:0];
            [group addFilter:sanding];
            [group addFilter:curve];
            group.initialFilters = @[sanding];
            group.terminalFilter = curve;
            filter = group;
            NSArray *array = [NSArray arrayWithObject:picture];
            self.pictures = array;
            break;
        }
    }
    self.skinFilter = filter;
    return filter;
}

@end
