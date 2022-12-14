//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import XCTest
@testable import IdCloudAccessSample

struct MockSettings {
    static let mockDefaultValue = "defaultValue"
    static let mockKey = "KEY_MOCK"

    @Storage(key: MockSettings.mockKey, defaultValue: MockSettings.mockDefaultValue)
    static var expectedSetting: String
}

final class SettingsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserDefaults.standard.removeObject(forKey: MockSettings.mockKey)
    }

    func testWrappedValue_DefaultValue() throws {
        XCTAssertEqual(MockSettings.expectedSetting, MockSettings.mockDefaultValue)
    }

    func testWrappedValue_NewValue() throws {
        let newValue = "newValue"
        MockSettings.expectedSetting = newValue
        XCTAssertEqual(MockSettings.expectedSetting, newValue)
    }
    
}
