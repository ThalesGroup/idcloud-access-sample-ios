//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit
import AppAuth

struct OIDCAgent {
    static var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private static var authState: OIDAuthState?

    static func authorize(username: String, acr: String, completion: @escaping (IDCAError?) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: URL(string: Settings.idpURLString)!) { configuration, error in
            if let error = error {
                Logger.log("Failed to discover: \(error.localizedDescription)")
                completion(IDCAError(oidError: error))
                return
            }

            guard let configuration = configuration else {
                fatalError("Missing configuration")
            }

            let externalUserAgent = IDCAUserAgent()
            Logger.log("acr_values: \(acr)")
            let additionalParameters: [String: String] = [
                "login_hint": username,
                "prompt": "login",
                "acr_values": acr
            ]
            let request: OIDAuthorizationRequest = OIDAuthorizationRequest(configuration: configuration,
                                                                           clientId: Settings.clientID,
                                                                           clientSecret: Settings.clientSecret.isEmpty ? nil : Settings.clientSecret,
                                                                           scopes: [ OIDScopeOpenID],
                                                                           redirectURL: URL(string: Settings.redirectURLString)!,
                                                                           responseType: OIDResponseTypeCode,
                                                                           additionalParameters: additionalParameters)
            currentAuthorizationFlow =  OIDAuthState.authState(byPresenting: request,
                                                               externalUserAgent: externalUserAgent) { authState, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(IDCAError(oidError: error))
                    }
                } else {
                    guard let authState = authState else {
                        fatalError("Missing auth state")
                    }

                    self.authState = authState

                    if let idToken = authState.lastTokenResponse?.idToken {
                        Logger.log("IDToken: \(idToken)")
                    }

                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}
