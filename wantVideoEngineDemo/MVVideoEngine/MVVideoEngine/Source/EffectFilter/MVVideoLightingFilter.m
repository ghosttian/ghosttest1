//
//  MVVideoLightingFilter.m
//  MVVideoEngine
//
//  Created by eson on 14-12-12.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoLightingFilter.h"
#import "GPUImageTwoInputFilter.h"


@interface MVVideoLightingStep1Filter : GPUImageFilter
@property (nonatomic, assign) float scode;
@end


@implementation MVVideoLightingStep1Filter

- (instancetype)init
{
	static NSString *kMVVideoLightingStep1FilterFragmentShaderString;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		char filter_glow_step1[] =
		"precision highp float;\n"
		"varying vec2 textureCoordinate;\n"
		"uniform sampler2D inputImageTexture;\n"
		"uniform float scode;\n"
		
		"vec3 rgb2hsv1(vec3 c)\n"
		"{\n"
		"    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);\n"
		"    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));\n"
		"    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));\n"
		
		"    float d = q.x - min(q.w, q.y);\n"
		"    float e = 1.0e-10;\n"
		"    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);\n"
		"}\n"
		
		"void main()\n"
		"{\n"
		"	vec4 color =  texture2D(inputImageTexture, textureCoordinate);\n"
		"	vec3 newColor = rgb2hsv1(color.xyz);\n"
		"	if (newColor.z > (1.0-scode)) {\n"
		"		gl_FragColor = color;\n"
		"	} else {\n"
		"     gl_FragColor = vec4(0.0);\n"
		"   }\n"

		"}\n";

		kMVVideoLightingStep1FilterFragmentShaderString = [NSString stringWithUTF8String:filter_glow_step1];
	});

	if (!(self = [super initWithFragmentShaderFromString:kMVVideoLightingStep1FilterFragmentShaderString]))
	{
		return nil;
	}
	self.scode = 1;

	return self;
}

- (void)setScode:(float)scode
{
	_scode = scode;
	[self setFloat:scode forUniformName:@"scode"];
}

@end

@interface MVVideoLightingStep2Filter : GPUImageFilter

@property(readwrite, nonatomic) CGFloat blurSize;

@end

@implementation MVVideoLightingStep2Filter

- (instancetype)init
{
	static NSString *kMVVideoLightingStep2FilterFragmentShaderString;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		char filter_glow_step2[] =
		"precision highp float;\n"
		"varying vec2 textureCoordinate;\n"
		"uniform sampler2D inputImageTexture;\n"
		"uniform float mvBlurSize; \n"
		
		"void main()\n"
		"{\n"
		"	vec4 avgColor =  texture2D(inputImageTexture, textureCoordinate);\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 1.0*mvBlurSize , textureCoordinate.y));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 1.0*mvBlurSize , textureCoordinate.y));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 0.707*1.0*mvBlurSize , textureCoordinate.y + 0.707*1.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 0.707*1.0*mvBlurSize , textureCoordinate.y - 0.707*1.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 2.0*mvBlurSize , textureCoordinate.y));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 2.0*mvBlurSize , textureCoordinate.y));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 0.707*2.0*mvBlurSize , textureCoordinate.y + 0.707*2.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 0.707*2.0*mvBlurSize , textureCoordinate.y - 0.707*2.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 3.0*mvBlurSize , textureCoordinate.y));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 3.0*mvBlurSize , textureCoordinate.y));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 0.707*3.0*mvBlurSize , textureCoordinate.y + 0.707*3.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 0.707*3.0*mvBlurSize , textureCoordinate.y - 0.707*3.0*mvBlurSize));\n"
		"   gl_FragColor = avgColor / 13.0;\n"
		"}\n";
		
		kMVVideoLightingStep2FilterFragmentShaderString = [NSString stringWithUTF8String:filter_glow_step2];
	});
	
	if (!(self = [super initWithFragmentShaderFromString:kMVVideoLightingStep2FilterFragmentShaderString]))
	{
		return nil;
	}
	self.blurSize = 0;
	
	return self;
}


- (void)setBlurSize:(CGFloat)blurSize
{
	_blurSize = blurSize;
	[self setFloat:_blurSize forUniformName:@"mvBlurSize"];
}


@end

@interface MVVideoLightingStep3Filter : GPUImageTwoInputFilter

// exposure ranges from -1.0 to 1.0, with 0.0 as the normal level
@property(readwrite, nonatomic) CGFloat exposure;

@property(readwrite, nonatomic) CGFloat blurSize;

@end

@implementation MVVideoLightingStep3Filter

