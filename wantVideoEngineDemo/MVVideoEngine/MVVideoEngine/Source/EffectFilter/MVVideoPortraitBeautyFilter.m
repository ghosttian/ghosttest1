//
//  MVVideoPortraitBeautyFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoPortraitBeautyFilter.h"

@implementation MVVideoPortraitBeautyFilter

static NSString *const kPortraitBeautyQingXinMeiBaiFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 const float y_qingxinlinren = 0.4;
 void main()
 {
     vec4 color_raw = texture2D(inputImageTexture,textureCoordinate);
     float r;
     float g;
     float b;

     r = texture2D(inputImageTexture2, vec2(color_raw.r, y_qingxinlinren)).r;
     g = texture2D(inputImageTexture2, vec2(color_raw.g, y_qingxinlinren)).g;
     b = texture2D(inputImageTexture2, vec2(color_raw.b, y_qingxinlinren)).b;

     gl_FragColor = vec4(r, g, b, 1.0);
 }

 );

static NSString *const kPortraitBeautyTianMeiKeRenFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 const float y_tianmeikeren = 0.55;
 void main()
 {
     vec4 color_raw = texture2D(inputImageTexture,textureCoordinate);
     float r;
     float g;
     float b;

     r = texture2D(inputImageTexture2, vec2(color_raw.r, y_tianmeikeren)).r;
     g = texture2D(inputImageTexture2, vec2(color_raw.g, y_tianmeikeren)).g;
     b = texture2D(inputImageTexture2, vec2(color_raw.b, y_tianmeikeren)).b;

     gl_FragColor = vec4(r, g, b, 1.0);
 }

 );

static NSString *const kPortraitBeautyShenDuMeiBaiFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 const float y_shendumeibai = 0.7;
 void main()
 {
     vec3 color_raw = texture2D(inputImageTexture,textureCoordinate).rgb;
     float r;
     float g;
     float b;

     mat3 mat_down_sat = mat3(0.771, 0.201, 0.027,
                              0.102, 0.870, 0.027,
                              0.102, 0.201, 0.697);
     vec3 input_color = color_raw * mat_down_sat;
     r = texture2D(inputImageTexture2, vec2(input_color.r, y_shendumeibai)).r;
     g = texture2D(inputImageTexture2, vec2(input_color.g, y_shendumeibai)).g;
     b = texture2D(inputImageTexture2, vec2(input_color.b, y_shendumeibai)).b;
     gl_FragColor = vec4(r, g, b, 1.0);
 }

 );

static NSString *const kPortraitBeautyXiangYanHongChunFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 void main()
 {
     vec3 color_raw = texture2D(inputImageTexture,textureCoordinate).rgb;
     mat3 rgb2lab = mat3(0.212601, 0.715195, 0.072205,
                         0.325896, -0.49926,  0.173341,
                         0.121813, 0.378561, - 0.500374);
     mat3 lab2rgb = mat3(1.0, 2.093366, 0.869501,
                         1.0, -0.625923, -0.072385,
                         1.0, 0.036092, -1.843547);
     vec3 temp_color = color_raw * rgb2lab;
     temp_color.b = temp_color.g; // b = a
     temp_color = temp_color * lab2rgb;
     temp_color += vec3(-0.08, 0.02, 0.02);
     gl_FragColor = vec4(temp_color, 1.0);
 }

 );

static NSString *const kPortraitBeautyTianShengLiZhiFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 const float y_tianshenglizhi = 0.9;
 void main()
 {
     vec4 color_raw = texture2D(inputImageTexture,textureCoordinate);
     float r;
     float g;
     float b;

     r = texture2D(inputImageTexture2, vec2(color_raw.r, y_tianshenglizhi)).r;
     g = texture2D(inputImageTexture2, vec2(color_raw.g, y_tianshenglizhi)).g;
     b = texture2D(inputImageTexture2, vec2(color_raw.b, y_tianshenglizhi)).b;

     gl_FragColor = vec4(r, g, b, 1.0);
 }

 );

-(instancetype)initWithPicture:(UIImage *)image Type:(GPUImagePortraitBeautyFilterType)beautyType{

    NSString *shader = nil;
    switch (beautyType) {
        case BeautyType_QingXinLiRen:
            shader = kPortraitBeautyQingXinMeiBaiFragmentShaderString;
            break;
        case BeautyType_TianMeiKeRen:
            shader = kPortraitBeautyTianMeiKeRenFragmentShaderString;
            break;
        case BeautyType_ShenDuMeiBai:
            shader = kPortraitBeautyShenDuMeiBaiFragmentShaderString;
            break;
        case BeautyType_XiangYanHongChun:
            shader = kPortraitBeautyXiangYanHongChunFragmentShaderString;
            break;
        case BeautyType_TianShengLiZhi:
            shader = kPortraitBeautyTianShengLiZhiFragmentShaderString;
            break;
    }

    self = [super initWithFragmentShaderFromString:shader];
    if (self) {
        _beautyImage = image;
    }

    return self;
}

@end
