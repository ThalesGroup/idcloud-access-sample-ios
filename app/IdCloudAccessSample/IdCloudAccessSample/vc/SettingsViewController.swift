//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

fileprivate typealias TapClosure = (IndexPath) -> Void

fileprivate struct Section {
    let name: String
    let rows: [Row]
}

fileprivate struct Row {
    let name: String
    let rowType: RowType
    let tapClosure: TapClosure?

    init(name: String, rowType: RowType = .normal, tapClosure: TapClosure? = nil) {
        self.name = name
        self.rowType = rowType
        self.tapClosure = tapClosure
    }
}

fileprivate enum RowType: String, CaseIterable {
    case subtitle = "UITableViewCellSubtitle"
    case checkmark = "UITableViewCellCheckmark"
    case destructive = "UITableViewCellDestructive"
    case normal = "UITableViewCell"

    var reuseIdentifier: String {
        return self.rawValue
    }
}

class SettingsViewController: UIViewController {
    private let tableView = UITableView()
    private var dataSource: [Section] = []
    private lazy var scaAgent = SCAAgent()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("settings_title", comment: "")
        view.backgroundColor = .extBackground

        setupTableView()
        setupDataSource()
        setupLayout()
        
        navigationItem.rightBarButtonItems = [
            IDCANavigationController.activityIndicatorBarButton
        ]
    }

    // MARK: Setup

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        for rowType in RowType.allCases {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: rowType.reuseIdentifier)
        }
    }
    private func setupDataSource() {
        dataSource = [
            Section(name: NSLocalizedString("settings_version_title", comment: ""),
                    rows: [
                        Row(name: "Protector FIDO", rowType: .subtitle),
                        Row(name: "IdCloud Risk", rowType: .subtitle)
                    ]),
            Section(name: NSLocalizedString("settings_configuration_idp_title", comment: ""),
                    rows: [
                        Row(name: "IDP URL", rowType: .subtitle, tapClosure: { [weak self] indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "IDP URL",
                                                                 text: Settings.idpURLString) { [weak self] value in
                                Settings.idpURLString = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                        Row(name: "Redirect URL", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "Redirect URL",
                                                                 text: Settings.redirectURLString) { [weak self] value in
                                Settings.redirectURLString = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                        Row(name: "Client ID", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "Client ID",
                                                                 text: Settings.clientID) { [weak self] value in
                                Settings.clientID = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                        Row(name: "Client Secret", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "Client Secret",
                                                                 text: Settings.clientSecret) { [weak self] value in
                                Settings.clientSecret = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        })
                    ]),
            Section(name: NSLocalizedString("settings_configuration_fido_title", comment: ""),
                    rows: [
                        Row(name: "MS URL", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "MS URL",
                                                                 text: Settings.msURLString) { [weak self] value in
                                Settings.msURLString = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                        Row(name: "Tenant ID", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "Tenant ID",
                                                                 text: Settings.tenantID) { [weak self] value in
                                Settings.tenantID = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                    ]),
            Section(name: NSLocalizedString("settings_configuration_risk_title", comment: ""),
                    rows: [
                        Row(name: "ND URL", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "ND URL",
                                                                 text: Settings.ndURLString) { [weak self] value in
                                Settings.ndURLString = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                        Row(name: "Risk Client ID", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "Risk Client ID",
                                                                 text: Settings.riskClientID) { [weak self] value in
                                Settings.riskClientID = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                        Row(name: "Risk URL", rowType: .subtitle, tapClosure: { indexPath in
                            UIAlertController.showTextFieldAlert(viewController: self,
                                                                 title: "Risk URL",
                                                                 text: Settings.riskURLString) { [weak self] value in
                                Settings.riskURLString = value
                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }),
                    ]),
            Section(name: NSLocalizedString("settings_general_title", comment: ""),
                    rows: [
                        Row(name: NSLocalizedString("settings_showlogs_title", comment: ""), rowType: .checkmark, tapClosure: { _ in
                            Settings.showLogger = !Settings.showLogger
                        }),
                        Row(name: NSLocalizedString("settings_refreshtoken_title", comment: ""), rowType: .normal, tapClosure: { _ in
                            PushNotificationUtil.registerForPushNotifications { [unowned self] isAuthorized in
                                if !isAuthorized {
                                    DispatchQueue.main.async {
                                        UIAlertController.showAlert(viewController: self,
                                                                    title: NSLocalizedString("alert_error_title", comment: ""),
                                                                    message: NSLocalizedString("settings_refreshtoken_error_message", comment: ""))
                                    }
                                } else {
                                    NotificationCenter.default.addObserver(self,
                                                                           selector: #selector(updatePushToken(_:)),
                                                                           name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken,
                                                                           object: nil)
                                }
                            }
                        }),
                        Row(name: NSLocalizedString("settings_reset_title", comment: ""), rowType: .destructive, tapClosure: { [weak self] _ in
                            Settings.username = ""
                            Settings.authenticationType = .rba
                            Logger.clearLogs()

                            self?.scaAgent.unenroll { [weak self] error in
                                if let error = error {
                                    UIAlertController.showErrorAlert(viewController: self,
                                                                     error: error)
                                } else {
                                    UIAlertController.showToast(viewController: self,
                                                                title: NSLocalizedString("settings_reset_title", comment: ""),
                                                                message: NSLocalizedString("alert_success_msg", comment: "")) {
                                        let vc = LandingViewController()
                                        self?.navigationController?.setViewControllers([vc], animated: true)
                                    }
                                }
                            }
                        }),
                    ])
        ]
    }

    private func setupLayout() {
        guard tableView.translatesAutoresizingMaskIntoConstraints
            else {
                return
        }

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    // MARK: Push Notification Listeners
    
    @objc func updatePushToken(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)

        guard let deviceToken = notification.object as? String else {
            return
        }
        
        scaAgent.refreshPushToken(deviceToken: deviceToken) { error in
            if let error = error {
                UIAlertController.showErrorAlert(viewController: self,
                                                 error: error)
            } else {
                UIAlertController.showToast(viewController: self,
                                            title: NSLocalizedString("settings_refreshtoken_title", comment: ""), message: NSLocalizedString("alert_success_msg", comment: ""))
            }
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].name
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        var cell: UITableViewCell
        switch row.rowType {
        case .subtitle:
            cell = UITableViewCell(style: .value1, reuseIdentifier: row.rowType.reuseIdentifier)
        case .destructive:
            cell = UITableViewCell(style: .default, reuseIdentifier: row.rowType.reuseIdentifier)
            cell.textLabel?.textColor = .red
        case .normal, .checkmark:
            cell = UITableViewCell(style: .default, reuseIdentifier: row.rowType.reuseIdentifier)
        }

        cell.textLabel?.text = row.name

        switch (indexPath.section, indexPath.row) {
        case (0, 0): // Protector FIDO SDK version
            cell.detailTextLabel?.text = SCAAgent.sdkVersion()
        case (0, 1): // IdCloud Risk SDK version
            cell.detailTextLabel?.text = RiskAgent.sdkVersion()
        case (1, 0):
            cell.detailTextLabel?.text = Settings.idpURLString
        case (1, 1):
            cell.detailTextLabel?.text = Settings.redirectURLString
        case (1, 2):
            cell.detailTextLabel?.text = Settings.clientID
        case (1, 3):
            cell.detailTextLabel?.text = Settings.clientSecret
        case (2, 0):
            cell.detailTextLabel?.text = Settings.msURLString
        case (2, 1):
            cell.detailTextLabel?.text = Settings.tenantID
        case (3, 0):
            cell.detailTextLabel?.text = Settings.ndURLString
        case (3, 1):
            cell.detailTextLabel?.text = Settings.riskClientID
        case (3, 2):
            cell.detailTextLabel?.text = Settings.riskURLString
        case (4, 0): // Show logs
            cell.accessoryType = Settings.showLogger ? .checkmark : .none
        case (4, 1),
            (4, 2): // Reset
            break
        default:
            fatalError("Unexpected {section, row}: {\(indexPath.section), \(indexPath.row)}")
        }

        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = dataSource[indexPath.section].rows[indexPath.row]
        row.tapClosure?(indexPath)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
