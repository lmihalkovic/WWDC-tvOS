//
//  AppDelegate.swift
//  WWDC
//
//  Created by Guilherme Rambo on 19/11/15.
//  Copyright © 2015 Guilherme Rambo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        let fm = NSFileManager.defaultManager()
//        let docDir = try? fm.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
//        debugPrint("Doc: \(docDir!)")
        LiveEventObserver.SharedObserver().start(window!.rootViewController!)
        
        AppModel.sharedModel.reloadSessions()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) where components.scheme == "wwdc",
              let host = components.host,
              let key = url.lastPathComponent else { return false }
        
        switch host {
            case "play":
                playSessionWithKey("\(key)")
            case "show":
                displaySessionWithKey("\(key)")
        default:
            return false
        }
        
        return true
    }
    
    private var sessionsViewController: RootMenuViewController? {
        guard let rootController = window?.rootViewController as? RootMenuViewController else { return nil }
        return rootController
    }
    
    private func displaySessionWithKey(key: String) {
        guard let videosVC = sessionsViewController else { return }
        videosVC.displaySession(key)
    }
    
    private func playSessionWithKey(key: String) {
        guard let videosVC = sessionsViewController else { return }
        videosVC.playSession(key)
    }


}

