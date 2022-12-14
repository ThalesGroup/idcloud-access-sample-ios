//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import Foundation
import AppAuth
import IdCloudClient
import D1

struct IDCAError: LocalizedError {
    enum Code {
        case unknown
        case cancelled
        case accessDenied
        case sca
        case risk
    }

    let code: Code
    private var errorReason: String?
    
    var errorDescription: String? {
        return errorReason
    }

    init(oidError: Error) {
        switch oidError._code {
        case OIDErrorCode.userCanceledAuthorizationFlow.rawValue:
            self.code = .cancelled
        default:
            self.code = .unknown
        }
        errorReason = oidError.localizedDescription
    }

    init(scaError: IDCError) {
        switch scaError._code {
        case IDCError.Code.userCancelled.rawValue:
            self.code = .cancelled
        default:
            self.code = .sca
        }
        errorReason = scaError.localizedDescription
    }

    init(riskError: D1Error) {
        switch riskError.code {
        case .cancelled:
            self.code = .cancelled
        default:
            self.code = .risk
        }
        errorReason = riskError.errorDescription
    }

    init(error: String, description: String) {
        switch error {
        case "access_denied":
            self.code = .accessDenied
        default:
            self.code = .unknown
        }
        errorReason = description
    }

    init(code: Code, description: String) {
        self.code = code
        errorReason = description

    }
}
