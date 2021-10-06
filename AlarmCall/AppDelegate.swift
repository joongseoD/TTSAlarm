//
//  AppDelegate.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/03.
//

import UIKit
import AVFoundation
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setUpRootViewController()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    private func setUpRootViewController() {
        let navigationController = UINavigationController()
//        navigationController.navigationBar.isHidden = true
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        navigationController.transition(to: .main, operation: .root)
    }
//
//    func applicationWillResignActive(_ application: UIApplication) {
//        var timer = Timer(fireAt: Date(timeIntervalSinceNow: 20), interval: 60.0, target: self, selector: #selector(playAlarm), userInfo: nil, repeats: true)
//
//        RunLoop.current.add(timer, forMode: .default)
//    }
//
//    @objc func playAlarm() {
//        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "sound", ofType: "caf")!)
//        let audioPlayer = try? AVAudioPlayer(contentsOf: sound)
//        audioPlayer?.play()
//    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.alert, .banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let url = response.notification.request.content.userInfo
        
        completionHandler()
    }
}

