//
//  ImageMetaRegistry.cpp
//  IMProcessingXMP
//
//  Created by denis svinarchuk on 03.11.17.
//

#include "ImageMetaNamespace.h"
#include <stdio.h>

#include <cstdio>
#include <vector>
#include <cstring>
#include <string>
#include <iostream>
#include <fstream>

using namespace std; 

#define XMP_INCLUDE_XMPFILES 1 
#define TXMP_STRING_TYPE std::string
#include "XMP_incl.hpp"
#include "XMP.hpp"

//static  bool __XMPMeta_ErrorCallbackProc ( void* context, XMP_ErrorSeverity severity, XMP_Int32 cause, XMP_StringPtr message ) {
//    NSLog(@"File error: code: %i, message: %@", cause, @(message));
//    return false;
//}

@implementation ImageMetaNamespace

#pragma mark Singleton Methods

+ (id)shared {
    static ImageMetaNamespace *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (NSInteger) historyLength {
    return 16;
}

- (id)init {
    if (self = [super init]) {
        
        XMP_OptionBits options = 0;
        
        if ( ! SXMPFiles::Initialize ( options ) )
        {
            std::cout << "Could not initialize SXMPFiles.";
        }
        
        if(!SXMPMeta::Initialize())
        {
            cout << "Could not initialize Toolkit!";
        }
        else
        {
            try
            {
                // Register the namespaces
                string actualPrefix;
                SXMPMeta::RegisterNamespace(kDHC_NS_SDK,     "Dehancer",     &actualPrefix);
                //SXMPMeta::SetDefaultErrorCallback(__XMPMeta_ErrorCallbackProc);                
                
            }
            catch(XMP_Error & e)
            {
                std::cerr << "ERROR: " << e.GetErrMsg() << " " << __FILE__ << ":" << __LINE__ << endl;;
            }
        }
    }
    return self;
}

- (void)dealloc
{
    SXMPMeta::Terminate();
    SXMPFiles::Terminate();
}

@end
