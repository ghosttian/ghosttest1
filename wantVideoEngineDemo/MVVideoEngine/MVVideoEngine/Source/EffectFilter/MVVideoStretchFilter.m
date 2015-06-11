//
//  MVVideoStretchFilter.m
//  microChannel
//
//  Created by aidenluo on 9/15/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoStretchFilter.h"

@implementation MVVideoStretchFilter

NSString *const kMVVideoStretchFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 void main()
 {
     float x1;
     float y1;
     float x0;
     float y0;
     x0 = textureCoordinate.x;
     y0 = textureCoordinate.y;
     x0 = clamp(x0, 0.0001, 1.0);
     y0 = clamp(y0, 0.0001, 1.0);
     x1 = pow(x0, 1.5);
     y1 = pow(y0, 0.4);
     gl_FragColor = texture2D(inputImageTexture, vec2(x1,y1));
 }
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoStretchFilterFragmentShaderString];
    if (self) {
        
    }
    return self;
}

@end
