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
        let type:LutType           = .mlut

        let meta = ImageMeta(path: "/tmp/ImageMeta", extension: "xmp", history:100)
     
        do {
            try meta.setField(type.model)
        }
        catch let error as NSError {
            Swift.print("Error: \(error)")
        }
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openImage(_ sender: NSMenuItem) {
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            if let url = openPanel.urls.first {
                
                Swift.print("image \(url.path)")
                
                let raw = ImageMetaRaw()
                
                raw.bias = 1
                
                let meta = ImageMeta(path: url.path)
                
                do {
                    try meta.setField(raw)
                }
                catch let error as NSError {
                    Swift.print(" error \(error)")
                }
            }
        }
    }
    
    lazy var openPanel:NSOpenPanel = {
        let p = NSOpenPanel()
        p.canChooseFiles = true
        p.canChooseDirectories = false
        p.resolvesAliases = true
        p.isExtensionHidden = false
        p.allowedFileTypes = ["jpeg", "jpg"]
        return p
    }()
    
}

