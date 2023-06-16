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
    
    @Storage<String>(key: "IDC_ACCESS_KEY_DEVICE_PUSH_TOKEN", defaultValue: "")
    static var devicePushToken: String
    
    static var authenticationType: AuthenticationType {
        get {
            return AuthenticationType(rawValue: authenticationTypeString)!
        }
        set {
            authenticationTypeString = newValue.rawValue
        }
    }

    
    @Storage<String>(key: "IDC_ACCESS_KEY_IDP_URL", defaultValue: IDP_URL)
    static var idpURLString: String
    
    @Storage<String>(key: "IDC_ACCESS_KEY_REDIRECT_URL", defaultValue: REDIRECT_URL)
    static var redirectURLString: String
    
    @Storage<String>(key: "IDC_ACCESS_KEY_CLIENT_ID", defaultValue: CLIENT_ID)
    static var clientID: String

    @Storage<String>(key: "IDC_ACCESS_KEY_CLIENT_SECRET", defaultValue: CLIENT_SECRET ?? "")
    static var clientSecret: String
    
    @Storage<String>(key: "IDC_ACCESS_KEY_MS_URL", defaultValue: MS_URL)
    static var msURLString: String
    
    @Storage<String>(key: "IDC_ACCESS_KEY_TENANT_ID", defaultValue: TENANT_ID)
    static var tenantID: String
    
    @Storage<[CUnsignedChar]>(key: "IDC_ACCESS_KEY_PUBLIC_KEY_MODULUS", defaultValue: PUBLIC_KEY_MODULUS)
    static var publicKeyModulus: [CUnsignedChar]
    
    @Storage<[CUnsignedChar]>(key: "IDC_ACCESS_KEY_PUBLIC_KEY_EXPONENT", defaultValue: PUBLIC_KEY_EXPONENT)
    static var publicKeyExponent: [CUnsignedChar]
    
    @Storage<String>(key: "IDC_ACCESS_KEY_ND_URL", defaultValue: ND_URL)
    static var ndURLString: String
    
    @Storage<String>(key: "IDC_ACCESS_KEY_RISK_CLIENT_ID", defaultValue: RISK_CLIENT_ID)
    static var riskClientID: String
    
    @Storage<String>(key: "IDC_ACCESS_KEY_RISK_URL", defaultValue: RISK_URL)
    static var riskURLString: String

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
