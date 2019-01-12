//
//  ImageMetaField.m
//  IMProcessingXMP
//
//  Created by denis svinarchuk on 03.11.17.
//

#import "ImageMetaField.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ImageMetaType
@end

@implementation ImageMetaField
{
    NSString *fieldId;
}
+ (NSString*) name {
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        fieldId = nil;
    }
    return self;
}

- (instancetype) initWithId:(NSString *)fieldID {
    self = [super init];
    if (self != nil) {
        fieldId = [fieldID copy];
    }
    return self;
}

- (NSString*) getFieldId {
    return fieldId;
}

- (NSDictionary *) dictionary
{ 
    id obj = self;
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    if (count==0){
        free(properties);
        return nil;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (key == nil) continue;
        id newObj = [obj valueForKey:key];
        if (newObj == nil) continue;
        [dict setObject:newObj forKey:key];
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSArray*) propertyList{
    unsigned count;
    objc_property_t *properties;
    
    properties = class_copyPropertyList([self class], &count);
    
    if (count==0)
        return nil;
    
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        struct objc_property *property = properties[i];
        
        NSString *pname = [NSString stringWithUTF8String:property_getName(property)];
        
        const char *propertyType = property_getTypeString(property);
        Class classObject = NSClassFromString([NSString stringWithUTF8String: propertyType]);

        ImageMetaType *type = [[ImageMetaType alloc] init];
        
        type.name = pname;
        type.propertyClass = classObject;
        
        [list addObject: type];
    }
    
    return list;
}

const char * property_getTypeString( objc_property_t property )
{
    const char * attrs = property_getAttributes( property );
        
    if ( attrs == NULL )
        return ( NULL );
    
    static char buffer[256];
    memset(buffer, 0, 256);
    const char * e = strchr( attrs, ',' );
    if ( e == NULL )
        return ( NULL );
    
    int len = (int)(e - attrs);
    memcpy( buffer, attrs, len );
    
    buffer[len-1] = '\0';
        
    return ( &buffer[3] );
}

@end
