//
//  LutType.swift
//  IMProcessingXmp-Pod
//
//  Created by denn on 12/01/2019.
//  Copyright © 2019 Dehancer. All rights reserved.
//

import Foundation
import IMProcessingXMP

public extension LutType {
    
    init?(meta: ImageMeta) throws {
        let t = try meta.getField(LutTypeModel.self, fieldId: nil) as! LutTypeModel
        self.init(rawValue: t.nstype.uint32Value)
    }
    
    var model:LutTypeModel {
        let m = LutTypeModel()
        m.nstype = NSNumber(value: self.rawValue)
        return m
    }
    
    var caption:String {
        switch self {
            case .mlut:
                return NSLocalizedString("MLut", comment: "")
            case .cube:
                return NSLocalizedString("Adobe Cube (3 files in folder)", comment: "")
            case .png:
                return NSLocalizedString("Lookup PNG (3 files in folder)", comment: "")
            @unknown default:
                fatalError("unknown")
        }
    }
    
    static var availableList:[LutType] {
        return [.mlut, .cube, .png]
    }
    
    var extention:String {
        switch self {
            case .mlut:
                return "mlut"
            case .cube:
                return "cube"
            case .png:
                return "png"
            
            @unknown default:
                fatalError("unknown")
        }
    }
    
    var folderExtention:String {
        switch self {
            case .mlut:
                return ""
            case .cube:
                return " (Cube)"
            case .png:
                return " (Lookup)"
            @unknown default:
             fatalError("unknown")
        }
    }
}