- (id)init;
{
	static NSString *kMVVideoLightingStep3FilterFragmentShaderString;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		char filter_glow_step3[] =
		"precision highp float;\n"
		"varying vec2 textureCoordinate;\n"
		"uniform sampler2D inputImageTexture;\n"
		"uniform sampler2D inputImageTexture2;\n"
		"uniform float mvBlurSize;\n"
		"uniform float exposure;\n"
		
		"void main()\n"
		"{\n"
		"	vec4 avgColor =  texture2D(inputImageTexture, textureCoordinate);\n"
		
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x, textureCoordinate.y - 1.0*mvBlurSize ));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x , textureCoordinate.y + 1.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 0.707*1.0*mvBlurSize , textureCoordinate.y + 0.707*1.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 0.707*1.0*mvBlurSize , textureCoordinate.y - 0.707*1.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x, textureCoordinate.y - 2.0*mvBlurSize ));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x , textureCoordinate.y + 2.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 0.707*2.0*mvBlurSize , textureCoordinate.y + 0.707*2.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 0.707*2.0*mvBlurSize , textureCoordinate.y - 0.707*2.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x, textureCoordinate.y - 3.0*mvBlurSize ));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x , textureCoordinate.y + 3.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x + 0.707*3.0*mvBlurSize , textureCoordinate.y + 0.707*3.0*mvBlurSize));\n"
		"		avgColor += texture2D(inputImageTexture, vec2(textureCoordinate.x - 0.707*3.0*mvBlurSize , textureCoordinate.y - 0.707*3.0*mvBlurSize));\n"
		
		"   avgColor = avgColor / 13.0 * exposure;\n"
		"   gl_FragColor = avgColor + texture2D(inputImageTexture2, textureCoordinate);\n"
		"}\n";
		
		kMVVideoLightingStep3FilterFragmentShaderString = [NSString stringWithUTF8String:filter_glow_step3];
	});
	
	if (!(self = [super initWithFragmentShaderFromString:kMVVideoLightingStep3FilterFragmentShaderString]))
	{
		return nil;
	}
	
	self.exposure = 1;
	self.blurSize = 0.01;
	
	return self;
}

- (void)setExposure:(CGFloat)exposure
{
	_exposure = exposure;
	
	[self setFloat:_exposure forUniformName:@"exposure"];
}

- (void)setBlurSize:(CGFloat)blurSize
{
	_blurSize = blurSize;
	[self setFloat:_blurSize forUniformName:@"mvBlurSize"];
}

@end


#pragma mark -

@interface MVVideoLightingFilter ()

@property (nonatomic, strong) MVVideoLightingStep1Filter *step1Filter;
@property (nonatomic, strong) MVVideoLightingStep2Filter *step2Filter;

@property (nonatomic, strong) GPUImageFilter *originFilter;
@property (nonatomic, strong) MVVideoLightingStep3Filter *step3Filter;

@end

@implementation MVVideoLightingFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
	if (!(self = [super init]))
	{
		return nil;
	}
	self.originFilter = [[GPUImageFilter alloc]init];
	[self addFilter:self.originFilter];

	self.step1Filter = [[MVVideoLightingStep1Filter alloc]init];
	[self addFilter:self.step1Filter];
	
	[self.originFilter addInputTarget:self.step1Filter];
	
	self.step2Filter = [[MVVideoLightingStep2Filter alloc]init];
	[self addFilter:self.step2Filter];
	
	[self.step1Filter addInputTarget:self.step2Filter];

	self.step3Filter = [[MVVideoLightingStep3Filter alloc]init];
	[self addFilter:self.step3Filter];
	
	[self.step2Filter addInputTarget:self.step3Filter];
	[self.originFilter addInputTarget:self.step3Filter];
	
	self.initialFilters = [NSArray arrayWithObject:self.originFilter];
	self.terminalFilter = self.step3Filter;

	self.exposure = 1;
	self.blurSize = 0.06;
	self.scode = 0.56;

	return self;
}

- (void)replaceCurrentCombineWithSource:(GPUImageOutput *)source
{
	if (source && [source isKindOfClass:[GPUImageOutput class]]) {
		[self.originFilter removeTarget:self.step3Filter];
		[source addInputTarget:self.step3Filter];
	}
}

#pragma mark -
#pragma mark Accessors

- (void)setExposure:(CGFloat)exposure
{
	_exposure = exposure;
	self.step3Filter.exposure = exposure;
}

- (void)setBlurSize:(CGFloat)blurSize
{
	_blurSize = blurSize;
	self.step3Filter.blurSize = blurSize;
	self.step2Filter.blurSize = blurSize;
}


- (void)setScode:(CGFloat)scode
{
	_scode = scode;
	self.step1Filter.scode = scode;
}

@end


