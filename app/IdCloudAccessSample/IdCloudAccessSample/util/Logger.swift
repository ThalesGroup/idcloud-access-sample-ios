//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit
import os.log

struct Logger {
    private static var logView: UITextView?
    private static var logs: String = "" {
        didSet {
            logView?.text = logs
            logView?.scrollRangeToVisible(NSRange(location: logs.count - 1, length: logs.count))
        }
    }
    private static let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: "IdCloud Access")

    static func setLogView(_ textView: UITextView) {
        self.logView = textView
    }

    static func log(_ message: String) {
        logs += "\(Date()): \(message)\n"
        os_log("%{public}@", log: log, type: .info, message)
    }

    static func clearLogs() {
        logs = ""
    }
}
