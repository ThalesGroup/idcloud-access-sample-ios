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
        if error.code == .cancelled {
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
}
