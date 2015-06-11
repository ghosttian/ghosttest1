//
//  MVVideoOldFilmFilter.m
//  microChannel
//
//  Created by aidenluo on 9/11/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoOldFilmFilter.h"

@implementation MVVideoOldFilmFilter

NSString *const kMVVideoOldFilmFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform vec2 randomCoord1;
 uniform vec2 randomCoord2;
 uniform float fluc;
 uniform float rx;
 uniform float ry;
 uniform float tx;
 uniform float ty;
 uniform float sx;
 uniform float sy;
 void main()
 {
     const float noiseFactor = 0.3;
     const float scratchFactor = .5;//024;
     const float scratchFactorInverse = 1.0 / scratchFactor;
     const vec3 lumcoeff = vec3(0.299, 0.587, 0.114);
     const vec3 sepiatone = vec3(0.9, 0.8, 0.6);
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     //
     vec2 ratio = vec2(rx, ry);
     ratio = ratio * textureCoordinate.xy;
     ratio = ratio + vec2(tx, ty);
     
     // Calculate random coord + sample
     vec2 rd1 = randomCoord1 * vec2(sx, sy);
     vec2 rd2 = randomCoord2 * vec2(sx, sy);
     vec2 rCoord = (ratio + rd1 + rd2) * 0.33;
     vec4 rand = texture2D(inputImageTexture2, rCoord);
     float s = step(0.0,noiseFactor - rand.r);
     color.rgb = mix(color.rgb,vec3(0.1 + rand.b * 0.4),s);//(1.0-s)*color.rgb + s*vec3(0.1 + rand.b * 0.4);
     
     float f1_in = step(rd1.y,0.02);
     float f2_in = step(rd2.y,0.016);
     float abs1 = 1.0+f1_in*step(abs(rd1.x - ratio.y),0.002);
     float abs2 = 1.0+f2_in*step(abs(rd2.x - ratio.x),0.002);
     
     color.rgb = color.rgb*abs1*abs2;
     
     // Convert to grayscale
     float gray = dot(color.rgb, lumcoeff);
     // To sepiatone
     color = vec4(gray * sepiatone, 1.0);
     // Sepia original (0.9, 0.7, 0.3)
     // Calc distance to center
     vec2 dist = 0.5 - ratio;
     // Random light fluctuation
     //float fluc = randomCoord2.x * 0.04;
     // Vignette effect
     color.rgb *= (0.38 + fluc - dot(dist, dist))  * 2.8;
     gl_FragColor = color;
 }
 );

- (instancetype)initWithResourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoOldFilmFragmentShaderString];
    if (self) {
        [self setCurveImage:image];
        [self setFloat:1.0 forUniformName:@"rx"];
        [self setFloat:1.0 forUniformName:@"ry"];
        [self setFloat:0.0 forUniformName:@"tx"];
        [self setFloat:0.0 forUniformName:@"ty"];
        [self setFloat:1.0 forUniformName:@"sx"];
        [self setFloat:1.0 forUniformName:@"sy"];
    }
    return self;
}

- (void)setNosiyPoint1:(CGPoint)nosiyPoint1
{
    [self setPoint:nosiyPoint1 forUniformName:@"randomCoord1"];
}

- (void)setNosiyPoint2:(CGPoint)nosiyPoint2
{
    [self setPoint:nosiyPoint2 forUniformName:@"randomCoord2"];
}

- (void)setFluc:(float)fluc
{
    [self setFloat:fluc forUniformName:@"fluc"];
}

@end
