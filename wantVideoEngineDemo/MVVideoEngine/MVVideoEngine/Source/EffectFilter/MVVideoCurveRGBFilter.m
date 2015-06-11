//
//  MVVideoCurveRGBFilter.m
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoCurveRGBFilter.h"
#import "GPUImagePicture.h"

@interface MVVideoCurveRGBFilter ()

@end

@implementation MVVideoCurveRGBFilter

NSString *const kMVVideoCurveRGBFilterFragmentShaderString = SHADER_STRING
(
 
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform int filterWithAlpha;
 
 void main()
 {
     vec4 color =  texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4(texture2D(inputImageTexture2, vec2(color.r,0.0)).r,
                         texture2D(inputImageTexture2, vec2(color.g,0.0)).g,
                         texture2D(inputImageTexture2, vec2(color.b,0.0)).b,
                         1.0);
 }
 
 );


NSString *const kMVVideoCurveRGBFilterWithCutFragmentShaderString = SHADER_STRING
(
 
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform int filterWithAlpha;
 
 void main()
 {
     vec4 color =  texture2D(inputImageTexture, textureCoordinate);
     float alpha = texture2D(inputImageTexture2, vec2(textureCoordinate.x, 1.0 - textureCoordinate.y)).a;
     if(alpha < 1.0){
         if(alpha <= 0.005){
             alpha = 0.0;
         }
         color = mix(vec4(texture2D(inputImageTexture2, vec2(color.r,0.0)).r,
                          texture2D(inputImageTexture2, vec2(color.g,0.0)).g,
                          texture2D(inputImageTexture2, vec2(color.b,0.0)).b,
                          1.0), color, alpha);
     }
     gl_FragColor = color;
 }
 
);

-(instancetype)initWithCut:(BOOL)cutWithAlpha picture:(UIImage *)image
{
    if (cutWithAlpha) {
        self = [super initWithFragmentShaderFromString:kMVVideoCurveRGBFilterWithCutFragmentShaderString];
    } else {
        self = [super initWithFragmentShaderFromString:kMVVideoCurveRGBFilterFragmentShaderString];
    }
    if (self) {
        _curveImage = image;
    }
    return self;
}

@end
