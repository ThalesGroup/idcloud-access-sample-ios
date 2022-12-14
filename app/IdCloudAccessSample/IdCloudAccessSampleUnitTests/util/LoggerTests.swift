//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import XCTest
@testable import IdCloudAccessSample

final class LoggerTests: XCTestCase {
    let logView = UITextView()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Logger.setLogView(logView)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoggerLogMessage() throws {
        let expected = "deadbeef"
        Logger.log(expected)

        XCTAssertTrue(logView.text.contains(expected))
    }

    func testLoggerClearLogs_Cleared() throws {
        let expected = "deadbeef"
        Logger.log(expected)
        Logger.clearLogs()
        XCTAssertTrue(logView.text.isEmpty)
    }


}
