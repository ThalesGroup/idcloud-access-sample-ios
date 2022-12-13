//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import Foundation

enum AuthenticationType: String, CaseIterable {
    case rba = "rba"
    case silent = "silent"
    case strong = "sca"

    var displayName: String {
        switch self {
        case .rba:
            return NSLocalizedString("authentication_type_risk", comment: "")
        case .silent:
            return NSLocalizedString("authentication_type_silent", comment: "")
        case .strong:
            return NSLocalizedString("authentication_type_strong", comment: "")
        }
    }

    var acrValue: String {
        return rawValue
    }
}
