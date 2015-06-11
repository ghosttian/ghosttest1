//
//  MVVIdeoSCBPartialFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVIdeoSCBPartialFilter.h"

@implementation MVVIdeoSCBPartialFilter
static NSString *const KMVVideoSCBPartialFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform float contrast;
 uniform float saturation;
 uniform float brightness;
 const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 temp_FragColor = vec4(((textureColor.rgb - vec3(0.5)) * contrast + vec3(0.5)), textureColor.w);


     float luminance = dot(temp_FragColor.rgb, luminanceWeighting);
     vec3 greyScaleColor = vec3(luminance);
     temp_FragColor = vec4(mix(greyScaleColor, temp_FragColor.rgb, saturation), temp_FragColor.w);


     float h = 0.0;
     float s = 0.0;
     float v = 0.0;
     float c_max = max(temp_FragColor.r, max(temp_FragColor.g, temp_FragColor.b));
     float c_min = min(temp_FragColor.r, max(temp_FragColor.g, temp_FragColor.b));
     if (temp_FragColor.r == c_max)
     {
         h = (temp_FragColor.g-temp_FragColor.b)/(c_max-c_min);
     }
     else if (temp_FragColor.g == c_max)
     {
         h = 2.0 + (temp_FragColor.b-temp_FragColor.r)/(c_max-c_min);
     }
     else
     {
         h = 4.0 + (temp_FragColor.r-temp_FragColor.g)/(c_max-c_min);
     }
     h *= 60.0;
     if (h < 0.0)
     {
         h += 360.0;
     }
     s = (c_max-c_min)/c_max;
     v =	c_max;

     float r = 0.0;
     float g = 0.0;
     float b = 0.0;
     v *= brightness;
     if (v > 1.0)
     {
         v = 1.0;
     }

     if (s == 0.0)
     {
         r = g = b = v;
     }
     else
     {
         h /= 60.0;
         int i = int(h);
         float f = h - float(i);
         float a1 = v * (1.0 - s);
         float b1 = v * (1.0 - s * f);
         float c1 = v * (1.0 - s * (1.0 - f));

         if (i == 0)
         {
             r = v; g = c1; b = a1;
         }
         else if (i == 1)
         {
             r = b1; g = v; b = a1;
         }
         else if (i == 2)
         {
             r = r = a1; g = v; b = c1;
         }
         else if (i == 3)
         {
             r = r = a1; g = b1; b = v;
         }
         else if (i == 4)
         {
             r = r = c1; g = a1; b = v;
         }
         else
         {
             r = v; g = a1; b = b1;
         }
     }
     vec4 instruct = texture2D(inputImageTexture2, textureCoordinate);

     gl_FragColor = mix(textureColor, vec4(r, g, b, 1.0), instruct.r);
 }
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:KMVVideoSCBPartialFilterFragmentShaderString];
    if (self) {

    }
    return self;
}

- (void)setFilterContrast:(float)contrast
{
    [self setFloat:contrast forUniformName:@"contrast"];
}

- (void)setSaturation:(float)saturation
{
    [self setFloat:saturation forUniformName:@"saturation"];
}

- (void)setBrightness:(float)brightness
{
    [self setFloat:brightness forUniformName:@"brightness"];
}
@end
