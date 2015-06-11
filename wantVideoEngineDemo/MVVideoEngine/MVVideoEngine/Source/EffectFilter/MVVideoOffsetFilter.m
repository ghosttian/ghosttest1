//
//  MVVideoOffsetFilter.m
//  microChannel
//
//  Created by aidenluo on 9/1/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoOffsetFilter.h"

@implementation MVVideoOffsetFilter

NSString *const kMVVideoOffsetFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float mvOffsetX;
 uniform float mvOffsetY;
 uniform int mvFollowType;
 uniform float mvFollowGap;
 
 void main()
 {
     int useBlack = 0;
     vec2 pos = vec2(textureCoordinate.x - mvOffsetX, textureCoordinate.y - mvOffsetY);
     
     if(pos.x < 0.0){
         useBlack = 1;
         if(mvFollowType == 1){
             pos.x += mvFollowGap;
             if(pos.x < 0.0){
                 pos.x += 1.0;
                 if(pos.x >= 0.0){
                     useBlack = 0;
                 }
             }
         }
     } else if(pos.x > 1.0){
         useBlack = 1;
         if(mvFollowType == 1){
             pos.x -= 1.0 + mvFollowGap;
             if(pos.x >= 0.0 && pos.x <= 1.0){
                 useBlack = 0;
             }
         }
     }
     
     
     if(pos.y < 0.0){
         useBlack = 1;
         if(mvFollowType == 2){
             pos.y += mvFollowGap;
             if(pos.y < 0.0){
                 pos.y += 1.0;
                 if(pos.y >= 0.0){
                     useBlack = 0;
                 }
             }
         }
     }else if(pos.y > 1.0){
         useBlack = 1;
         if(mvFollowType == 2){
             pos.y -= 1.0 + mvFollowGap;
             if(pos.y >= 0.0 && pos.y <= 1.0){
                 useBlack = 0;
             }
         }
     }
     
     if(useBlack > 0){
         gl_FragColor = vec4(0.0 , 0.0 , 0.0 , 0.0);
     }else{
         gl_FragColor = texture2D(inputImageTexture,pos);
     }
     
 }
 
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kMVVideoOffsetFilterFragmentShaderString];
    if (self) {
        
    }
    return self;
}

- (void)setOffsetX:(float)offsetX
{
    _offsetX = offsetX;
    [self setFloat:_offsetX forUniformName:@"mvOffsetX"];
}

- (void)setOffsetY:(float)offsetY
{
    _offsetY = offsetY;
    [self setFloat:_offsetY forUniformName:@"mvOffsetY"];
}

- (void)setFollowType:(int)followType
{
    _followType = followType;
    [self setInteger:_followType forUniformName:@"mvFollowType"];
}

- (void)setFollowGap:(float)followGap
{
    _followGap = followGap;
    [self setFloat:_followGap forUniformName:@"mvFollowGap"];
}

@end
