//
//  MVVideoTwirlFilter.m
//  microChannel
//
//  Created by aidenluo on 9/15/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoTwirlFilter.h"

@implementation MVVideoTwirlFilter

NSString *const kMVVideoTwirlFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform int width;
 uniform int height;
 void main()
 {
     float radius = 0.25*float(width) /1000.0;
     float scalewidth = float(width)/1000.0;
     float scaleheight = float(height)/1000.0;
     float twirlAngleRadians = 3.1415926 * 2.0 * (50.0 * 1.5/360.0);
     vec2 pos = vec2(textureCoordinate.x * scalewidth,textureCoordinate.y * scaleheight);
     vec2 cent = vec2(scalewidth/2.0,scaleheight/2.0);
     int gaussOrsinc = 0;
     vec2 relativePos = pos - cent;
     float distFromCenter = length(relativePos);
     distFromCenter /= radius;
     float adjustedRadians;
     float sincWeight = sin(distFromCenter) * twirlAngleRadians/distFromCenter;
     float gaussWeight = exp(-1.0*distFromCenter*distFromCenter)*twirlAngleRadians;
     adjustedRadians = (distFromCenter == 0.0)? twirlAngleRadians:sincWeight;
     adjustedRadians = (gaussOrsinc == 1)? adjustedRadians : gaussWeight;
     float cosAngle = cos(adjustedRadians);
     float sinAngle = sin(adjustedRadians);
     mat2 rotationMat = mat2(cosAngle,sinAngle,-sinAngle,cosAngle);
     relativePos = rotationMat * relativePos;
     relativePos += cent;
     relativePos.x /= scalewidth;
     relativePos.y /= scaleheight;
     gl_FragColor = texture2D(inputImageTexture,relativePos);
 }
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoTwirlFilterFragmentShaderString];
    if (self) {
        [self setInteger:480 forUniformName:@"width"];
        [self setInteger:480 forUniformName:@"height"];
    }
    return self;
}

@end
