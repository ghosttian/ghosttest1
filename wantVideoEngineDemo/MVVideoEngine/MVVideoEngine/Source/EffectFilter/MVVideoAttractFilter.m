//
//  MVVideoAttractFilter.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoAttractFilter.h"

@implementation MVVideoAttractFilter

NSString *const kMVVideoAttractFragmentShaderString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 const vec3 rgb2xyz_1 = vec3(0.412453, 0.357580, 0.180423);
 const vec3 rgb2xyz_2 = vec3(0.212671, 0.715160, 0.072169);
 const vec3 rgb2xyz_3 = vec3(0.019334, 0.119193, 0.950227);

 const vec3 xyz2rgb_1 = vec3(3.2406, -1.5372, -0.4986);
 const vec3 xyz2rgb_2 = vec3(-0.9689, 1.8758, 0.0415);
 const vec3 xyz2rgb_3 = vec3(0.0557, -0.2040, 1.0570);
 const float REF_X = 95.0456; // Observer= 2°, Illuminant= D65
 const float REF_Y = 100.000;
 const float REF_Z = 108.8754;

 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate.xy);

     float x;
     float y;
     float z;

     float X;
     float Y;
     float Z;
     float L;
     float A;
     float B;

     float r = color.r;
     float g = color.g;
     float b = color.b;

     ///rgb to lab , based on Observer= 2°, Illuminant= D65
     {
         //0.947867 = 1.0 / 1.055
         r = pow((r + 0.055) * 0.947867, 2.4);
         g = pow((g + 0.055) * 0.947867, 2.4);
         b = pow((b + 0.055) * 0.947867, 2.4);


         vec3 tmp_rgb = vec3(r, g, b);
         tmp_rgb *= 100.0;
         X = dot(tmp_rgb, rgb2xyz_1);
         Y = dot(tmp_rgb, rgb2xyz_2);

         //0.010521 = 1/REF_X;
         //0.01 = 1/REF_Y
         x = pow( X*0.010521 , 0.33333 );
         y = pow( Y*0.01 , 0.33333 );


         L = ( 116.0 * y ) - 16.0;
         A = 500.0 * ( x - y );
     }

     B = A;

     if(A > 0.0);
     A*=1.2;

     if(B > 0.0)
         B *= 0.8;

     ////0.003922 = 1/255
     float x_L = (L + 127.0) * 0.003922;
     float x_AB = (A + 127.0) * 0.003922;


     float y_coord = 0.5;
     //L = texture2D(inputImageTexture2, vec2(x_L , y_coord)).r;
     A = texture2D(inputImageTexture2, vec2(x_AB , y_coord)).g;
     B = texture2D(inputImageTexture2, vec2(x_AB , y_coord)).b;


     //L = L * 255.0 - 128.0;
     A = A * 255.0 - 128.0;
     B = B * 255.0 - 128.0;

     //if(B > 2.0)
     //    A *= 1.8;

     //A = min(100.0, max(-100.0, A));

     if(A > 0.0)
         A *= 1.3;
     // A *= 2.0;

     //if(B > 0.0)
     //    B *= 0.5;

     //A = min(A, 128.0);


     ///lab to rgb , based on Observer= 2°, Illuminant= D65
     {
         ////0.008621 = 1/116.0
         y = (L + 16.0) * 0.008621;
         x = A * 0.002 + y;
         z = y - B * 0.005;

         X = x*x*x * REF_X;
         Y = y*y*y * REF_Y;
         Z = z*z*z * REF_Z;

         vec3 tmp_xyz = vec3(X, Y, Z);
         tmp_xyz *= 0.01;
         r = dot(tmp_xyz, xyz2rgb_1);
         g = dot(tmp_xyz, xyz2rgb_2);
         b = dot(tmp_xyz, xyz2rgb_3);


         r = 1.055 * pow( r , 0.41666 ) - 0.055;
         g = 1.055 * pow( g , 0.41666 ) - 0.055;
         b = 1.055 * pow( b , 0.41666 ) - 0.055;

     }

     //color = vec4(L, A, B, 1.0);
     gl_FragColor = vec4(r, g, b,1.0);
     
 }
 );

- (instancetype)initWithResourceImage:(UIImage *)image
{
    self = [super initWithFragmentShaderFromString:kMVVideoAttractFragmentShaderString];
    if (self) {
        [self setModelImage:image];
    }
    return self;
}

@end
