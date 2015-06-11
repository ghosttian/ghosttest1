//
//  MVVideoCrayonPencilPartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-18.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoCrayonPencilPartialFilter.h"

@implementation MVVideoCrayonPencilPartialFilter

static NSString *const KMVVideoCrayonPencilPartialFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform int width;
 uniform int height;
 uniform float param;
 uniform float scale;
 void main()
 {
     vec4 grayMat = vec4(0.299,0.587,0.114,0.0);
     vec4 color = texture2D(inputImageTexture,  textureCoordinate);
     float g = dot(color,grayMat);
     float tx;
     float ty;
     mat3 rgb2yiq = mat3(0.299,-0.148,0.615,
                         0.587,-0.289,-0.515,
                         0.114,0.437,-0.1);
     mat3 yiq2rgb = mat3(1.0,1.0,1.0,
                         0.0,-0.395,2.032,
                         1.14,-0.581,0.0);

     tx = scale / float(width);
     ty = scale / float(height);
     vec4 tmp = vec4(0.01);
     vec4 c1;
     c1 = texture2D(inputImageTexture,  textureCoordinate + vec2(-tx,-ty));
     tmp = max(tmp,c1);
     c1 = texture2D(inputImageTexture,  textureCoordinate + vec2(tx,-ty));
     tmp = max(tmp,c1);
     c1 = color;
     tmp = max(tmp,c1);
     c1 = texture2D(inputImageTexture,  textureCoordinate + vec2(-tx,ty));
     tmp = max(tmp,c1);
     c1 = texture2D(inputImageTexture,  textureCoordinate + vec2(tx,ty));
     tmp = max(tmp,c1);

     float threshold = 57.0/255.0;
     g = clamp(g/threshold,0.0,1.0);

     vec4 dd;
     dd = color/tmp;//(color + (vec4(1.0)-tmp)*color/tmp);

     dd = mix(color,dd,g);//ratio*dd + (1.0 - ratio)*color;
     g = dot(grayMat,dd);
     g = clamp(g,0.0,1.0);//min(1.0,max(0.0,g));

     vec4 yiq;
     yiq.rgb = rgb2yiq*color.rgb;
     yiq.r =  clamp(pow(g,1.0+param*3.4),0.0,1.0);//max(min(pow(g, 2.7), 1.0), 0.0);

     vec4 instruct = texture2D(inputImageTexture2, textureCoordinate);

     gl_FragColor = mix(color, vec4(yiq2rgb*yiq.rgb,1.0), instruct.r);
 }
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:KMVVideoCrayonPencilPartialFilterFragmentShaderString];
    if (self) {
        [self setFloat:1.0 forUniformName:@"param"];
        [self setFloat:1.0 forUniformName:@"scale"];
        [self setInteger:480 forUniformName:@"width"];
        [self setInteger:480 forUniformName:@"height"];
    }
    return self;
}

@end
