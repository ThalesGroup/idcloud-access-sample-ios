//
//
// Copyright © 2023 THALES. All rights reserved.
//
    

import UIKit

class LandingViewController: UIViewController {
    // Landing
    private let landingView: LandingView = {
        let landingView = LandingView()
        return landingView
    }()

    private lazy var scaAgent = SCAAgent()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .extBackground
        title = NSLocalizedString("main_title", comment: "")
        let settingsBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(settings(_:)))
        navigationItem.rightBarButtonItems = [
            settingsBarButtonItem,
            IDCANavigationController.activityIndicatorBarButton
        ]

        landingView.scanButton.addTarget(self, action: #selector(scanQR(_:)), for: .touchUpInside)
        landingView.noButton.addTarget(self, action: #selector(goToMain(_:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layout()
    }

    // MARK: IBAction

    @objc func scanQR(_ barButtonItem: UIBarButtonItem) {
        IDCANavigationController.startAnimating()
        let vc = QRScannerViewController { [weak self] (aCode) in
            guard let qrCode = aCode else {
                return
            }
            self?.scaAgent.enroll(enrollmentToken: qrCode) { [weak self] idcaError in
                if let error = idcaError {
                    Logger.log("Enrollment failed with error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        IDCANavigationController.stopAnimating()
                        UIAlertController.showErrorAlert(viewController: self,
                                                         error: error)
                    }
                } else {
                    Logger.log("Enrollment completed")
                    DispatchQueue.main.async {
                        IDCANavigationController.stopAnimating()
                        let vc = MainViewController()
                        UIAlertController.showToast(viewController: self?.navigationController,
                                                    title: NSLocalizedString("register_button_title", comment: ""),
                                                    message: NSLocalizedString("alert_success_msg", comment: "")) {
                            self?.navigationController?.setViewControllers([vc], animated: true)
                        }
                    }
                }
            }
        }
        navigationController?.present(vc, animated: true)
    }

    @objc func goToMain(_ barButtonItem: UIBarButtonItem) {
        let vc = MainViewController()
        navigationController?.setViewControllers([vc], animated: true)
    }

    @objc func settings(_ barButtonItem: UIBarButtonItem) {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
}

// MARK: Layout
extension LandingViewController {
    private func layout() {
        view.subviews.forEach { $0.removeFromSuperview() }

        landingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(landingView)
        view.addConstraints([
            landingView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            landingView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            landingView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 32.0),
            landingView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])
    }
}
