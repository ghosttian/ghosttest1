//
//  MVVideoCurveRGBPartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoCurveRGBPartialFilter.h"

@implementation MVVideoCurveRGBPartialFilter

static NSString *const kMVVideoCurveRGBPartialFilterFragmentShaderString = SHADER_STRING
(

 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform int filterWithAlpha;

 void main()
 {
     vec4 color =  texture2D(inputImageTexture, textureCoordinate);
     vec4 color2 = vec4(texture2D(inputImageTexture2, vec2(color.r,0.0)).r,
                         texture2D(inputImageTexture2, vec2(color.g,0.0)).g,
                         texture2D(inputImageTexture2, vec2(color.b,0.0)).b,
                         1.0);

     vec4 instruct = texture2D(inputImageTexture3, textureCoordinate);
     gl_FragColor = mix(color,color2,instruct.r);
 }

 );

static NSString *const kMVVideoCurveRGBPartialFilterWithCutFragmentShaderString = SHADER_STRING
(

 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
  uniform sampler2D inputImageTexture3;
 uniform int filterWithAlpha;

 void main()
 {
     vec4 color =  texture2D(inputImageTexture, textureCoordinate);
     vec4 color2;
     float alpha = texture2D(inputImageTexture2, vec2(textureCoordinate.x, 1.0 - textureCoordinate.y)).a;
     if(alpha < 1.0){
         if(alpha <= 0.005){
             alpha = 0.0;
         }
         color2 = mix(vec4(texture2D(inputImageTexture2, vec2(color.r,0.0)).r,
                          texture2D(inputImageTexture2, vec2(color.g,0.0)).g,
                          texture2D(inputImageTexture2, vec2(color.b,0.0)).b,
                          1.0), color, alpha);
     }

     vec4 instruct = texture2D(inputImageTexture3, textureCoordinate);
     gl_FragColor = mix(color,color2,instruct.r);
 }

 );

-(instancetype)initWithCut:(BOOL)cutWithAlpha picture:(UIImage *)image
{
    if (cutWithAlpha) {
        self = [super initWithFragmentShaderFromString:kMVVideoCurveRGBPartialFilterWithCutFragmentShaderString];
    } else {
        self = [super initWithFragmentShaderFromString:kMVVideoCurveRGBPartialFilterFragmentShaderString];
    }
    if (self) {
        self.curveImage = image;
    }
    return self;
}

@end
