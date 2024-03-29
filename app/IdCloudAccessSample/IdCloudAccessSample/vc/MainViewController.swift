//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit
import D1
import WebKit

class MainViewController: UIViewController {
    // Enroll
    private let enrollView: EnrollView = {
        let enrollView = EnrollView()
        return enrollView
    }()

    // Authentication
    private let authenticateView: AuthenticationView = {
        let authenticateView = AuthenticationView()
        return authenticateView
    }()

    // Log
    private let logView: LogView = {
        let logView = LogView()
        return logView
    }()

    private lazy var scaAgent = SCAAgent()
    private let semaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .extBackground
        title = NSLocalizedString("main_title", comment: "")

        Settings.delegate = self

        let settingsBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(settings(_:)))
        navigationItem.rightBarButtonItems = [
            settingsBarButtonItem,
            IDCANavigationController.activityIndicatorBarButton
        ]
        
        enrollView.registerButton.addTarget(self, action: #selector(register(_:)), for: .touchUpInside)
        enrollView.signInButton.addTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
        authenticateView.authenticationTypeButton.addTarget(self, action: #selector(authenticationTypeDropdown(_:)), for: .touchUpInside)
        authenticateView.authenticateSignInButton.addTarget(self, action: #selector(authenticationSignIn(_:)), for: .touchUpInside)
        logView.clearLogsButton.addTarget(self, action: #selector(clearLogs(_:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layout()
        startAnalyze()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)

        if SCAAgent.isEnrolled() {
            IDCANavigationController.startAnimating()
            scaAgent.fetch { [weak self] idcaError in
                IDCANavigationController.stopAnimating()
                AppDelegate.rootViewController.popViewController(animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let error = idcaError {
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

    override func viewWillDisappear(_ animated: Bool) {
        RiskAgent.pauseAnalyze()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        super.viewWillDisappear(animated)
    }

    // MARK: IBAction

    @objc func settings(_ barButtonItem: UIBarButtonItem) {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC,
                                                 animated: true)
    }

    @objc func register(_ button: UIButton) {
        guard let username = assertUsername(forTextField: enrollView.usernameTextField) else {
            return
        }

        let acrValue = "enroll sca=fidomob"
        IDCANavigationController.startAnimating()
        OIDCAgent.authorize(username: username,
                            acr: acrValue) { [weak self] error in
            IDCANavigationController.stopAnimating()
            if let error = error {
                UIAlertController.showErrorAlert(viewController: self,
                                                 error: error)
            } else {
                Settings.username = username
                self?.layout()
                UIAlertController.showToast(viewController: self,
                                            title: NSLocalizedString("register_button_title", comment: ""),
                                            message: NSLocalizedString("alert_success_msg", comment: ""))
            }
        }
    }

    @objc func signIn(_ button: UIButton) {
        guard let username = assertUsername(forTextField: enrollView.usernameTextField) else {
            return
        }
        var aError: IDCAError?

        var acrValue = "rba sca=fidomob"
        if let userAgent = WKWebView().value(forKey: "userAgent") as? String {
            RiskAgent.userAgent = userAgent
        }

        IDCANavigationController.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            RiskAgent.submitRiskPayload(username: username) { [weak self] riskID, error in
                if let riskID = riskID {
                    acrValue += " riskid=\(riskID)"
                } else if let error = error {
                    aError = error
                }
                self?.semaphore.signal()
            }
            self?.semaphore.wait()

            if aError != nil {
                DispatchQueue.main.async {
                    UIAlertController.showErrorAlert(viewController: self,
                                                     error: aError!)
                }
                return
            }

            OIDCAgent.authorize(username: username,
                                acr: acrValue) { [weak self] error in
                IDCANavigationController.stopAnimating()
                if let error = error {
                    UIAlertController.showErrorAlert(viewController: self,
                                                     error: error)
                } else {
                    Settings.username = username
                    UIAlertController.showToast(viewController: self,
                                                title: NSLocalizedString("sign_in_button_title", comment: ""),
                                                message: NSLocalizedString("alert_success_msg", comment: ""))
                }
                self?.semaphore.signal()
            }
            self?.semaphore.wait()
        }
    }

    @objc func authenticationTypeDropdown(_ button: UIButton) {
        let authenticationTypeVC = AuthenticationTypeTableViewController()
        authenticationTypeVC.modalPresentationStyle = .popover
        authenticationTypeVC.preferredContentSize = CGSize(width: 150, height: 135)

        let popoverVC = authenticationTypeVC.popoverPresentationController
        popoverVC?.delegate = authenticationTypeVC
        popoverVC?.sourceView = button
        popoverVC?.sourceRect = button.bounds
        present(authenticationTypeVC, animated: true)
    }

    @objc func authenticationSignIn(_ button: UIButton) {
        if Settings.username.isEmpty {
            guard let username = assertUsername(forTextField: authenticateView.usernameTextField) else {
                return
            }
            Settings.username = username
        }
        var aError: IDCAError?

        var acrValue = "\(Settings.authenticationType.acrValue) sca=fidomob"
        if let clientID = SCAAgent.clientId() {
            acrValue += " clientid=\(clientID)"
        }

        if let userAgent = WKWebView().value(forKey: "userAgent") as? String {
            RiskAgent.userAgent = userAgent
        }

        IDCANavigationController.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if Settings.authenticationType == .rba ||
                Settings.authenticationType == .silent {
                RiskAgent.submitRiskPayload(username: Settings.username) { [weak self] riskID, error in
                    if let riskID = riskID {
                        acrValue += " riskid=\(riskID)"
                    } else if let error = error {
                        aError = error
                    }
                    self?.semaphore.signal()
                }
                self?.semaphore.wait()
            }

            if aError != nil {
                DispatchQueue.main.async {
                    UIAlertController.showErrorAlert(viewController: self,
                                                     error: aError!)
                }
                return
            }

            OIDCAgent.authorize(username: Settings.username,
                                acr: acrValue) { [weak self] error in
                IDCANavigationController.stopAnimating()
                if let error = error {
                    UIAlertController.showErrorAlert(viewController: self,
                                                     error: error)
                } else {
                    UIAlertController.showToast(viewController: self,
                                                title: NSLocalizedString("sign_in_button_title", comment: ""),
                                                message: NSLocalizedString("alert_success_msg", comment: ""))
                }
                self?.semaphore.signal()
            }
            self?.semaphore.wait()
        }
    }

    @objc func clearLogs(_ button: UIButton) {
        Logger.clearLogs()
    }

    // MARK: Private

    private func assertUsername(forTextField textField: UITextField) -> String? {
        textField.endEditing(true)
        guard let username = textField.text,
            !username.isEmpty else {
            UIAlertController.showAlert(viewController: self,
                                        title: NSLocalizedString("alert_error_title", comment: ""),
                                        message: NSLocalizedString("username_textfield_placeholder", comment: ""))
            return nil
        }
        return username
    }
}

extension MainViewController: SettingsDelegate {
    func didSetUsername(_ username: String) {
        enrollView.usernameTextField.text = username
        authenticateView.usernameValueLabel.text = username
    }

    func didSetAuthenticationType(_ authenticationType: AuthenticationType) {
        authenticateView.authenticationTypeButton.setTitle("\(authenticationType.displayName) ▼", for: .normal)
    }
}

extension MainViewController {
    // MARK: Layout

    private func layout() {
        displayScreen()

        view.subviews.forEach { $0.removeFromSuperview() }

        let topView = enrollView.isHidden ? authenticateView : enrollView
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        view.addConstraints([
            topView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            topView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 32.0),
        ])

        logView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logView)
        view.addConstraints([
            logView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            logView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            logView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16.0),
            logView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

    private func displayScreen() {
        logView.logTextView.isHidden = !Settings.showLogger
        logView.clearLogsButton.isHidden = !Settings.showLogger
        enrollView.isHidden = SCAAgent.isEnrolled()
        authenticateView.isHidden = !SCAAgent.isEnrolled()
        authenticateView.toggleUsernameEntry(Settings.username.isEmpty)
    }
}

extension MainViewController {
    // MARK: Risk SDK
    @objc func appDidBecomeActive(_ notification: Notification) {
        if viewIfLoaded?.window != nil {
            startAnalyze()
        }
    }

    @objc func appWillResignActive(_ notification: Notification) {
        if viewIfLoaded?.window != nil {
            RiskAgent.pauseAnalyze()
        }
    }

    // MARK: Private

    private func startAnalyze() {
        IDCANavigationController.startAnimating()
        view.isUserInteractionEnabled = false
        RiskAgent.startAnalyze(view: view) { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
            IDCANavigationController.stopAnimating()
        }
    }
}
