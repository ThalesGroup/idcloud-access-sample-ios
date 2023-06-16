//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

extension UIAlertController {
    static func showAlert(viewController: UIViewController?,
                          title: String,
                          message: String,
                          okMessage: String = NSLocalizedString("alert_ok", comment: ""),
                          okAction: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okMessage, style: .default, handler: okAction))
        viewController?.present(alertController, animated: true, completion: nil)
    }

    static func showErrorAlert(viewController: UIViewController?,
                               error: IDCAError,
                               okMessage: String = NSLocalizedString("alert_ok", comment: ""),
                               okAction: ((UIAlertAction) -> Void)? = nil) {
        if error.code == .cancelled ||
            error.code == .noPendingEvents {
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("alert_error_title", comment: ""),
                                                message: error.errorDescription,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okMessage, style: .default, handler: okAction))
        viewController?.present(alertController, animated: true, completion: nil)
    }

    static func showToast(viewController: UIViewController?,
                          title: String,
                          message: String,
                          duration: Double = 1.5,
                          completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        viewController?.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alertController.dismiss(animated: true, completion: completion)
        }
    }
    
    static func showTextFieldAlert(viewController: UIViewController?,
                                   title: String,
                                   text: String,
                                   okMessage: String = NSLocalizedString("alert_ok", comment: ""),
                                   okAction: ((String) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = title
            textField.text = text
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_cancel", comment: ""), style: .cancel))
        alertController.addAction(UIAlertAction(title: okMessage, style: .default) { _ in
            guard let textField = alertController.textFields?.first,
            let text = textField.text else {
                fatalError("No text field found")
            }
            textField.endEditing(true)
            okAction?(text)
        })
        viewController?.present(alertController, animated: true, completion: nil)
    }
}
