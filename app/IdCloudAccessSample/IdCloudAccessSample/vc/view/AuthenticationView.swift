//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

class AuthenticationView: UIView {
    let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.text = NSLocalizedString("username_label", comment: "")
        usernameLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        return usernameLabel
    }()
    let usernameValueLabel: UILabel = {
        let usernameValueLabel = UILabel()
        usernameValueLabel.text = Settings.username
        usernameValueLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        return usernameValueLabel
    }()
    let usernameTextField: UITextField = {
        let usernameTextField = UITextField()
        usernameTextField.placeholder = NSLocalizedString("username_textfield_placeholder", comment: "")
        usernameTextField.font = UIFont.preferredFont(forTextStyle: .title3)
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.returnKeyType = .done
        usernameTextField.isHidden = true
        return usernameTextField
    }()
    let authenticationTypeLabel: UILabel = {
        let authenticationTypeLabel = UILabel()
        authenticationTypeLabel.text = NSLocalizedString("authentication_type_label", comment: "")
        authenticationTypeLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        return authenticationTypeLabel
    }()
    let authenticationTypeButton: UIButton = {
        let authenticationTypeButton = UIButton(type: .system)
        authenticationTypeButton.setTitle("\(Settings.authenticationType.displayName) ▼", for: .normal)
        authenticationTypeButton.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        authenticationTypeButton.setTitleColor(.extButton, for: .normal)
        authenticationTypeButton.contentHorizontalAlignment = .leading
        return authenticationTypeButton
    }()
    let authenticateSignInButton: UIButton = {
        let authenticateSignInButton = UIButton()
        authenticateSignInButton.setTitle(NSLocalizedString("sign_in_button_title", comment: ""), for: .normal)
        authenticateSignInButton.setTitleColor(.extBlue, for: .highlighted)
        authenticateSignInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        authenticateSignInButton.backgroundColor = .extBlue
        authenticateSignInButton.layer.cornerRadius = 8.0
        return authenticateSignInButton
    }()

    init() {
        super.init(frame: .zero)
        usernameTextField.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        usernameTextField.delegate = self
    }

    func toggleUsernameEntry(_ toEnter: Bool) {
        usernameValueLabel.isHidden = toEnter
        usernameTextField.isHidden = !toEnter
    }

    override func layoutSubviews() {
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameLabel)
        addConstraints([
            usernameLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
        ])

        usernameValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameValueLabel)
        addConstraints([
            usernameValueLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            usernameValueLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            usernameValueLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16.0),
        ])

        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameTextField)
        addConstraints([
            usernameTextField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16.0),
        ])

        authenticationTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(authenticationTypeLabel)
        addConstraints([
            authenticationTypeLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            authenticationTypeLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            authenticationTypeLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16.0),
        ])

        authenticationTypeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(authenticationTypeButton)
        addConstraints([
            authenticationTypeButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            authenticationTypeButton.topAnchor.constraint(equalTo: authenticationTypeLabel.bottomAnchor, constant: 8.0),
        ])

        authenticateSignInButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(authenticateSignInButton)
        addConstraints([
            authenticateSignInButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            authenticateSignInButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            authenticateSignInButton.topAnchor.constraint(equalTo: authenticationTypeButton.bottomAnchor, constant: 16.0),
            authenticateSignInButton.heightAnchor.constraint(equalTo: authenticationTypeLabel.heightAnchor, multiplier: 2.0),
            authenticateSignInButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])

        super.layoutSubviews()
        authenticationTypeButton.addUnderline()
        usernameTextField.addUnderline()
    }
}

extension AuthenticationView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
