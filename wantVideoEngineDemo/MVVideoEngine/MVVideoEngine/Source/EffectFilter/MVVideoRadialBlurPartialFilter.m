//
//  MVVideoRadialBlurPartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoRadialBlurPartialFilter.h"

@implementation MVVideoRadialBlurPartialFilter
NSString *const kMVVideoRadialBlurPartialFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 varying vec2 textureCoordinate;
 uniform float samples[10];
 uniform float separation;
 uniform float radius;
 uniform float x;
 uniform float y;

 void main(void)
{
    vec2 dir = vec2(x - textureCoordinate.x, y - textureCoordinate.y);
    float dist = sqrt(dir.x*dir.x + dir.y*dir.y);
    dir = dir/dist;
    vec4 color = texture2D(inputImageTexture, textureCoordinate);
    vec4 sum = color;
    for (int i = 0; i < 10; ++i)
    {
        sum += texture2D(inputImageTexture, textureCoordinate + dir * samples[i] * separation);
    }
    sum *= 1.0/11.0;
    float t = dist * radius * 8.9933;
    t = clamp(t, 0.0, 1.0);

    vec4 instruct = texture2D(inputImageTexture2, textureCoordinate);

    gl_FragColor = mix(color, mix(color, sum, t), instruct.r);
}
 
 );

- (instancetype)init{
    self = [super initWithFragmentShaderFromString:kMVVideoRadialBlurPartialFilterFragmentShaderString];
    if (self) {
        float samples[] = {-0.05f, -0.04f, -0.03f, -0.02f, -0.01f, 0.01f, 0.02f, 0.03f, 0.04f, 0.05f};
        [super setFloatArray:samples length:sizeof(samples) forUniform:@"samples"];
    }

    return self;
}

#pragma properties

- (void)setSeparation:(float)separation{
    _separation = separation;
    [self setFloat:separation forUniformName:@"separation"];
}

- (void)setRadius:(float)radius{
    _radius = radius;
    [self setFloat:radius forUniformName:@"radius"];
}

- (void)setX:(float)x{
    _x = x;
    [self setFloat:x forUniformName:@"x"];
}

- (void)setY:(float)y{
    _y = y;
    [self setFloat:y forUniformName:@"y"];
}

@end
