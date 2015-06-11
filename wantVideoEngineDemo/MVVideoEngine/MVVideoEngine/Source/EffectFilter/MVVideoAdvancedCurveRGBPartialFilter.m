//
//  MVVideoAdvancedCurveRGBPartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoAdvancedCurveRGBPartialFilter.h"

@implementation MVVideoAdvancedCurveRGBPartialFilter

static NSString *const kMVVideoAdvancedCurveRGBPartialFilterFragmentShaderString = SHADER_STRING
(

 precision mediump float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;

 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float blueColor = textureColor.b * 63.0;
     vec2 quad1;
     quad1.y = floor(floor(blueColor) / 8.0);
     quad1.x = floor(blueColor) - (quad1.y * 8.0);
     vec2 quad2;
     quad2.y = floor(ceil(blueColor) / 8.0);
     quad2.x = ceil(blueColor) - (quad2.y * 8.0);
     highp vec2 texPos1;
     texPos1.x = (quad1.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.r);
     texPos1.y = (quad1.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.g);
     highp vec2 texPos2;
     texPos2.x = (quad2.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.r);
     texPos2.y = (quad2.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.g);
     vec4 newColor1 = texture2D(inputImageTexture2, texPos1);
     vec4 newColor2 = texture2D(inputImageTexture2, texPos2);
     vec4 newColor = mix(newColor1, newColor2, fract(blueColor));

     vec4 instruct = texture2D(inputImageTexture3, textureCoordinate);
     gl_FragColor = mix(textureColor,newColor,instruct.r);
 }

 );

-(instancetype)initWithPicture:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoAdvancedCurveRGBPartialFilterFragmentShaderString];
    if (self) {
        _curveImage = image;
    }
    return self;
}

@end
