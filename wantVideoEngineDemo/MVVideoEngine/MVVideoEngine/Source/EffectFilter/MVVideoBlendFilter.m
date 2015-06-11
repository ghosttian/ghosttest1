//
//  MVVideoBlendFilter.m
//  microChannel
//
//  Created by aidenluo on 9/3/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoBlendFilter.h"

@interface MVVideoBlendFilter ()
@property (nonatomic, assign) MVVideoBlendFilterMode mode;
@end

@implementation MVVideoBlendFilter

NSString *const kMVVideoBlendFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 %@
 
 float func_mix(float A,float B){
     float c = 0.0;
     %@
     return c;
 }
 
 void main()
 {
     
     vec4 baseColor;
     if(mvReversed > 0){
         baseColor = func_movice_texture2D(textureCoordinate);
     }else{
         baseColor = texture2D(inputImageTexture, textureCoordinate);
     }
     
     if(mvCombineW == 0.0 || mvCombineH == 0.0){
         gl_FragColor = baseColor;
         return;
     }
     
     vec2 pos = textureCoordinate;
     pos.x -= mvCombineX;
     pos.y -= mvCombineY;
     if(pos.x < 0.0 || pos.x > max(mvCombineW, -mvCombineW)||
        pos.y < 0.0 || pos.y > max(mvCombineH, -mvCombineH) ){
         gl_FragColor = baseColor;
         return;
     }
     
     pos.x /= mvCombineW;
     pos.y /= mvCombineH;
     if(pos.x < 0.0){
         pos.x += 1.0;
     }
     if(pos.y < 0.0){
         pos.y += 1.0;
     }
     pos = clamp(pos, 0.0, 1.0);
     
     vec4 movColor;
     if(mvReversed > 0){
         movColor = texture2D(inputImageTexture, pos);
     }else{
         movColor = func_movice_texture2D(pos);
     }
     
     movColor = movColor * mvCombineAlpha;
     
     
     %@
     
     
 }
 );

