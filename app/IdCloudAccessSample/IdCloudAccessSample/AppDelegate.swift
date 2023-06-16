//
//
// Copyright © 2022 THALES. All rights reserved.
//
    

import UIKit
import IdCloudClient

// A known issue was filed with Apple regarding UI thread error:
// https://developer.apple.com/forums/thread/712074
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static let rootViewController: IDCANavigationController = {
        var viewController: UIViewController
        if SCAAgent.isEnrolled() {
            viewController = MainViewController()
        } else {
            viewController = LandingViewController()
        }
        let navigationController = IDCANavigationController(rootViewController: viewController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .extBackground
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
        
        return navigationController
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Assert Configurations
        Configuration.assertConfigurations()

        // Configure Protector FIDO
        SCAAgent.prepareAgent()

        // MARK: Register Push notifications
        UNUserNotificationCenter.current().delegate = self
        PushNotificationUtil.registerForPushNotifications(completion: nil)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .extBackground
        window?.rootViewController = AppDelegate.rootViewController
        window?.makeKeyAndVisible()

        return true
    }
}

// MARK: Push Notifications

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Settings.devicePushToken = token
        Logger.log("Device token: \(String(describing: token))")
        NotificationCenter.default.post(name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken, object: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.log("Failed to register remote notification with error: \(error.localizedDescription)")
        NotificationCenter.default.post(name: PushNotificationConstants.didFailToRegisterForRemoteNotificationsWithError, object: nil)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
         Logger.log("Received remote notification payload: \(userInfo)")
        NotificationCenter.default.post(name: PushNotificationConstants.didReceiveUserNotification, object: userInfo)
         completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: PushNotificationConstants.didReceiveUserNotification, object: userInfo)

        completionHandler()
    }
}
