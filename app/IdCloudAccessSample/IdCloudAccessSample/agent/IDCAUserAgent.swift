//
//
// Copyright © 2022 THALES. All rights reserved.
//


import UIKit
import AppAuth
import WebKit

class IDCAUserAgent: NSObject {
    let scaAgent = SCAAgent()
}

extension IDCAUserAgent: OIDExternalUserAgent {
    func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
        let webVC = WebViewController(url: request.externalUserAgentRequestURL())
        webVC.redirectCallback = { [weak self] (url, decisionHandler) in
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                fatalError("Unexpected behaviour")
            }

            // Handle error
            if let error = components.queryItems?.filter({ $0.name == "error" }).first?.value,
               let description = components.queryItems?.filter({ $0.name == "error_description" }).first?.value {
                let idcaError = IDCAError(error: error, description: description)
                decisionHandler(.cancel)
                AppDelegate.rootViewController.popViewController(animated: true)
                OIDCAgent.currentAuthorizationFlow?.failExternalUserAgentFlowWithError(idcaError)
                return
            }
            // Handle enrollment
            else if let enrollmentTokenQueryItem = components.queryItems?.filter({ $0.name == "enrollmentToken" }).first,
                  let enrollmentToken = enrollmentTokenQueryItem.value {
                Logger.log("Enrollment token: \(enrollmentToken)")
                self?.scaAgent.enroll(enrollmentToken: enrollmentToken, completion: { error in
                    if let error = error {
                        Logger.log("Enrollment failed with error: \(error.localizedDescription)")
                    } else {
                        Logger.log("Enrollment completed")
                    }
                })
            }
            // Handle fetch/authenticate
            else if let scenarioId = components.queryItems?.filter({ $0.name == "scenarioId" }).first?.value {
                Logger.log("Scenario ID: \(scenarioId)")
                self?.scaAgent.fetch(completion: { error in
                    if let error = error {
                        Logger.log("Authentication failed with error: \(error.localizedDescription)")
                    } else {
                        Logger.log("Authentication completed")
                    }
                })
            }
            // Handle success
            else if let code = components.queryItems?.filter({ $0.name == "code" }).first?.value,
                    let state = components.queryItems?.filter({ $0.name == "state" }).first?.value,
                    components.path == "/oidctest/oidc-callback" {
                Logger.log("Code: \(code)")
                Logger.log("State: \(state)")
                AppDelegate.rootViewController.popViewController(animated: true)
                decisionHandler(.cancel)
                OIDCAgent.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url)
                return
            }
            decisionHandler(.allow)
            return
        }

        AppDelegate.rootViewController.pushViewController(webVC, animated: true)
        return true
    }

    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        completion()
    }
}