- (instancetype)initWithBlendMode:(MVVideoBlendFilterMode)mode
{
    NSString* first_shader = SHADER_STRING
    (
     uniform sampler2D inputImageTexture2;
     
     uniform float mvCombineX;
     uniform float mvCombineY;
     uniform float mvCombineW;
     uniform float mvCombineH;
     uniform float mvCombineAlpha;
     uniform int mvReversed;
     
     vec4 func_movice_texture2D(vec2 pos){
         return texture2D(inputImageTexture2, pos);
     }
     
     );
    
    NSString *second_shader = @"c = A + B - A*B;";
    
    NSString* third_shader = SHADER_STRING
    (
     vec4 finalColor = vec4(
                            func_mix(baseColor.r, movColor.r),
                            func_mix(baseColor.g, movColor.g),
                            func_mix(baseColor.b, movColor.b),
                            1.0);
     gl_FragColor = finalColor;
     
     );
    
    switch (mode) {
        case MVVideoBlendFilterModeScreen:
        {
            second_shader = @"c = A + B - A*B;";
            break;
        }
        case MVVideoBlendFilterModeLuminance:
        {
            third_shader = SHADER_STRING
            (
             vec4 finalColor;
             float f = dot(baseColor.rgb, vec3(0.2125, 0.7154, 0.0721));
             finalColor = vec4(f,f,f,1.0);
             f = dot(movColor.rgb, vec3(0.2125, 0.7154, 0.0721));
             gl_FragColor = mix(baseColor, finalColor, f);
             );
            break;
        }
        case MVVideoBlendFilterModeBrightness:
        {
            third_shader = SHADER_STRING
            (
             vec4 finalColor;
             float f = baseColor.b;
             if(baseColor.r > baseColor.g){
                 f = max(baseColor.r, f) + min(baseColor.g, f);
             }else{
                 f = max(baseColor.g, f) + min(baseColor.r, f);
             }
             f *= 0.5;
             finalColor = vec4(f,f,f,1.0);
             f = dot(movColor.rgb, vec3(0.2125, 0.7154, 0.0721));
             gl_FragColor = mix(baseColor, finalColor, f);
             );
            break;
        }
        case MVVideoBlendFilterModeMix:
        {
            third_shader = SHADER_STRING
            (
             gl_FragColor = movColor + (1.0 - movColor.a) * baseColor;
             );
            break;
        }
        case MVVideoBlendFilterModeFill:
        {
//            second_shader = @"c = B;";
//			c = A * (1.0 - a) + B * a; //a = 1 表示不透明
			third_shader = SHADER_STRING
			(
				 vec4 finalColor = baseColor *( 1.0 - mvCombineAlpha ) + movColor * mvCombineAlpha;
				 gl_FragColor = finalColor;
			);

            break;
        }
        case MVVideoBlendFilterModeMin:
        {
            second_shader = @"c = min(A,B);";
            break;
        }
        case MVVideoBlendFilterModeMax:
        {
            second_shader = @"c = max(A,B);";
            break;
        }
        case MVVideoBlendFilterModeMultipy:
        {
            second_shader = @"c = A * B;";
            break;
        }
        case MVVideoBlendFilterModeHardLight:
        {
            second_shader = SHADER_STRING
            (
             if (B <= 0.5){
                 c=B*(2.0*A);
             } else {
                 c=1.0-(1.0-B)*2.0*(1.0-A);
             }
             );
            break;
        }
        case MVVideoBlendFilterModeSoftLight:
        {
            second_shader = SHADER_STRING
            (
             if (B <= 0.5){
                 c=A+(2*B-1.0)*(A-pow(A,2));
             } else {
                 c=A+(2*B-1.0)*(pow(A,0.5)-A);
             }
             );
            break;
        }
        case MVVideoBlendFilterModeVividLight:
        {
            second_shader = SHADER_STRING
            (
             if (B <= 0.5){
                 c=1.0-(1.0-A)/(2.0*B);
             } else {
                 c=A/(2.0*(1.0-B));
             }
             );
            break;
        }
        case MVVideoBlendFilterModeOverlay:
        {
            second_shader = SHADER_STRING
            (
             if (A <= 0.5){
                 c=B*(2.0*A);
             } else {
                 c=1.0-(1.0-B)*2.0*(1.0-A);
             }
             );
            break;
        }
        case MVVideoBlendFilterModeMinus:
        {
            second_shader = SHADER_STRING
            (
             if(A > B){
                 c = A - B;
             }else{
                 c = B - A;
             }
             );
            break;
        }
        case MVVideoBlendFilterModeLiner:
        {
            second_shader = SHADER_STRING(
                                          c = A + B - 1.0;
                                          );
            break;
        }
        case MVVideoBlendFilterModeLighten:
        {
            second_shader = SHADER_STRING
            (
             if(A <= B){
                 c = B;
             }else{
                 c = A;
             }
             );
            break;
        }
        case MVVideoBlendFilterModeDarken:
        {
            second_shader = SHADER_STRING
            (
             if(A <= B){
                 c = A;
             }else{
                 c = B;
             }
             );
            break;
        }
        case MVVideoBlendFilterModeOnlyWhite:
        {
            third_shader = SHADER_STRING
            (
             if(movColor.r >= 0.8 && movColor.g >= 0.8 && movColor.b >= 0.8) {
                 gl_FragColor = baseColor;
             } else {
                 gl_FragColor = movColor;
             }
            );
            break;
        }
        case MVVideoBlendFilterModeOnlyBlack:
        {
            third_shader = SHADER_STRING
            (
             if(movColor.r <= 0.2 && movColor.g <= 0.2 && movColor.b <= 0.2) {
                 gl_FragColor = baseColor;
             } else {
                 gl_FragColor = movColor;
             }
             );
            break;
        }
    }
    NSString *finalFragmentShader = [NSString stringWithFormat:kMVVideoBlendFilterFragmentShaderString,first_shader,second_shader,third_shader];
    self = [super initWithFragmentShaderFromString:finalFragmentShader];
    if (self) {
		self.mode = mode;
        [self setAlpha:0.0];
        [self setX:0.0];
        [self setY:0.0];
        [self setWidth:1.0];
        [self setHeight:1.0];
        [self setReversed:0];
    }
    return self;
}

- (void)setAlpha:(float)alpha
{
    _alpha = alpha;
    [self setFloat:_alpha forUniformName:@"mvCombineAlpha"];
}

- (void)setX:(float)x
{
    _x = x;
    [self setFloat:_x forUniformName:@"mvCombineX"];
}

- (void)setY:(float)y
{
    _y = y;
    [self setFloat:_y forUniformName:@"mvCombineY"];
}

- (void)setWidth:(float)width
{
    _width = width;
    [self setFloat:_width forUniformName:@"mvCombineW"];
}

- (void)setHeight:(float)height
{
    _height = height;
    [self setFloat:_height forUniformName:@"mvCombineH"];
}

- (void)setReversed:(int)reversed
{
    _reversed = reversed;
    [self setInteger:_reversed forUniformName:@"mvReversed"];
}

@end
