//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import IdCloudClient

class SCAClientConformer: ClientConformer {
    override func idCloudClient(_ idCloudClient: IDCIdCloudClient, authenticatorDescription authenticator: IDCAuthenticator, authenticatorDescriptionHandler: @escaping (IDCAuthenticatorDescriptor) -> Void, cancelHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("friendly_name_title", comment: ""), message: NSLocalizedString("input_friendly_name_message", comment: ""), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .words
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default) { _ in
            guard let friendlyName = alertController.textFields?.first?.text else {
                fatalError("Cannot retrieve textField text")
            }
            let authenticatorDescription = IDCAuthenticatorDescriptor(friendlyName: friendlyName)
            authenticatorDescriptionHandler(authenticatorDescription)
        })
        AppDelegate.rootViewController.present(alertController, animated: true)
    }
}
