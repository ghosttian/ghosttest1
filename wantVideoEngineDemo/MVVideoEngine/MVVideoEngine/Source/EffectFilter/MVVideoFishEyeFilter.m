//
//  MVVideoFishEyeFilter.m
//  microChannel
//
//  Created by aidenluo on 9/15/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoFishEyeFilter.h"

@implementation MVVideoFishEyeFilter

NSString *const kMVVideoFishEyeFilterFragmentShaderString = SHADER_STRING
(
    precision mediump float;
    varying vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
    void main()
    {
        vec2 newXY = textureCoordinate - vec2(0.5);
        float len = length(newXY);
        vec2 newCoord = vec2(0.5) + normalize(newXY) * (0.5 * len / (1.25 - len));
        gl_FragColor = texture2D(inputImageTexture, newCoord);
    }
);

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoFishEyeFilterFragmentShaderString];
    if (self) {
        
    }
    return self;
}

@end
