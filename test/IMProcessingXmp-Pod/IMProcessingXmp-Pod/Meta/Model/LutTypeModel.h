//
//  LutTypeModel.h
//  IMProcessingXmp-Pod
//
//  Created by denn on 12/01/2019.
//  Copyright © 2019 Dehancer. All rights reserved.
//

#import <IMProcessingXMP/ImageMeta.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint, LutType) {
    LutTypeMlut  = 0,
    LutTypeCube  = 1,
    LutTypePng   = 2
};

@interface LutTypeModel : ImageMetaField
    @property(nonnull)  NSNumber *nstype;
@end

NS_ASSUME_NONNULL_END
