//
//
// Copyright © 2022 THALES. All rights reserved.
//
    
// swiftlint:disable line_length syntactic_sugar
import Foundation

// MARK: Open ID Connect
fileprivate let IDP_URL: String = "<#T##String#>"
fileprivate let REDIRECT_URL: String = "<#T##String#>"
fileprivate let CLIENT_ID: String = "<#T##String#>"
fileprivate let CLIENT_SECRET: String? = nil

// MARK: Protector FIDO
fileprivate let MS_URL: String = "<#T##String#>"
fileprivate let TENANT_ID: String = "<#T##String#>"
fileprivate let PUBLIC_KEY_EXPONENT: Array<CUnsignedChar> = [<#T##CUnsignedChar#>]
fileprivate let PUBLIC_KEY_MODULUS: Array<CUnsignedChar> = [<#T##CUnsignedChar#>]

// MARK: IdCloud Risk
fileprivate let ND_URL: String = "<#T##String#>"
fileprivate let RISK_CLIENT_ID: String = "<#T##String#>"
fileprivate let RISK_URL: String = "<#T##String#>"

struct Configuration {
    static var idpURL: URL {
        return URL(string: IDP_URL)!
    }

    static var redirectURL: URL {
        return URL(string: REDIRECT_URL)!
    }

    static var clientID: String {
        return CLIENT_ID
    }

    static var clientSecret: String? {
        return CLIENT_SECRET
    }

    static var msURL: String {
        return MS_URL
    }

    static var tenantID: String {
        return TENANT_ID
    }

    static var publicKeyModulus: [CUnsignedChar] {
        return PUBLIC_KEY_MODULUS
    }

    static var publicKeyExponent: [CUnsignedChar] {
        return PUBLIC_KEY_EXPONENT
    }

    static var ndURL: String {
        return ND_URL
    }

    static var riskClientID: String {
        return RISK_CLIENT_ID
    }

    static var riskURL: String {
        return RISK_URL
    }

    static func assertConfigurations() {
        precondition(URL(string: IDP_URL) != nil)
        precondition(URL(string: REDIRECT_URL) != nil)
        precondition(CLIENT_ID.isEmpty == false)

        precondition(URL(string: MS_URL) != nil)
        precondition(TENANT_ID.isEmpty == false)
    }

    @available(*, unavailable)
    init() {}
}
// swiftlint:enable line_length syntactic_sugar
