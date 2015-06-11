//
//  MVVideoCurveFilter.m
//  microChannel
//
//  Created by aidenluo on 9/3/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoCurveFilter.h"

@interface MVVideoCurveFilter ()

@property(nonatomic) GLint matrixUniform;

@end

@implementation MVVideoCurveFilter

NSString *const kMVVideoCurveFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
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
     gl_FragColor = vec4(r,g,b,1.0);
 }
 );

+ (UIImage *)decodeImageByName:(NSString *)name
{
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"MVVideoEngine.bundle"];
    NSString *fullName = [bundlePath stringByAppendingPathComponent:name];
    NSData *data = [NSData dataWithContentsOfFile:fullName];
    // decode
    Byte *bytes = (Byte *)[data bytes];
    Byte *decodedBytes = (Byte *)malloc([data length]);
    memcpy(decodedBytes, bytes, [data length]);
    
    //temple added by deqiang, need remove latter
    //if(name != @"warmfilter.png" && name != @"abaofilter.png" && name != @"portraitbeauty.png")
    {
        for (int i = 0; i < 1024 && i < [data length]; i++) {
            Byte b = bytes[i];
            b = (b & 0x0F) << 4 | (b & 0xF0) >> 4;
            decodedBytes[i] = b;
        }
    }
    NSData *decoded = [NSData dataWithBytesNoCopy:decodedBytes length:[data length]];
    UIImage *image = [UIImage imageWithData:decoded];
    return image;
}

- (instancetype)initWithMatix:(GPUMatrix4x4)matrix resourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoCurveFilterFragmentShaderString];
    if (self) {
        _matrixUniform = [filterProgram uniformIndex:@"colorMat"];
        [self setFloat:1.0 forUniformName:@"rx"];
        [self setFloat:1.0 forUniformName:@"ry"];
        [self setFloat:0.0 forUniformName:@"tx"];
        [self setFloat:0.0 forUniformName:@"ty"];
        [self setMatrix4f:matrix forUniform:_matrixUniform program:filterProgram];
        _curveImage = image;
    }
    return self;
}

@end
