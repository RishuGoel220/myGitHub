//
//  majorTests.swift
//  majorTests
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import XCTest
@ testable import  major
class majorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let vc = ViewController()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPILogin() {
        APIcaller().login("rishugoel", password: "rishu", otp: ""){
            response in
            XCTAssert(response.result.isSuccess is Bool)
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
