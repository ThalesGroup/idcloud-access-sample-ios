//
//
// Copyright © 2023 THALES. All rights reserved.
//
    

import UIKit

class LandingView: UIView {
    let qrCodeLabel: UILabel = {
        let qrCodeLabel = UILabel()
        qrCodeLabel.text = NSLocalizedString("qrcode_label", comment: "")
        qrCodeLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        qrCodeLabel.numberOfLines = 0
        return qrCodeLabel
    }()
    let scanButton: UIButton = {
        let scanButton = UIButton()
        scanButton.setTitle(NSLocalizedString("scan_button_title", comment: ""), for: .normal)
        scanButton.setTitleColor(.extBlue, for: .highlighted)
        scanButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        scanButton.titleLabel?.numberOfLines = 0
        scanButton.titleLabel?.textAlignment = .center
        scanButton.backgroundColor = .extBlue
        scanButton.layer.cornerRadius = 8.0
        return scanButton
    }()
    let noButton: UIButton = {
        let noButton = UIButton()
        noButton.setTitle(NSLocalizedString("no_button_title", comment: ""), for: .normal)
        noButton.setTitleColor(.extBlue, for: .highlighted)
        noButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        noButton.backgroundColor = .extBlue
        noButton.layer.cornerRadius = 8.0
        return noButton
    }()

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        qrCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(qrCodeLabel)
        addConstraints([
            qrCodeLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            qrCodeLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            qrCodeLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
        ])

        scanButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scanButton)
        addConstraints([
            scanButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            scanButton.topAnchor.constraint(equalTo: qrCodeLabel.bottomAnchor, constant: 24.0),
        ])

        noButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(noButton)
        addConstraints([
            noButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            noButton.topAnchor.constraint(equalTo: qrCodeLabel.bottomAnchor, constant: 24.0),
        ])

        addConstraints([
            noButton.leadingAnchor.constraint(equalTo: scanButton.trailingAnchor, constant: 16.0),
            scanButton.widthAnchor.constraint(equalTo: noButton.widthAnchor),
            scanButton.heightAnchor.constraint(equalTo: noButton.heightAnchor),
        ])

        super.layoutSubviews()
    }
}
