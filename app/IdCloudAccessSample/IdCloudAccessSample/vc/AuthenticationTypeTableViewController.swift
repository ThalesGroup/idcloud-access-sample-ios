//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

class AuthenticationTypeTableViewController: UITableViewController {
    let reuseIdentifier = "UITableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AuthenticationType.allCases.count
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let authenticationType = AuthenticationType.allCases[indexPath.row]
        cell.textLabel?.text = authenticationType.displayName
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let authenticationType = AuthenticationType.allCases[indexPath.row]
        Settings.authenticationType = authenticationType
        dismiss(animated: true)
    }
}

extension AuthenticationTypeTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
