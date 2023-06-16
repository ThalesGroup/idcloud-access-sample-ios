//
//
// Copyright © 2022 THALES. All rights reserved.
//
    
// swiftlint:disable line_length syntactic_sugar
import Foundation

//  ** WARNING **
//  The application Settings will be initialized with the values provided here.
//  Once modifications have been made in the Settings UI, modifications to the Configurations here would no longer be reflected for that particular setting.

// MARK: Open ID Connect
let IDP_URL: String = "<#T##String#>"
let REDIRECT_URL: String = "<#T##String#>"
let CLIENT_ID: String = "<#T##String#>"
let CLIENT_SECRET: String? = "<#T##String#>"

// MARK: Protector FIDO
let MS_URL: String = "<#T##String#>"
let TENANT_ID: String = "<#T##String#>"
let PUBLIC_KEY_EXPONENT: Array<CUnsignedChar> = [<#T##CUnsignedChar#>]
let PUBLIC_KEY_MODULUS: Array<CUnsignedChar> = [<#T##CUnsignedChar#>]

// MARK: IdCloud Risk
let ND_URL: String = "<#T##String#>"
let RISK_CLIENT_ID: String = "<#T##String#>"
let RISK_URL: String = "<#T##String#>"

struct Configuration {
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
