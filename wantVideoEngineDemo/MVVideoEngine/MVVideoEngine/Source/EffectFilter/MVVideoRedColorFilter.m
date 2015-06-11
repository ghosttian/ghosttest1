//
//  MVVideoRedColorFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoRedColorFilter.h"

@implementation MVVideoRedColorFilter

NSString *const kMVVideoRedColorFragmentShaderString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 const  mat3  rgb2xyz = mat3(   0.4360747, 0.3850649, 0.1430804,
                             0.2225045, 0.7168786, 0.0606169,
                             0.0139322, 0.0971045, 0.7141733);

 const mat3 xyz2rgb = mat3(3.1338563, -1.6168667, -0.4906147,
                           -0.9787685, 1.9161415, 0.0334541,
                           0.0719451, -0.2289913, 1.4052427);

 const vec3 REF = vec3(96.4221, 100.00, 82.5211);
 const vec3 REF_INV = vec3(1.0/96.4221, 1.0/100.00, 1.0/82.5211);

 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate.xy);

     float x;
     float y;
     float z;

     float L;
     float A;
     float B;

     ///rgb to lab , based on Observer= 2°, Illuminant= D65
     {
         vec3 clr = color.rgb;
         vec3 exp1 = vec3(2.4);
         vec3 exp2 = vec3(0.33333);

         //0.947867 = 1.0 / 1.055
         clr = (clr + 0.055) * 0.947867;
         clr = pow(clr, exp1);

         vec3 res = clr * rgb2xyz * 100.0 * REF_INV;

         res = pow(res, exp2);
         x = res.r;
         y = res.g;
         z = res.b;

         L = ( 116.0 * y ) - 16.0;
         A = 500.0 * ( x - y );
         B = 200.0 * ( y - z );
     }

     //B = A;

     ////0.003922 = 1/255
     float x_L = (L + 127.0) * 0.003922;
     float x_A = (A + 127.0) * 0.003922;
     float x_B = (B + 127.0) * 0.003922;

     vec3 vecLab;
     float y_coord = 0.5;
     //vecLab.r = texture2D(inputImageTexture2, vec2(x_L , y_coord)).r;
     vecLab.g = texture2D(inputImageTexture2, vec2(x_A , y_coord)).g;
     vecLab.b = texture2D(inputImageTexture2, vec2(x_B , y_coord)).b;

     vecLab = vecLab * 255.0 - 128.0;

     //L = vecLab.r;
     A = vecLab.g;
     B = vecLab.b;

     if(A < 0.0)
         A *= 1.8;
     A = max(A, -78.0);

     L += 5.0;

     vec3 result = vecLab;
     ///lab to rgb , based on Observer= 2°, Illuminant= D65
     {
         ////0.008621 = 1/116.0
         y = (L + 16.0) * 0.008621;
         x = A * 0.002 + y;
         z = y - B * 0.005;

         vec3 exp3 = vec3(0.41666);
         vec3 tmp3 = vec3(x, y, z);
         vec3 res2 = tmp3 * tmp3 * tmp3 * REF * xyz2rgb * 0.01;

         result = 1.055 * pow(res2, exp3) - 0.055;
     }

     gl_FragColor = vec4(result, 1.0);

 }
);

- (instancetype)initWithResourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoRedColorFragmentShaderString];
    if (self) {
        [self setModelImage:image];
    }
    return self;
}

@end
