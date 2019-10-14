//
//  ImageMeta.m
//  IMProcessingXMP
//
//  Created by denis svinarchuk on 30.10.17.
//

#import "ImageMeta.h"
#import "ImageMetaRaw.h"
#import "ImageMetaNamespace.h"
#import <simd/simd.h>

#include <stdio.h>

#include <cstdio>
#include <vector>
#include <cstring>
#include <string>
#include <iostream>
#include <fstream>

#define XMP_INCLUDE_XMPFILES 1
#define TXMP_STRING_TYPE std::string
#include "XMP_incl.hpp"
#include "XMP.hpp"

const char* kDHC_UNKNOWN_ERROR_STR = "Unknown error";

//static bool __XMPFiles_ErrorCallbackProc ( void* context, XMP_StringPtr filePath, XMP_ErrorSeverity severity, XMP_Int32 cause, XMP_StringPtr message ) {
//    NSLog(@"File error: %@ code: %i, message: %@", @(filePath), cause, @(message));
//    return false;
//}

ImageMetaState stateFrom(int code) {
    switch (code) {
        case EPERM:            
            return ImageMetaProtected;
        case ENOENT:
        case EIO:
            return ImageMetaNotOpened;
        default:
            return ImageMetaCorrupted;
    }
}

@interface ImageMeta()
@property (atomic) NSUInteger serial;
@end

@implementation ImageMeta
{
    NSURL       *sourceUrl;
    NSURL       *xmpUrl;
    NSInteger   changeCount;
    
    std::string  filename;
    std::string  xmpFilename;
    
    bool         sourceFileIsOk;
    SXMPFiles   *sourceFile;
    SXMPMeta     meta;
    
    NSISO8601DateFormatter *formatter;
}

@synthesize state = _state;
@synthesize historyLength = _historyLength;

- (NSURL*) url {
    return self->xmpUrl;
}

- (void)dealloc
{
    try{
        [self flush: nil];
        if (sourceFileIsOk) {
            sourceFile->CloseFile();
            sourceFileIsOk = false;
        }
        if (sourceFile) {
            delete sourceFile;
        }
    }
    catch(...) {
        [self warning:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR fileName:filename.c_str() line:__LINE__];
    }  
}

- (nullable instancetype) open:(NSError **)error{
    
    if (sourceFileIsOk) {
        return self;
    }     
    
    try
    {            
        XMP_OptionBits opts = kXMPFiles_OpenForUpdate | kXMPFiles_OpenUseSmartHandler ;
        
        sourceFileIsOk = sourceFile->OpenFile(filename, kXMP_UnknownFile, opts);
                
        if( ! sourceFileIsOk )
        {
            // Now try using packet scanning
            opts = kXMPFiles_OpenForUpdate | kXMPFiles_OpenUsePacketScanning;
            sourceFileIsOk = sourceFile->OpenFile(filename, kXMP_UnknownFile, opts);
        
            xmpUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:filename.c_str()]];
        }   
        
        return [self read: error];
    }
    catch(XMP_Error & warn)
    {
        return [self read: error];
        [self warning:ImageMetaProtected errorString:warn.GetErrMsg() fileName:filename.c_str() line:__LINE__];
    }        
    catch(...) {
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
        return nil;
    }
    
    return self;
}

//- (NSURL*)

- (nullable instancetype) flush:(NSError **)error {
    
    try{
        if (sourceFileIsOk && changeCount>0) {
            if (sourceFile->CanPutXMP(meta)) {
                sourceFile->PutXMP(meta);
                sourceFile->CloseFile();
                sourceFileIsOk = false;
                xmpUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:filename.c_str()]];
            }
            else {
                self.state = ImageMetaProtected;
                if (changeCount>0){
                    return [self writeRDFToFile:meta filename:xmpFilename error:error];
                }
            }
        }  
        else {
            if (changeCount>0){
                return [self writeRDFToFile:meta filename:xmpFilename error:error];
            }
        }
        
        return self;
    }
    catch(XMP_Error & err)
    {            
        [self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
    }            
    catch(...) {
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
    }
    
    return nil;
}

