//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit

class LogView: UIView {
    let logTextView: UITextView = {
        let logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.layer.cornerRadius = 16.0
        logTextView.layer.borderWidth = 1.0
        logTextView.layer.borderColor = UIColor.systemGray.cgColor
        return logTextView
    }()
    let clearLogsButton: UIButton = {
        let clearLogsButton = UIButton(type: .system)
        clearLogsButton.setTitle(NSLocalizedString("clear_logs_button_title", comment: ""), for: .normal)
        clearLogsButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        return clearLogsButton
    }()

    init() {
        super.init(frame: .zero)
        Logger.setLogView(logTextView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Logger.setLogView(logTextView)
    }

    override func layoutSubviews() {
        clearLogsButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clearLogsButton)
        addConstraints([
            clearLogsButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            clearLogsButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])

        logTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logTextView)
        addConstraints([
            logTextView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            logTextView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            logTextView.bottomAnchor.constraint(equalTo: clearLogsButton.topAnchor, constant: -8.0),
            logTextView.topAnchor.constraint(equalTo: topAnchor)
        ])

        super.layoutSubviews()
    }
}
