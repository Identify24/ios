//
//  AppDelegate.swift
//  NewTest
//
//  Created by Emir Beytekin on 10.10.2022.
//

import UIKit
import IQKeyboardManagerSwift
import netfox
import IdentifySDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.        
        UIApplication.shared.isIdleTimerDisabled = true
        IQKeyboardManager.shared.enable = true
        NFX.sharedInstance().start()
        startFirstScreen()
        return true
    }
    
    func startFirstScreen() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let firstVC = SDKLoginViewController()
        let firstNC = UINavigationController(rootViewController: firstVC)
        UINavigationBar.appearance().tintColor = .white
//        UINavigationBar.appearance().prefersLargeTitles = false
//        UINavigationBar.appearance().backgroundColor = KHTheme.grayColor
//        UIBarButtonItem.appearance().tintColor = .white // pushtan sonra ki sayfanın buton rengi
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.window?.rootViewController = firstNC
        self.window?.makeKeyAndVisible()
    }
    
    func setupForOldPhone() {
        let firstVC = SDKLoginViewController()
        let firstNC = UINavigationController(rootViewController: firstVC)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().backgroundColor = IdentifyTheme.blueColor

    }

}



