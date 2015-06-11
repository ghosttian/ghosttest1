//
//  MVVideoSkinRedFilter.m
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoSkinRedFilter.h"

@implementation MVVideoSkinRedFilter

NSString *const kMVVideoSkinRedFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
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
     temp_color.g = (temp_color.g + temp_color.b) * 0.5; // b = a
     temp_color = temp_color * lab2rgb;
     //     temp_color += vec3(0.0, 0.02, 0.02);
     
     float vmax = max(color_raw.r, color_raw.g);
     vmax = max(color_raw.b, vmax);
     float vmin = min(color_raw.r, color_raw.g);
     vmin = min(color_raw.b, vmin);
     float vgap = vmax - color_raw.r;
     vgap = clamp(vgap, 0.0, 1.0);
     
     temp_color *= (0.8 + (vmax - vmin) * 0.4 - vgap);
     temp_color = clamp(temp_color, 0.0, 1.0);
     
     gl_FragColor = vec4(temp_color, 1.0);
 }
 
 );

- (instancetype)init
{
    self = [self initWithFragmentShaderFromString:kMVVideoSkinRedFilterFragmentShaderString];
    if (self) {
        
    }
    return self;
}

@end
