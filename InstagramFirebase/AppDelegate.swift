//
//  AppDelegate.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/13/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        
        attemptRegisterForNotifications(application: application)
        
        return true
    }
    
    //show notifcations while application was in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Registered with FCM with token:", fcmToken)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered For Notifications:", deviceToken)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func attemptRegisterForNotifications(application: UIApplication) {
        print("Attempting to register APNS...")
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        // user notification authorization
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            if let err = err {
                print("Failed to grant authorization: ", err)
                return
            }
            if granted {
                print("Auth granted")
            } else {
                print("Auth denied")
            }
        }
        application.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let followerId = userInfo["followerId"] as? String {
            //Push userProfileController for followerId
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.userId = followerId
            
            //How to access main UI from Appdelegate
            if let mainTabBarController = window?.rootViewController as? MainTabBarController {
                
                mainTabBarController.selectedIndex = 0
                //for when on the photoselector page and need to get to followed user
                mainTabBarController.presentedViewController?.dismiss(animated: true, completion: nil)
                
                if let homeNavController = mainTabBarController.viewControllers?.first as? UINavigationController {
                    homeNavController.pushViewController(userProfileController, animated: true)
                }
            }
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

