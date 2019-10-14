//
//  AppDelegate.m
//  XmpObjcTest-Pod
//
//  Created by denn nevera on 13/10/2019.
//  Copyright © 2019 Dehancer. All rights reserved.
//

#import "AppDelegate.h"
#import <IMProcessingXMP/ImageMeta.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    @try {
        ImageMeta* im = [[ImageMeta  alloc] initWithPath:@"/tmp/ImageMeta" extension:@"mlut" history:1];
    }
    @catch (NSException *e) {
        
    }
    
    @catch (...) {
        
        NSLog(@" error ... ");
        
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
