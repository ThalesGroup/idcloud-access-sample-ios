//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit.UIControl

extension UIControl {
    func addUnderline() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: bounds.height + 3, width: bounds.width, height: 1.5)
        bottomLine.backgroundColor = UIColor.systemGray.cgColor
        layer.addSublayer(bottomLine)
    }
}
