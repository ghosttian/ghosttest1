//
//  MVVideoStencilFilter.m
//  microChannel
//
//  Created by aidenluo on 9/22/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoStencilFilter.h"

@implementation MVVideoStencilFilter

NSString *const kMVVideoStencilFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //overlayTexture
 uniform sampler2D inputImageTexture3;  //maskTexture
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 overlay = texture2D(inputImageTexture2, textureCoordinate);
     vec4 masking = texture2D(inputImageTexture3, textureCoordinate);
     vec4 finalColor = mix(textureColor, overlay, masking.r);
     gl_FragColor = finalColor;
 }
);

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoStencilFilterFragmentShaderString];
    if (self) {
        
    }
    return self;
}

@end
