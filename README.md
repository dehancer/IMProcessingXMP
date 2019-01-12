# IMProcessingXMP - Adobe’s XMPToolkit ObjC wrapper for  OS X.

Adobe’s Extensible Metadata Platform (XMP) is a file labeling technology that lets you embed metadata into files themselves during the content creation process. With an XMP enabled application, your workgroup can capture meaningful information about a project (such as titles and descriptions, searchable keywords, and up-to-date author and copyright information) in a format that is easily understood by your team as well as by software applications, hardware devices, and even file formats. Best of all, as team members modify files and assets, they can edit and update the metadata in real time during the workflow.

IMProcessingXMP wraps XMP meta data to ease to use with ObjC and Swift.

## Make a model

### Model interface
```objectivec
#import <IMProcessingXMP/ImageMeta.h>

NS_ASSUME_NONNULL_BEGIN

/// Define a new enum
typedef NS_ENUM(uint, LutType) {
    LutTypeMlut  = 0,
    LutTypeCube  = 1,
    LutTypePng   = 2
};

/// Registry field to can be store to media file 
@interface LutTypeModel : ImageMetaField
    /// define a property that keeps the type
    @property(nonnull)  NSNumber *nstype;
@end

NS_ASSUME_NONNULL_END

```

### Model implementation

```objectivec
#import "LutTypeModel.h"

@implementation LutTypeModel
/// fix mandatory properties serial and datetime 
@dynamic serial;
@dynamic datetime;

/// define model name as class property
+ (NSString*) name {
    return  @"mlutType";
}

@end

```
 
 ### Type extending
 
 ```swift
 import Foundation
 import IMProcessingXMP
 
 
 /// Extend LutType defined in Model
 public extension LutType {
     
     ///
     /// Read object state from meta 
     ///
     public init?(meta: ImageMeta) throws {
         let t = try meta.getField(LutTypeModel.self, fieldId: nil) as! LutTypeModel
         self.init(rawValue: t.nstype.uint32Value)
     }
     
     ///
     /// Get model reference from object state
     ///
     public var model:LutTypeModel {
         let m = LutTypeModel()
         m.nstype = NSNumber(value: self.rawValue)
         return m
     }
     
     ///
     /// Just define utility properties
     ///
     public var caption:String {
         switch self {
         case .mlut:
             return NSLocalizedString("MLut", comment: "")
         case .cube:
             return NSLocalizedString("Adobe Cube (3 files in folder)", comment: "")
         case .png:
             return NSLocalizedString("Lookup PNG (3 files in folder)", comment: "")
         }
     }
     
     public static var availableList:[LutType] {
         return [.mlut, .cube, .png]
     }
     
     public var extention:String {
         switch self {
         case .mlut:
             return "mlut"
         case .cube:
             return "cube"
         case .png:
             return "png"
         }
     }
     
     public var folderExtention:String {
         switch self {
         case .mlut:
             return ""
         case .cube:
             return " (Cube)"
         case .png:
             return " (Lookup)"
         }
     }
 }
 ```
 
 ### Example of using in application as standalone storage
 
 ```swift
 
 /// Initialize type
 let type:LutType           = .mlut
 
 /// Connect storage
 let meta = ImageMeta(path: "/tmp/ImageMeta", extension: "xmp", history:100)
 
 do {
    /// Save current state
    try meta.setField(type.model)
 }
 catch let error as NSError {
    Swift.print("Error: \(error)")
 }
 
 ```
 
  ### Example of using with image XMP extensions 

```swift
  
  ///
  /// ... some NSViewController code 
  ///
  
  ///
  /// Create image property: https://github.com/dehancer/IMProcessingXMP/blob/master/ImageMeta/ImageMetaRaw.h
  ///
  let raw = ImageMetaRaw()                

  func setImageBias(value:NSNumber){
      raw.bias = value
  }

  ///
  /// Open image from app
  ///
  @IBAction func openImage(_ sender: NSMenuItem) {
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            
            if let url = openPanel.urls.first {
                
                /// Connect image XMP store
                let meta = ImageMeta(path: url.path)
                                                
                do {
                    /// save current state
                    try meta.setField(raw)
                }
                catch let error as NSError {
                    NSAlert(error:error)
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

    
```
