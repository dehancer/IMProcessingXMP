//
//  DHCImageMetaField.h
//  DehancerUIKit
//
//  Created by denis svinarchuk on 03.11.17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageMetaType: NSObject
@property NSString * _Nonnull name;
@property Class _Nonnull     propertyClass;
@end

@interface ImageMetaField : NSObject

+ (NSString*_Nonnull) name;

/**
 *  Get property as dictionary
 *
 *  @return [String:id].
 */
- (NSDictionary*_Nullable) dictionary;

/**
 *  Get property list types
 *
 *  @return [DHCImageMetaType].
 */
- (NSArray*_Nullable) propertyList;

- (instancetype _Nullable ) initWithId:(NSString*_Nonnull)fieldID;

- (nullable NSString*) getFieldId;

@property NSDate   * _Nonnull datetime;
@property NSNumber * _Nonnull serial;

@end

NS_ASSUME_NONNULL_END
