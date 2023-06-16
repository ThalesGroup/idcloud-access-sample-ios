//
//
// Copyright © 2023 THALES. All rights reserved.
//
    

import UIKit

class IDCANavigationController: UINavigationController {
    private lazy var scaAgent = SCAAgent()

    static let activityIndicator: UIActivityIndicatorView = {
        var activityIndicator: UIActivityIndicatorView!
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .white)
        }
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    static let activityIndicatorBarButton = UIBarButtonItem(customView: activityIndicator)
    
    static func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    static func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(processNotification(_:)), name: PushNotificationConstants.didReceiveUserNotification, object: nil)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.didReceiveUserNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Notification Handling
    
    @objc func processNotification(_ notification: Notification) {
        guard let userInfo = notification.object as? [AnyHashable: Any] else {
            return
        }
        
        let currentViewController = AppDelegate.rootViewController.topViewController
        IDCANavigationController.startAnimating()
        scaAgent.processNotification(notification: userInfo) { error in
            if let currentViewController = currentViewController {
                AppDelegate.rootViewController.popToViewController(currentViewController, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                IDCANavigationController.stopAnimating()
                if let error = error {
                    UIAlertController.showErrorAlert(viewController: self,
                                                     error: error)
                } else {
                    UIAlertController.showToast(viewController: self,
                                                title: NSLocalizedString("sign_in_button_title", comment: ""),
                                                message: NSLocalizedString("alert_success_msg", comment: ""))
                }
            }
        }
    }
}
