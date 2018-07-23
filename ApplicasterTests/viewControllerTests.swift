//
//  ApplicasterTests.swift
//  ApplicasterTests
//
//  Created by Fernando Avalos on 7/19/18.
//  Copyright © 2018 Fernando Avalos. All rights reserved.
//

import XCTest
@testable import Applicaster

class ApplicasterTests: XCTestCase {
    
    var sut: ViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ItemsViewController")
        sut = viewController as! ViewController
        
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_TableView_AfterViewDidLoad_IsNotNil() {
        XCTAssertNotNil(sut.tblVideos)
    }
    
    func test_LoadingData_AfterViewDidLoad_isNotNil() {
        XCTAssertNotNil(sut.desiredChannelsArray)
        XCTAssertNotNil(sut.channelsDataArray)
        XCTAssertNotNil(sut.videosArray)
    }
    
    func test_getYoutubeFormattedDurationFrom() {
        XCTAssertEqual(sut.getYoutubeFormattedDurationFrom("PT10H05M15S"), "10:05:15")
    }
    
}
