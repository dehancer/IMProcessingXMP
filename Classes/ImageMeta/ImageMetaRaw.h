//
//  ImageMetaRaw.h
//  IMProcessingXMP
//
//  Created by denis svinarchuk on 03.11.17.
//

#import <Foundation/Foundation.h>
#import "ImageMetaField.h"

@interface ImageMetaRaw : ImageMetaField
@property NSDate   *datetime;
@property NSNumber *serial;

@property NSNumber *exposure;
@property NSNumber *bias;
@property NSNumber *boost;
@property NSNumber *temperature;
@property NSNumber *tint;
@property NSNumber *boostShadow;

@property NSNumber *enableSharpening;

@property NSNumber *noiseReduction;
@property NSNumber *noiseReductionSharpness;
@property NSNumber *noiseReductionContrast;
@property NSNumber *noiseReductionDetail;

@property NSNumber *luminanceNoiseReduction;
@property NSNumber *colorNoiseReduction;

@end
