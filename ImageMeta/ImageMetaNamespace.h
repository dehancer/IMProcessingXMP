//
//  ImageMetaRegistry.hpp
//  IMProcessingXMP
//
//  Created by denis svinarchuk on 03.11.17.
//

#ifndef DHCImageMetaRegistry_hpp
#define DHCImageMetaRegistry_hpp

#include <Foundation/Foundation.h>

typedef const char * IMP_StringPtr;  // Points to a null terminated UTF-8 string.

const IMP_StringPtr kDHC_CREATOR_TOOL = "IMProcessing";
const IMP_StringPtr kDHC_NS_SDK       = "http://dehancer.com/xmp/1.0";
const IMP_StringPtr kDHC_NS_QUAL_TYPE = "type";

@interface ImageMetaNamespace : NSObject 
+ (id)shared;
@property (readonly) NSInteger historyLength;
@end


#endif /* DHCImageMetaRegistry_hpp */
