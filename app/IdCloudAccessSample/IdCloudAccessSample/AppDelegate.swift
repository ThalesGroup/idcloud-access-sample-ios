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
    static let rootViewController: UINavigationController = {
        let viewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
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

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .extBackground
        window?.rootViewController = AppDelegate.rootViewController
        window?.makeKeyAndVisible()

        return true
    }
}
