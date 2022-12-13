//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import XCTest
import AppAuth
@testable import IdCloudAccessSample

final class IDCAErrorTests: XCTestCase {
    var testee: IDCAError?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitOidError_Valid_Mapped() throws {
        let oidError = NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.userCanceledAuthorizationFlow.rawValue) as Error
        testee = IDCAError(oidError: oidError)
        XCTAssertEqual(testee?.code, .cancelled)
    }

    func testInitOidError_Invalid_Unknown() throws {
        let oidError = NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.jsonSerializationError.rawValue) as Error
        testee = IDCAError(oidError: oidError)
        XCTAssertEqual(testee?.code, .unknown)
    }

    func testInitErrorMessage_Valid_Mapped() throws {
        let validError = "access_denied"
        let errorDescription = "error_description"
        testee = IDCAError(error: validError, description: errorDescription)
        XCTAssertEqual(testee?.code, .accessDenied)
        XCTAssertEqual(testee?.errorDescription, errorDescription)
    }

    func testInitErrorMessage_Invalid_Unknown() throws {
        let invalidError = "random_message"
        let errorDescription = "error_description"
        testee = IDCAError(error: invalidError, description: errorDescription)
        XCTAssertEqual(testee?.code, .unknown)
        XCTAssertEqual(testee?.errorDescription, errorDescription)
    }
}
