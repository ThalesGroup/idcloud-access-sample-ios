//
//
// Copyright © 2023 THALES. All rights reserved.
//

import UIKit
import os.log

struct PushNotificationConstants {
    static let didRegisterForRemoteNotificationsWithDeviceToken = Notification.Name(rawValue: "didRegisterForRemoteNotificationsWithDeviceToken")
    static let didFailToRegisterForRemoteNotificationsWithError = Notification.Name(rawValue: "didFailToRegisterForRemoteNotificationsWithError")
    static let didReceiveUserNotification = Notification.Name(rawValue: "didReceiveUserNotification")
}

struct PushNotificationUtil {
    typealias Completion = (Bool) -> Void

    static func registerForPushNotifications(completion: Completion?) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { (_, error) in
                if let error = error {
                    Logger.log("Failed to request authorization with error:  \(error.localizedDescription)")
                }
                getNotificationSettings(completion: completion)
            }
    }

    private static func getNotificationSettings(completion: Completion?) {
        UNUserNotificationCenter.current().getNotificationSettings {settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion?(true)
            case .denied, .notDetermined:
                completion?(false)
                return
            @unknown default:
                return
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
