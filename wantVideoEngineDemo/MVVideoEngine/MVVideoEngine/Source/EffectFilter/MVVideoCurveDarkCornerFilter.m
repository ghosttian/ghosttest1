//
//  MVVideoCurveDarkCornerFilter.m
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoCurveDarkCornerFilter.h"

@interface MVVideoCurveDarkCornerFilter ()

@property(nonatomic) GLint matrixUniform;

@end

@implementation MVVideoCurveDarkCornerFilter

NSString *const kMVVideoCurveDarkCornerFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform float gradStart;
 uniform float gradEnd;
 uniform mat4 colorMat;
 uniform float rx;
 uniform float ry;
 uniform float tx;
 uniform float ty;
 void main()
 {
     vec4 color = colorMat*texture2D(inputImageTexture, textureCoordinate.xy);
     vec2 ratio = vec2(rx, ry);
     ratio = ratio * textureCoordinate.xy;
     ratio = ratio + vec2(tx, ty);
     float d = length(ratio - vec2(0.5,0.5));
     float alpha;
     d = clamp(d,gradStart,gradEnd);
     alpha = 1.0 - (d - gradStart)/(gradEnd - gradStart);
     color = color*alpha;
     float r;
     float g;
     float b;
     r = texture2D(inputImageTexture2,vec2(color.r,0.5)).r;
     g = texture2D(inputImageTexture2,vec2(color.g,0.5)).g;
     b = texture2D(inputImageTexture2,vec2(color.b,0.5)).b;
     gl_FragColor = vec4(r,g,b,1.0);
 }
 );

- (instancetype)initWithPicture:(UIImage *)image
                          Matix:(GPUMatrix4x4)matrix
                  gradientStart:(float)gStart
                    gradientEnd:(float)gEnd{
    self = [super initWithFragmentShaderFromString:kMVVideoCurveDarkCornerFilterFragmentShaderString];
    if (self) {
        _matrixUniform = [filterProgram uniformIndex:@"colorMat"];
        [self setFloat:gStart forUniformName:@"gradStart"];
        [self setFloat:gEnd forUniformName:@"gradEnd"];
        [self setFloat:1.0 forUniformName:@"rx"];
        [self setFloat:1.0 forUniformName:@"ry"];
        [self setFloat:0.0 forUniformName:@"tx"];
        [self setFloat:0.0 forUniformName:@"ty"];
        [self setMatrix4f:matrix forUniform:_matrixUniform program:filterProgram];
        _darkCornerImage = image;

    }
    return self;
}

@end