- (nullable instancetype) read:(NSError **)error {
    if(sourceFileIsOk && sourceFile->CanPutXMP(meta)) {
        try {
                // Create the xmp object and get the xmp data
            sourceFile->GetXMP(&meta);
            
            if(meta.DoesPropertyExist( kXMP_NS_DC, "CreatorTool" )){
                meta.SetProperty( kXMP_NS_DC, "CreatorTool", kDHC_CREATOR_TOOL, NULL );
            }
            
            self.state = ImageMetaOk;
        }
        catch(XMP_Error & err){
            [self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
            return nil;
        }
        catch(...) {
            [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
            return nil;
        }
        changeCount = 0;
    }
    else {
        if ([self readRDFFromFile:meta filename:xmpFilename error:error]) {
            self.state = ImageMetaXmpOk;
            changeCount = 0;
        }
        else {
            self.state = ImageMetaNotOpened;
        }
    }
    
    return self;
}

- (instancetype) initWithPath:(NSString *)aPath
                    extension:(NSString *)ext
                      history:(NSInteger)length {
    
    sourceFile = new SXMPFiles;
    
    //sourceFile->SetErrorCallback(__XMPFiles_ErrorCallbackProc, 0, 1);//
    //SXMPFiles::SetDefaultErrorCallback(__XMPFiles_ErrorCallbackProc);

    self = [super init];
    if (self) {
        
        formatter = [[NSISO8601DateFormatter alloc] init];
        
        [ImageMetaNamespace shared];
        
        _historyLength = length;
        
        sourceUrl = [NSURL fileURLWithPath:aPath];
        xmpFilename = std::string( [[[sourceUrl URLByDeletingPathExtension] path] UTF8String]);
        if (ext == nil){
            xmpFilename += ".xmp";
        }
        else {
            xmpFilename += ".";
            xmpFilename += [ext UTF8String];
        }
        filename = std::string( [[sourceUrl path] UTF8String]);
        
        sourceFileIsOk = false;
        
        self.serial = time(NULL);
        
    }
    return self;
}

- (instancetype) initWithPath:(NSString *)aPath history:(NSInteger)length {
    return [self initWithPath:aPath extension:nil history:length];
}

- (instancetype) initWithPath:(NSString *)aPath extension:(NSString *)ext {
    return [self initWithPath:aPath extension:ext history:[[ImageMetaNamespace shared] historyLength]];
}

- (instancetype)initWithPath:(NSString*)aPath
{
    return [self initWithPath:aPath extension:nil history:[[ImageMetaNamespace shared] historyLength]];
}

- (const char *) structureUndoName:(ImageMetaField*)value {    
    NSString *fid = [value getFieldId];
    if (fid == nil) {
        return [[NSString stringWithFormat:@"%@.undo", [[value class] name]] UTF8String];
    }
    else {
        return [[NSString stringWithFormat:@"%@-%@.undo", fid, [[value class] name]] UTF8String];
    }
}

- (const char *) fieldName:(NSString*)propname {
    return  [propname UTF8String];    
}

- (nullable instancetype) setField:(ImageMetaField*)value error:(NSError **)error {

    const char *name = [self structureUndoName:value];
    NSDictionary *dict = [value dictionary];
    std::string correctionsItemPath;
    
    try {
        
        [self open: error];

        // Compose a path to the last item in the DocumentUsers array, this will point to a UserDetails structure
        SXMPUtils::ComposeArrayItemPath(kDHC_NS_SDK, name, kXMP_ArrayLastItem, &correctionsItemPath);
        
        // Create/Append the top level DocumentUsers array.  If the array exists a new item will be added
        meta.AppendArrayItem(kDHC_NS_SDK, name, kXMP_PropValueIsArray, 0, kXMP_PropValueIsStruct);
        
        self.serial++;
        
        for(NSString *key in dict) {
            
            if ([key isEqualToString:@"datetime"]){
                continue;
            }
            
            if ([key isEqualToString:@"serial"]){
                continue;
            }
            
            const char *propName =  [self fieldName:key]; 
            
            // Compose a path to the exposure and set field value
            std::string keyPath;
            SXMPUtils::ComposeStructFieldPath(kDHC_NS_SDK, correctionsItemPath.c_str(), kXMP_NS_RDF, propName, &keyPath);
            
            id obj = [dict objectForKey:key];
            
            if (obj == nil) { continue; }
            if ([obj isKindOfClass:[NSNumber class]]){
                
                NSNumber *number = obj;
                std::string _c_type([number objCType]);
                
                if (strcmp(_c_type.c_str(), @encode(BOOL))==0){
                    meta.SetProperty_Bool(kDHC_NS_SDK, keyPath.c_str(), [number boolValue]);
                }
                else if (strcmp(_c_type.c_str(), @encode(int))==0){
                    meta.SetProperty_Int(kDHC_NS_SDK, keyPath.c_str(), [number intValue]);                    
                }
                else if (strcmp(_c_type.c_str(), @encode(NSInteger))==0){
                    meta.SetProperty_Int64(kDHC_NS_SDK, keyPath.c_str(), [number integerValue]);                    
                }
                else {
                    meta.SetProperty_Float(kDHC_NS_SDK, keyPath.c_str(), [number doubleValue], 0);
                }
                
                meta.SetQualifier(kDHC_NS_SDK, keyPath.c_str(), kXMP_NS_XMP_IdentifierQual, kDHC_NS_QUAL_TYPE, _c_type.c_str());
            }
            else if ([obj isKindOfClass:[NSString class]]) {
                NSString *string = obj;
                meta.SetProperty(kDHC_NS_SDK, keyPath.c_str(), [string UTF8String]);
            }
            else if ([obj isKindOfClass:[NSArray class]]) {
                NSString *type = nil;
                for (id object in obj) {
                    NSString *asString = nil;
                    if ([object isKindOfClass:[NSString class]]) {
                        asString = object;
                        NSAssert(type == nil || [type isEqualToString:@"string"],
                                 @"ImageMeta should not have different types in array properties");
                        type = @"string";
                    }
                    else if ([object isKindOfClass:[NSNumber class]]){
                        asString = [object stringValue];
                        NSAssert(type == nil || [type isEqualToString:@"number"],
                                 @"ImageMeta should not have different types in array properties");
                        type = @"number";                        
                    }
                    if (asString!=nil){
                        meta.AppendArrayItem(kDHC_NS_SDK, keyPath.c_str(), kXMP_PropValueIsArray, [asString UTF8String]);
                    }
                }
                
                meta.SetQualifier(kDHC_NS_SDK, keyPath.c_str(), kXMP_NS_XMP_IdentifierQual, kDHC_NS_QUAL_TYPE, [type UTF8String]);
                
            }
        }
        
        // Update the Metadata Date
        XMP_DateTime updatedTime;
        // Get the current time.  This is a UTC time automatically
        // adjusted for the local time
        SXMPUtils::CurrentDateTime(&updatedTime);

        std::string keyPath;
        SXMPUtils::ComposeStructFieldPath(kDHC_NS_SDK, correctionsItemPath.c_str(), kXMP_NS_RDF, "datetime", &keyPath);
        meta.SetProperty_Date(kDHC_NS_SDK, keyPath.c_str(), updatedTime, 0);

        SXMPUtils::ComposeStructFieldPath(kDHC_NS_SDK, correctionsItemPath.c_str(), kXMP_NS_RDF, "serial", &keyPath);
        meta.SetProperty_Int(kDHC_NS_SDK, keyPath.c_str(), (XMP_Int32)self.serial, 0);

        XMP_Index count = meta.CountArrayItems(kDHC_NS_SDK, name);
        
        for (NSInteger i=1; i<=count-self.historyLength; i++) {
            meta.DeleteArrayItem(kDHC_NS_SDK, name, (XMP_Int32)i);
        }
        
        changeCount++;
        
        return [self flush: error];
    }
    catch(XMP_Error & err)
    {            
        [self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
    }
    catch(...)
    {            
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
    }
    
    return nil;
}

- (nullable NSArray*)  getFieldUndoHistory:(Class)valueClass
                                   fieldId:(nullable NSString*)fieldId
                                     error:(NSError **)error{
    
    try {

        [self open: error];

        if (![valueClass isSubclassOfClass:[ImageMetaField class]]) {
            return nil;
        }
        
        ImageMetaField *value = [[valueClass alloc] initWithId:fieldId];
        const char *name = [self structureUndoName:value];
        
        XMP_Index count = meta.CountArrayItems(kDHC_NS_SDK, name);
        
        NSMutableArray *history = [[NSMutableArray alloc] init];
        
        for (XMP_Index i=1; i<=count; i++) {
            try {
                ImageMetaField *field = [self getField:valueClass at:i fieldId:fieldId error:error];
                [history addObject:field];
            }
            catch(XMP_Error & error)
            {      
                NSLog(@"ImageMeta error: %s", error.GetErrMsg());
                
            }
        }
        
        return [[history reverseObjectEnumerator] allObjects];
    }
    catch(XMP_Error & err)
    {            
        [self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
    }        
    catch(...)
    {            
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
    }        
    
    return nil;
}

- (ImageMetaField*)   getField:(Class)valueClass
                               at:(XMP_Index)index
                          fieldId:(nullable NSString*)fieldId
                            error:(NSError **)error{
    
    if (![valueClass isSubclassOfClass:[ImageMetaField class]]) {
        return nil;
    }
    
    try {   
        [self open: error];

        ImageMetaField *value = [[valueClass alloc] initWithId:fieldId];
        
        if ( value == nil ) {
            value = [[valueClass alloc] init];
        }
        
        const char *name = [self structureUndoName:value];
                
        std::string correctionsItemPath;
        SXMPUtils::ComposeArrayItemPath(kDHC_NS_SDK, name, index, &correctionsItemPath);
        
        for (ImageMetaType *prop in value.propertyList) {
            NSString *key = [prop name];
            
            const char *propName =  [self fieldName:key];
            
            Class       propClass = [prop propertyClass]; 
            
            std::string keyPath;
            SXMPUtils::ComposeStructFieldPath(kDHC_NS_SDK, correctionsItemPath.c_str(), kXMP_NS_RDF, propName, &keyPath);
                        
            if ([propClass isSubclassOfClass:[NSNumber class]]) {    
                NSNumber *number = nil;
                if ([key isEqualToString:@"serial"]) {
                    XMP_Int64 theValue;
                    bool exist = meta.GetProperty_Int64(kDHC_NS_SDK, keyPath.c_str(), &theValue, NULL);
                    if (exist){
                        number = [NSNumber numberWithUnsignedInteger:theValue];
                    }
                }
                else {
                    try {
                        std::string _type;
                        meta.GetQualifier(kDHC_NS_SDK, keyPath.c_str(), kXMP_NS_XMP_IdentifierQual, kDHC_NS_QUAL_TYPE, &_type, NULL);
                        
                        if (strcmp(_type.c_str(), @encode(BOOL))==0){
                            bool theValue;
                            bool exist = meta.GetProperty_Bool(kDHC_NS_SDK, keyPath.c_str(), &theValue, NULL);
                            if (exist){
                                number = [NSNumber numberWithBool:theValue];
                            }
                        }
                        else if (strcmp(_type.c_str(), @encode(int))==0){
                            int theValue;
                            bool exist = meta.GetProperty_Int(kDHC_NS_SDK, keyPath.c_str(), &theValue, NULL);
                            if (exist){
                                number = [NSNumber numberWithInt:theValue];
                            }
                        }
                        else if (strcmp(_type.c_str(), @encode(NSInteger))==0){
                            XMP_Int64 theValue;
                            bool exist = meta.GetProperty_Int64(kDHC_NS_SDK, keyPath.c_str(), &theValue, NULL);
                            if (exist){
                                number = [NSNumber numberWithInteger:theValue];
                            }
                        }
                        else {
                            double theValue;
                            bool exist = meta.GetProperty_Float(kDHC_NS_SDK,  keyPath.c_str(), &theValue, NULL);
                            if (exist){
                                number = [NSNumber numberWithDouble:theValue];
                            }
                        }
                    }
                    catch(XMP_Error & err)
                    {
                        [self warning:ImageMetaOk errorString:err.GetErrMsg() fileName:keyPath.c_str() line:__LINE__];
                        continue;
                        //[self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
                        //return nil;
                    }
                }
                if (number != nil ) {
                    [value setValue:number forKey:key];
                }
            }
            else if ([propClass isSubclassOfClass:[NSString class]]) {
                std::string theValue;
                bool exist = meta.GetProperty(kDHC_NS_SDK, keyPath.c_str(), &theValue, NULL);
                if (exist) {
                    NSString *string = [NSString stringWithUTF8String:theValue.c_str()];
                    [value setValue:string forKey:key];
                }
            }   
            else if ([propClass isSubclassOfClass:[NSArray class]]) {
                if (meta.DoesPropertyExist(kDHC_NS_SDK, keyPath.c_str())) {
                    XMP_Index count = meta.CountArrayItems(kDHC_NS_SDK, keyPath.c_str());
                    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
                    std::string _type;
                    meta.GetQualifier(kDHC_NS_SDK, keyPath.c_str(), kXMP_NS_XMP_IdentifierQual, kDHC_NS_QUAL_TYPE, &_type, NULL);
                    NSString *type = [NSString stringWithUTF8String:_type.c_str()];
                    for (int i=1; i<=count; i++) {
                        id value;
                        std::string _value;
                        meta.GetArrayItem(kDHC_NS_SDK, keyPath.c_str(), i, &_value, NULL);
                        if ([type isEqualToString:@"number"]){                            
                            value = [NSNumber numberWithDouble:SXMPUtils::ConvertToFloat(_value)];
                        }
                        else if ([type isEqualToString:@"string"]){
                            value = [NSString stringWithUTF8String:_value.c_str()];
                        }
                        [array addObject:value];
                    }
                    [value setValue:array forKey:key];
                }
            }
            else if ([propClass isSubclassOfClass:[NSDate class]]) {
                XMP_DateTime myDate;
                bool exist = meta.GetProperty_Date(kDHC_NS_SDK, keyPath.c_str(), &myDate, NULL);
                if (exist) {
                    std::string dateStr;
                    SXMPUtils::ConvertFromDate(myDate, &dateStr);
                    NSString *dstr = [NSString stringWithUTF8String:dateStr.c_str()];
                    NSDate *date =  [formatter dateFromString: dstr];
                    [value setValue:date forKey:key];
                }
            }
        }
        
        return value;
    }
    catch(XMP_Error & err)
    {            
        [self perror:ImageMetaCorrupted errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
    }        
    catch(...)
    {            
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
    }    
    
    return nil;
}

- (NSDate *)getDateFromISO8601:(NSString *)strDate{    
    return  [formatter dateFromString: strDate];
}

- (ImageMetaField*)   getField:(Class)valueClass
                          fieldId:(nullable NSString*)fieldId
                            error:(NSError **)error{
    return [self getField:valueClass at:kXMP_ArrayLastItem fieldId:fieldId error:error];
}

- (nullable instancetype) writeRDFToFile:(SXMPMeta&)meta filename:(const std::string&)filename error:(NSError **)error{
    
    try {
        std::string metaBuffer;
        
        // Serialize the packet and write the buffer to a file
        // Let the padding be computed and use the default linefeed and indents without limits
        //meta.SerializeToBuffer(&metaBuffer, 0, 0, "", "", 0);
        
        // Write the packet to a file but this time as compact RDF
        XMP_OptionBits outOpts = kXMP_OmitPacketWrapper | kXMP_UseCompactFormat | kXMP_UseCanonicalFormat; // | kXMP_EncodeUTF8;
        meta.SerializeToBuffer(&metaBuffer, outOpts);
        
        std::ofstream outFile;
        
        outFile.exceptions(std::ofstream::failbit | std::ofstream::badbit);
        
        outFile.open(filename.c_str(), std::ios::out);
        outFile << metaBuffer;
        outFile.close();
        
        NSString *c = [NSString stringWithUTF8String:metaBuffer.c_str()];
        
        xmpUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:filename.c_str()]];

        return self;
    }
    catch(XMP_Error & err)
    {            
        [self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
    }        
    catch (std::ios_base::failure& err) {
        [self perror:stateFrom(errno) errorString:strerror(errno) error:error fileName:filename.c_str() line:__LINE__];
    }
    catch (std::system_error &err) {
        [self perror:stateFrom(errno) errorString:strerror(errno) error:error fileName:filename.c_str() line:__LINE__];
    }
    catch (...) {
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
    }
    
    return nil;
}

- (bool) readRDFFromFile:(SXMPMeta &)meta filename:(const std::string&) filename error:(NSError **)error{
    try {
        
        std::string metaBuffer;        
        std::ifstream inFile;
        
        inFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
        
        try{
            inFile.open(filename.c_str(),  std::fstream::in);
        }
        catch (std::ios_base::failure& err) {
            [self perror:stateFrom(errno) errorString:strerror(errno) error:error fileName:filename.c_str() line:__LINE__];
            return false;
        }
        
        inFile.seekg(0, std::ios::end);   
        metaBuffer.reserve(inFile.tellg());
        inFile.seekg(0, std::ios::beg);
        
        metaBuffer.assign((std::istreambuf_iterator<char>(inFile)),
                          std::istreambuf_iterator<char>());
        
        inFile.close();
                
        meta.ParseFromBuffer(metaBuffer.c_str(), (XMP_Int32)metaBuffer.length());
        
        return true;
        
    }
    catch(XMP_Error & err)
    {            
        [self perror:stateFrom(errno) errorString:err.GetErrMsg() error:error fileName:filename.c_str() line:__LINE__];
    }        
    catch (std::ios_base::failure& err) {
        [self perror:stateFrom(errno) errorString:strerror(errno) error:error fileName:filename.c_str() line:__LINE__];
    }
    catch (std::system_error &err) {
        [self perror:stateFrom(errno) errorString:strerror(errno) error:error fileName:filename.c_str() line:__LINE__];
    }
    catch (...) {
        [self perror:stateFrom(errno) errorString:kDHC_UNKNOWN_ERROR_STR error:error fileName:filename.c_str() line:__LINE__];
    }
    return false;
}

- (void) perror:(ImageMetaState)aState
    errorString:(const char* )errorString
          error:(NSError **)error
       fileName:(const char*)_filename
           line:(int)line {
    
    self.error = errno;
    self.state = aState;
    
    if (error !=nil )
        *error = [NSError errorWithDomain:@"com.dehancer.meta"
                                     code:aState
                                 userInfo:@{
                                            NSLocalizedDescriptionKey: @(errorString),
                                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Format error", comment:"")
                                            }];
#if DEBUG_XMP || DEBUG
    NSLog(@"ImageMeta error/state(%i/%i): %@:%@, %s:%i", self.error, aState, @(errorString), @(_filename), __FILE__, line);
#endif
}

- (void) warning:(ImageMetaState)aState errorString:(const char* )error fileName:(const char*)_filename line:(int)line {
    self.error = errno;
    self.state = aState;
#if DEBUG_XMP || DEBUG
    NSLog(@"ImageMeta warning/state(%i/%i): %@, %s:%i", self.error, aState, @(_filename), __FILE__, line);
#endif
}
@end
