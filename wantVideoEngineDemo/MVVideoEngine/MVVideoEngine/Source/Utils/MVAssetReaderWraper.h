//
//  MVAssetReaderWraper.h
//  microChannel
//
//  Created by eson on 14-9-9.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MVAssetReaderWraper : NSObject

@property (nonatomic, assign) NSTimeInterval readerStartTime;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (BOOL)startProcess;
- (void)cancelProcess;

- (CGImageRef)copySampleCGImageRefAtTime:(NSTimeInterval)time;

+ (CGImageRef)copyImageRefFromCMSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (CGImageRef)copyImageRefFromCVPixelBufferRef:(CVPixelBufferRef)imageBuffer;

@end
