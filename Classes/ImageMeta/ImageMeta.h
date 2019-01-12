//
//  DHCExif.h
//  DehancerUIKit
//
//  Created by denis svinarchuk on 30.10.17.
//

#import <Foundation/Foundation.h>
#import "ImageMetaField.h"

typedef NS_ENUM(int, ImageMetaState) {
    ImageMetaOk        = 0,
    ImageMetaXmpOk     = 1,
    ImageMetaNotOpened,
    ImageMetaProtected,
    ImageMetaCorrupted
};

@interface ImageMeta : NSObject
- (nonnull instancetype) initWithPath:(nonnull NSString*)path;

- (nonnull instancetype) initWithPath:(nonnull NSString*)path
                              history:(NSInteger)length;

- (nonnull instancetype) initWithPath:(nonnull NSString*)path
                            extension:(nullable NSString*)ext;

- (nonnull instancetype) initWithPath:(nonnull NSString*)path
                            extension:(nullable NSString*)ext
                              history:(NSInteger)length;

@property ImageMetaState state;


@property NSInteger         historyLength;
@property int               error;

- (nullable instancetype) setField:(ImageMetaField*_Nonnull)value
                             error:(NSError **)error;

- (nullable ImageMetaField*) getField:(Class _Nonnull )valueClass
                                 fieldId:(nullable NSString*)fieldId
                                   error:(NSError **)error;

- (nullable NSArray*)   getFieldUndoHistory:(Class _Nonnull )valueClass
                                    fieldId:(nullable NSString*)fieldId
                                      error:(NSError **)error;

@end
