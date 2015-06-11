//
//  MVVideoColorAdjustmentFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoColorAdjustmentFilter.h"

@interface MVVideoColorAdjustmentFilter ()

@property(nonatomic) GLint matrixUniform;

@end

@implementation MVVideoColorAdjustmentFilter

static NSString *const kMVVideoColorAdjustmentFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;

 uniform mat4 colorMat;

 void main()
{
    vec4 newColor = colorMat*texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = newColor;
}
 
 );

- (instancetype)initWithMatix:(GPUMatrix4x4)matrix{
    self = [super initWithFragmentShaderFromString:kMVVideoColorAdjustmentFilterFragmentShaderString];
    if (self) {
        _matrixUniform = [filterProgram uniformIndex:@"colorMat"];
        [self setMatrix4f:matrix forUniform:_matrixUniform program:filterProgram];
    }
    return self;
}

@end
