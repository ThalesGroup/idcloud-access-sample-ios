//
//
// Copyright © 2022 THALES. All rights reserved.
//


import Foundation
import IdCloudClient
import LocalAuthentication

class SCAAgent: NSObject {
    private var client = try! IDCIdCloudClient(url: Configuration.msURL, tenantId: Configuration.tenantID)
    private var enrollRequest: IDCEnrollRequest?
    private var fetchRequest: IDCFetchRequest?
    private var unenrollRequest: IDCUnenrollRequest?

    let clientConformer: SCAClientConformer = {
        let clientConformer = SCAClientConformer()
        clientConformer.presentViewClosure = { (presentViewController: UIViewController, isPresent: Bool) in
            if isPresent {
                AppDelegate.rootViewController.present(presentViewController, animated: true, completion: nil)
            } else {
                AppDelegate.rootViewController.pushViewController(presentViewController, animated: true)
            }
        }
        return clientConformer
    }()

    static func prepareAgent() {
        let config = SecureLogConfig { (slComps) in
            slComps.fileID = "sample"

            // Set Mandatory parameters
            slComps.publicKeyModulus = NSData(bytes: Configuration.publicKeyModulus,
                                              length: Configuration.publicKeyModulus.count) as Data
            slComps.publicKeyExponent = NSData(bytes: Configuration.publicKeyExponent,
                                               length: Configuration.publicKeyExponent.count) as Data
        }

        IDCIdCloudClient.configureSecureLog(config)
    }

    static func sdkVersion() -> String {
        return IDCIdCloudClient.sdkVersion()
    }

    static func clientId() -> String? {
        let client = try? IDCIdCloudClient(url: Configuration.msURL, tenantId: Configuration.tenantID)
        return client?.clientID()
    }

    func enroll(enrollmentToken code: String, completion: @escaping (IDCAError?) -> Void) {
        do {
            guard let tokenData = code.data(using: .utf8) else {
                fatalError("Unable to convert enrollmentToken string to bytes")
            }
            let enrollmentToken = try IDCEnrollmentTokenFactory.createEnrollmentToken(tokenData)
            let uiDelegates = IDCUiDelegates()
            uiDelegates.commonUiDelegate = clientConformer
            uiDelegates.biometricUiDelegate = clientConformer
            uiDelegates.securePinPadUiDelegate = clientConformer
            uiDelegates.platformUiDelegate = clientConformer

            enrollRequest = client.createEnrollRequest(with: enrollmentToken, uiDelegates: uiDelegates) { _ in
                // Do something
            } completion: { _, error in
                // Remove all views displayed by the IdCloud FIDO UI SDK.
                if let webVC = AppDelegate.rootViewController.viewControllers.filter({ $0 is WebViewController }).first as? WebViewController {
                    AppDelegate.rootViewController.popToViewController(webVC, animated: true)
                }

                if let idcError = error as? IDCError {
                    completion(IDCAError(scaError: idcError))
                } else {
                    completion(nil)
                }
            }
            enrollRequest?.execute()
        } catch let error as IDCError {
            completion(IDCAError(scaError: error))
        } catch let error {
            if let idcError = error as? IDCError {
                completion(IDCAError(scaError: idcError))
            }
        }
    }

    func fetch(completion: @escaping (IDCAError?) -> Void) {
        let uiDelegates = IDCUiDelegates()
        uiDelegates.commonUiDelegate = clientConformer
        uiDelegates.biometricUiDelegate = clientConformer
        uiDelegates.securePinPadUiDelegate = clientConformer
        uiDelegates.platformUiDelegate = clientConformer

        fetchRequest = client.createFetchRequest(with: uiDelegates) { _ in
            // Do something
        } completion: { _, error in
            if let webVC = AppDelegate.rootViewController.viewControllers.filter({ $0 is WebViewController }).first as? WebViewController {
                AppDelegate.rootViewController.popToViewController(webVC, animated: true)
            }
            if let idcError = error as? IDCError {
                completion(IDCAError(scaError: idcError))
            } else {
                completion(nil)
            }
        }
        fetchRequest?.execute()
    }

    func unenroll(completion: @escaping (IDCAError?) -> Void) {
        unenrollRequest = client.createUnenrollRequest(progress: { _ in
            // Do something
        }, completion: { _, error in
            if let idcError = error as? IDCError {
                completion(IDCAError(scaError: idcError))
            } else {
                completion(nil)
            }
        })
        unenrollRequest?.execute()
    }
}
