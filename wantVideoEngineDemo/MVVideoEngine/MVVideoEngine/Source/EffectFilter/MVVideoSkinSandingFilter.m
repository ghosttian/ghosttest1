//
//  MVVideoSkinSandingFilter.m
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoSkinSandingFilter.h"

@implementation MVVideoSkinSandingFilter

#define Texture0 inputImageTexture
#define Texture1 inputImageTexture2
#define texCoord textureCoordinate
#define blur_texture(x, y) texture2D(Texture0, texCoord + smoothSize * vec2(x,y))
#define init_texture(x, y) texture2D(Texture0, texCoord + vec2(x,y))

NSString *const kMVVideoSkinSandingFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform int width;
 uniform int height;
 uniform float curve[256];
 uniform float mvSmoothSize;
 uniform float mvBlurDegree;
 
 float mv_green_mix(float g1, float g2)
 {
     float g = g2 + 1.0 - 2.0 * g1;
     g = clamp(g, 0.0, 1.0);
     return mix(g, g2, 0.5);
 }
 
 float mv_high_mix(float hg, float flag)
 {
     float g = clamp(hg, 0.0001, 0.9999);
     return mix(g/(2.0*(1.0-g)), 1.0 - (1.0-g)/(2.0*g), flag);
 }
 
 void main(void)
{
    vec4 init_color = texture2D(inputImageTexture, textureCoordinate);
    
    float smoothSize = mvSmoothSize * 0.02;
    vec4
    blur_color  = blur_texture(-0.326212, -0.405805);//
    blur_color += blur_texture(-0.840144, -0.073580);
    blur_color += blur_texture(-0.203345,  0.620716);//
    blur_color += blur_texture( 0.962340, -0.194983);
    blur_color += blur_texture( 0.519456,  0.767022);//
    blur_color += blur_texture( 0.185461, -0.893124);
    blur_color += blur_texture( 0.896420,  0.412458);
    blur_color += blur_texture(-0.321940, -0.932615);
    
    blur_color += blur_texture(-0.695914,  0.457137);//
    blur_color += blur_texture( 0.473434, -0.480026);//
    blur_color += blur_texture( 0.507431,  0.064425);
    blur_color += blur_texture(-0.791559, -0.597705);//
    
    blur_color /= 12.0;
    
    ///highpass
    float hg = mv_green_mix(blur_color.g, init_color.g);
    
    float flag = step(hg, 0.5);
    hg = mv_high_mix(hg, flag);
    hg = mv_high_mix(hg, flag);
    hg = mv_high_mix(hg, flag);
    
    hg = clamp(hg, 0.0, 1.0);
    if(hg > 0.2){
        hg = pow((hg - 0.2) * 1.25, 0.5)/1.25 + 0.2;
    }
    hg = 1.0 - hg;
    
    vec4 high_color;
    high_color.a = 1.0;
    high_color.r = curve[int(init_color.r*255.0)];
    high_color.g = curve[int(init_color.g*255.0)];
    high_color.b = curve[int(init_color.b*255.0)];
    
    smoothSize = mvSmoothSize * 0.2 + 0.2;
    high_color = (init_color + smoothSize * hg * (high_color - init_color));
    
    ///overlap
    float tx = 1.0 / float(width);
    float ty = 1.0 / float(height);
    float
    lg =  init_texture(-tx,0.0).g;
    lg += init_texture(tx,0.0).g;
    lg += init_texture(0.0,-ty).g;
    lg += init_texture(0.0,ty).g;
    lg = init_color.g * 0.5 + lg * 0.125;
    
    float a = mv_green_mix(lg, init_color.g);
    
    flag = step(0.5, a);
    init_color = mix((2.0 * a * high_color),
                     (1.0 - 2.0 * (1.0-a) * (1.0-high_color)),
                     flag);
    high_color = mix(init_color, high_color, 0.1);
    
    gl_FragColor = mix(high_color, blur_color, mvBlurDegree);
}
 
);

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoSkinSandingFilterFragmentShaderString];
    if (self) {
        static float curve[] = {0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22,24,25,27,28,30,31,33,34,36,37,39,40,42,43,45,46,47,49,50,52,53,55,56,58,59,61,62,63,65,66,68,69,71,72,73,75,76,78,79,80,82,83,85,86,87,89,90,92,93,94,96,97,98,100,101,102,104,105,106,108,109,110,112,113,114,116,117,118,119,121,122,123,125,126,127,128,130,131,132,133,134,136,137,138,139,140,142,143,144,145,146,147,149,150,151,152,153,154,155,156,157,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,181,182,183,184,185,186,187,188,188,189,190,191,192,193,193,194,195,196,197,197,198,199,200,201,201,202,203,204,204,205,206,207,207,208,209,209,210,211,211,212,213,213,214,215,215,216,217,217,218,219,219,220,221,221,222,222,223,224,224,225,226,226,227,227,228,228,229,230,230,231,231,232,232,233,234,234,235,235,236,236,237,237,238,238,239,240,240,241,241,242,242,243,243,244,244,245,245,246,246,247,247,248,248,249,249,250,250,251,251,252,252,253,253,254,254,255};
        if (curve[10] > 2.0) {
            for (int i=0; i<256; i++) {
                curve[i] = curve[i] / 255.0;
            }
        }
        [self setFloatArray:curve length:256 forUniform:@"curve"];
        [self setFloat:0.7 forUniformName:@"mvSmoothSize"];
        [self setFloat:0.01 forUniformName:@"mvBlurDegree"];
        [self setInteger:480 forUniformName:@"width"];
        [self setInteger:480 forUniformName:@"height"];
    }
    return self;
}

@end
