//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import Foundation

protocol SettingsDelegate: AnyObject {
    func didSetUsername(_ username: String)
    func didSetAuthenticationType(_ authenticationType: AuthenticationType)
}

class Settings {
    static weak var delegate: SettingsDelegate?

    @Storage<String>(key: "IDC_ACCESS_KEY_USERNAME", defaultValue: "")
    static var username: String {
        didSet {
            delegate?.didSetUsername(username)
        }
    }

    @Storage<Bool>(key: "IDC_ACCESS_KEY_SHOW_LOGGER", defaultValue: false)
    static var showLogger: Bool

    static var authenticationType: AuthenticationType {
        get {
            return AuthenticationType(rawValue: authenticationTypeString)!
        }
        set {
            authenticationTypeString = newValue.rawValue
        }
    }

    // MARK: Private

    @Storage<String>(key: "IDC_ACCESS_KEY_AUTHENTICATION_TYPE", defaultValue: AuthenticationType.rba.rawValue)
    private static var authenticationTypeString: String {
        didSet {
            delegate?.didSetAuthenticationType(AuthenticationType(rawValue: authenticationTypeString)!)
        }
    }
}

@propertyWrapper
struct Storage<T> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            // Read value from UserDefaults
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            // Set value to UserDefaults
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
