//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

class EnrollView: UIView {
    let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.text = NSLocalizedString("username_label", comment: "")
        usernameLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        return usernameLabel
    }()
    let usernameTextField: UITextField = {
        let usernameTextField = UITextField()
        usernameTextField.placeholder = NSLocalizedString("username_textfield_placeholder", comment: "")
        usernameTextField.font = UIFont.preferredFont(forTextStyle: .title3)
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.returnKeyType = .done
        return usernameTextField
    }()
    let registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle(NSLocalizedString("register_button_title", comment: ""), for: .normal)
        registerButton.setTitleColor(.extBlue, for: .highlighted)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        registerButton.backgroundColor = .extBlue
        registerButton.layer.cornerRadius = 8.0
        return registerButton
    }()
    let signInButton: UIButton = {
        let signInButton = UIButton()
        signInButton.setTitle(NSLocalizedString("sign_in_button_title", comment: ""), for: .normal)
        signInButton.setTitleColor(.extBlue, for: .highlighted)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        signInButton.backgroundColor = .extBlue
        signInButton.layer.cornerRadius = 8.0
        return signInButton
    }()

    init() {
        super.init(frame: .zero)
        usernameTextField.delegate = self
}

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        usernameTextField.delegate = self
    }

    override func layoutSubviews() {
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameLabel)
        addConstraints([
            usernameLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
        ])

        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameTextField)
        addConstraints([
            usernameTextField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16.0),
        ])

        registerButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(registerButton)
        addConstraints([
            registerButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            registerButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 24.0),
            registerButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])

        signInButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(signInButton)
        addConstraints([
            signInButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            signInButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 24.0),
            signInButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])

        addConstraints([
            signInButton.leadingAnchor.constraint(equalTo: registerButton.trailingAnchor, constant: 16.0),
            registerButton.widthAnchor.constraint(equalTo: signInButton.widthAnchor),
            registerButton.heightAnchor.constraint(equalTo: signInButton.heightAnchor),
            registerButton.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor, multiplier: 2.0)
        ])

        super.layoutSubviews()
        usernameTextField.addUnderline()
    }
}

extension EnrollView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
