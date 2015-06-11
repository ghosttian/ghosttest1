//
//  MVVideoColorPencilPartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoColorPencilPartialFilter.h"

@implementation MVVideoColorPencilPartialFilter

static NSString *const kMVVideoColorPencilPartialFragmentShaderString = SHADER_STRING
( precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform int width;
 uniform int height;
 uniform float param;
 uniform float scale;
 void main()
 {
     vec4 color;
     vec4 colorL;
     vec4 colorR;

     float ratio = 0.65;
     color = texture2D(inputImageTexture, textureCoordinate);

     float gray = dot(vec3(0.299,0.587,0.114),color.rgb);
     float tt = 0.3 + 0.9 * param;
     gray = tt* gray;
     gray = clamp(gray,0.01,0.8);

     float num = 6.0;
     float hatchFactor;
     hatchFactor= gray*num;
     float rat;
     rat = fract(hatchFactor);
     vec2 uv;
     vec2 coord = vec2(textureCoordinate.y, 1.0 - textureCoordinate.x);
     float md = scale * 256.0;
     uv = mod(coord*vec2(float(height),float(width)),vec2(md))/md;

     uv = vec2((uv.x + floor(hatchFactor))/num,uv.y);

     uv.x = clamp(uv.x,0.0,1.0);
     colorL = texture2D (inputImageTexture2, uv);

     uv = uv + vec2(1.0/num,0.0);
     uv.x = clamp(uv.x,0.0,1.0);
     colorR = texture2D (inputImageTexture2, uv);

     float x_step = scale / float(width);
     float y_step = scale / float(height);
     vec2 next;
     vec4 tmp = color;
     next = textureCoordinate.xy + vec2(x_step, -y_step);
     vec4 upC = texture2D(inputImageTexture, next);
     tmp = max(tmp,upC);

     next = textureCoordinate.xy + vec2(-x_step, y_step);
     vec4 downC = texture2D(inputImageTexture, next);
     tmp = max(tmp,downC);

     next = textureCoordinate.xy + vec2(-x_step, -y_step);
     vec4 leftC = texture2D(inputImageTexture, next);
     tmp = max(tmp,leftC);

     next = textureCoordinate.xy + vec2(x_step, y_step);
     vec4 rightC = texture2D(inputImageTexture, next);
     tmp = max(tmp,rightC);

     vec4 dd = color / (tmp + 0.01);
     dd = 0.85*mix(mix(colorL,colorR,rat),dd,gray);
     float g = dot(vec3(0.299,0.587,0.114),dd.rgb);

     vec4 colorF = vec4((1.0 - (1.0 - color.rgb)*(1.0 - g)),1.0);
     vec4 instruct = texture2D(inputImageTexture3, textureCoordinate);

     gl_FragColor = mix(color,colorF,instruct.r);

 }
 );

- (instancetype)initWithResourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoColorPencilPartialFragmentShaderString];
    if (self) {
        [self setModelImage:image];
        [self setFloat:1.0 forUniformName:@"param"];
        [self setFloat:1.0 forUniformName:@"scale"];
        [self setInteger:480 forUniformName:@"width"];
        [self setInteger:480 forUniformName:@"height"];
    }
    return self;
}

@end
