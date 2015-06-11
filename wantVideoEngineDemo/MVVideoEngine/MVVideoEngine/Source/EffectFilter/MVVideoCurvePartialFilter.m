//
//  MVVideoCurvePartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoCurvePartialFilter.h"

@interface MVVideoCurvePartialFilter ()

@property(nonatomic) GLint matrixUniform;

@end

@implementation MVVideoCurvePartialFilter

NSString *const kMVVideoCurvePartialFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
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

     float d = 1.0 - length(ratio - vec2(0.5,0.5))*1.4142;
     float r;
     float g;
     float b;
     r = texture2D(inputImageTexture2, vec2(color.r,d)).r;
     g = texture2D(inputImageTexture2, vec2(color.g,d)).g;
     b = texture2D(inputImageTexture2, vec2(color.b,d)).b;

     vec4 instruct = texture2D(inputImageTexture3, textureCoordinate);
     vec4 color2 = texture2D(inputImageTexture, textureCoordinate);

     gl_FragColor = mix(color2, vec4(r, g, b, 1.0), instruct.r);

 }
);

- (instancetype)initWithMatix:(GPUMatrix4x4)matrix resourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoCurvePartialFilterFragmentShaderString];
    if (self) {
        self.matrixUniform = [filterProgram uniformIndex:@"colorMat"];
        [self setFloat:1.0 forUniformName:@"rx"];
        [self setFloat:1.0 forUniformName:@"ry"];
        [self setFloat:0.0 forUniformName:@"tx"];
        [self setFloat:0.0 forUniformName:@"ty"];
        [self setMatrix4f:matrix forUniform:self.matrixUniform program:filterProgram];
        self.curveImage = image;
    }
    return self;
}

@end
