//
//  AppDelegate.swift
//  IMProcessingXmp-Pod
//
//  Created by denn on 12/01/2019.
//  Copyright © 2019 Dehancer. All rights reserved.
//

import Cocoa
import IMProcessingXMP

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        Swift.print(".... ")
        
        let raw = ImageMetaRaw()
        
        raw.bias = 1
        
        let meta = ImageMeta(path: "/tmp/test_meta.xmp")
        meta.historyLength = 100
        
        do {
            try meta.setField(raw)
        }
        catch let error as NSError {
            Swift.print(" error \(error)")
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

