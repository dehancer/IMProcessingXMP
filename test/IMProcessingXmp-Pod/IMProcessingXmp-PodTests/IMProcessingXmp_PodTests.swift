//
//  IMProcessingXmp_PodTests.swift
//  IMProcessingXmp-PodTests
//
//  Created by denn on 12/01/2019.
//  Copyright © 2019 Dehancer. All rights reserved.
//

import XCTest
import IMProcessingXMP

@testable import IMProcessingXmp_Pod

class IMProcessingXmp_PodTests: XCTestCase {
    
    var meta:ImageMeta?
    
    override func setUp() {
         meta = ImageMeta(path: "/tmp/IMProcessingXmp_PodTests", extension: "xmp", history:10)
    }

    override func tearDown() {}

    func test_0() {
        continueAfterFailure = true
        let t = LutType.png
        XCTAssert(try! meta?.setField(t.model) != nil)
    }

    func test_1() {
        continueAfterFailure = true
        do {
            let t = try LutType(meta: meta!)!
            XCTAssert(t == .png)
        }
        catch {
            XCTAssert(false)
        }
    }

    func testPerformanceExample() {
        self.measure {
            let t = LutType.png
            for _ in 0..<1 {
                try! meta?.setField(t.model)
            }
        }
    }

}
