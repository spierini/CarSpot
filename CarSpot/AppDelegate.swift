//
//  AppDelegate.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 4/25/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

/**  ADDITIONAL INFORMATION FOR GRADING
 *
 * The app will send a notification to the user (foreground and background) when 1 minute remaining on timer. An Alarm will trigger at 00:00
 * The user will get a notification on their garage timer when their maximum price preference has been reached. to test this just set the max price to $0.00 and start the timer. An alert and notification will be triggered
 * You must 'Save' a spot in order to add it to the database and the 'Find Car' table view
 * Pin color represents traffic data at the 3 default parking garages in SLO. Blue means N/A
 */

import UIKit
import UserNotifications
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.'
        FIRApp.configure()

        return true
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

