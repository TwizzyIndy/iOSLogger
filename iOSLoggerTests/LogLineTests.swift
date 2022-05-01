//
//  LogLineTests.swift
//  iOSLoggerTests
//
//  Created by Aung Khant M. on 13/04/2022.
//

import XCTest

class LogLineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testLogLine() throws {
        
        let logLine = LogLine(logMessage: "Apr 13 14:54:14 iPad-Pro-105-inch mediaserverd(AudioToolbox)[34] <Notice>: SpatializationManager.cpp:575   Audio route is not capable of spatialization.\n")
        
        XCTAssert(logLine.messageModel != nil)
        
        print(logLine.messageModel!)
    }
    
    func testLogLineWithOneDigitInDay() throws {
        let logLine = LogLine(logMessage: "May  2 02:30:04 iPad-Pro-105-inch symptomsd(SymptomEvaluator)[152] <Notice>: L2 Metrics on en0: rssi: -35 [-1,-1] -> -35, snr: 35 (cca [wake/total] self/other/intf): [0,0]/[0,0]/[0,0]/27 (txFrames/txReTx/txFail): 128/17/0 -> (was/is) 0/0\n")
        
        XCTAssert(logLine.messageModel != nil)
        
        print(logLine.messageModel!)
    }

}
