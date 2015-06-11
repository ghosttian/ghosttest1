//
//  MVVideoFantasyFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoFantasyFilter.h"

@interface MVVideoFantasyFilter ()

@property(nonatomic) GLint matrixUniform;

@end

@implementation MVVideoFantasyFilter

NSString *const kMVVideoFantasyFragmentShaderString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform int width;
 uniform int height;
 uniform mat4 colorMat;
 uniform float satChange;

 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate.xy);
     vec4 c1;
     vec4 c2;
     vec3 hsv;
     c1.r = texture2D(inputImageTexture2, vec2(color.r,0.1)).r;
     c1.g = texture2D(inputImageTexture2, vec2(color.g,0.1)).g;
     c1.b = texture2D(inputImageTexture2, vec2(color.b,0.1)).b;
     c1.a = 1.0;

     c1 = colorMat*c1;

     c2.r = texture2D(inputImageTexture2, vec2(c1.r,0.9)).r;
     c2.g = texture2D(inputImageTexture2, vec2(c1.g,0.9)).g;
     c2.b = texture2D(inputImageTexture2, vec2(c1.b,0.9)).b;

     gl_FragColor = vec4(c2.rgb,1.0);
 }
);

- (instancetype)initWithResourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoFantasyFragmentShaderString];
    if (self) {
        [self setModelImage:image];

        self.matrixUniform = [filterProgram uniformIndex:@"colorMat"];
        GPUMatrix4x4 matrix = { 0.1993f + 0.3333f, 0.1993f, 0.1993f, 0, 0.391f, 0.391f + 0.3333f, 0.391f, 0, 0.076f, 0.076f, 0.076f + 0.3333f, 0, 0, 0, 0, 1 };
        [self setMatrix4f:matrix forUniform:self.matrixUniform program:filterProgram];
    }
    return self;
}

@end
