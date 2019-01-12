//
//  DHCExif.h
//  DehancerUIKit
//
//  Created by denis svinarchuk on 30.10.17.
//

#import <Foundation/Foundation.h>
#import "ImageMetaField.h"

typedef NS_ENUM(int, DHCImageMetaState) {
    DHCImageMetaOk        = 0,
    DHCImageMetaXmpOk     = 1,
    DHCImageMetaNotOpened,
    DHCImageMetaProtected,
    DHCImageMetaCorrupted
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

@property DHCImageMetaState state;


@property NSInteger         historyLength;
@property int               error;

- (nullable instancetype) setField:(ImageMetaField*_Nonnull)value
                             error:(NSError *_Nullable*_Nullable)error;

- (nullable ImageMetaField*) getField:(Class _Nonnull )valueClass
                                 fieldId:(nullable NSString*)fieldId
                                   error:(NSError *_Nullable*_Nullable)error;

- (nullable NSArray*)   getFieldUndoHistory:(Class _Nonnull )valueClass
                                    fieldId:(nullable NSString*)fieldId
                                      error:(NSError *_Nullable*_Nullable)error;

@end
