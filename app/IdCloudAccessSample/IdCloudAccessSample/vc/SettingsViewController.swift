//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

fileprivate typealias TapClosure = () -> Void

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
            Section(name: NSLocalizedString("settings_general_title", comment: ""),
                    rows: [
                        Row(name: NSLocalizedString("settings_showlogs_title", comment: ""), rowType: .checkmark, tapClosure: {
                            Settings.showLogger = !Settings.showLogger
                        }),
                        Row(name: NSLocalizedString("settings_reset_title", comment: ""), rowType: .destructive, tapClosure: { [weak self] in
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
                                        self?.navigationController?.popViewController(animated: true)
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
        case (1, 0): // Show logs
            cell.accessoryType = Settings.showLogger ? .checkmark : .none
        case (1, 1): // Reset
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
        row.tapClosure?()
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
