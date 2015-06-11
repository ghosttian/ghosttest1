//
//  MVVideoSkinBeautyFilter.m
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoSkinBeautyFilter.h"

@implementation MVVideoSkinBeautyFilter

NSString *const kMVVideoSkinBeautyFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float mvFactor;
 uniform float mvFactorRed;
 uniform float mvFactorGreen;
 uniform float mvFactorBlue;
 
 void main()
 {
     vec3 color = texture2D(inputImageTexture,textureCoordinate).rgb;
     color.r = texture2D(inputImageTexture2, vec2(color.r, mvFactor)).r * (mvFactorRed + 1.0);
     color.g = texture2D(inputImageTexture2, vec2(color.g, mvFactor)).g * (mvFactorGreen + 1.0);
     color.b = texture2D(inputImageTexture2, vec2(color.b, mvFactor)).b * (mvFactorBlue + 1.0);
     color = clamp(color, 0.0, 1.0);
     gl_FragColor = vec4(color, 1.0);
 }
 
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoSkinBeautyFilterFragmentShaderString];
    if (self) {
        
    }
    return self;
}

- (void)setFactor:(float)factor
{
    [self setFloat:factor forUniformName:@"mvFactor"];
}

- (void)setRed:(float)red
{
    [self setFloat:red forUniformName:@"mvFactorRed"];
}

- (void)setGreen:(float)green
{
    [self setFloat:green forUniformName:@"mvFactorGreen"];
}

- (void)setBlue:(float)blue
{
    [self setFloat:blue forUniformName:@"mvFactorBlue"];
}

@end
