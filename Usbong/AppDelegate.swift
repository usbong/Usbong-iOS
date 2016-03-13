//
//  AppDelegate.swift
//  Usbong
//
//  Created by Chris Amanse on 11/26/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import UsbongKit

struct SampleTree {
    static let fileName = "Usbong iOS"
    static let ext = "utree"
}

struct UsbongNotification {
    static let CopiedTreeInApp = "ph.usbong.Usbong.CopiedTreeInApp"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let launchedKey = "launched-\(UIApplication.appVersion)"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print("App Version: \(UIApplication.appVersion)")
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.barTintColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1)
        navBarAppearance.translucent = false
        navBarAppearance.tintColor = UIColor.whiteColor()
        navBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
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
        guard let fileNameExtension = url.pathExtension else { return false }
        guard let fileName = url.URLByDeletingPathExtension?.lastPathComponent else { return false }
        
        switch fileNameExtension {
        case "utree":
            // Copy .utree files to Documents/
            
            print("Opening file: \(url)")
            let fileManager = NSFileManager.defaultManager()
            let rootURL = UsbongFileManager.defaultManager().rootURL
            
            // If filename exists, add suffix with the appropriate count
            var suffixNumber = 0
            var newURL = rootURL
            
            repeat {
                let suffix = suffixNumber == 0 ? "" : "-\(suffixNumber)"
                newURL = rootURL.URLByAppendingPathComponent("\(fileName)\(suffix)").URLByAppendingPathExtension(fileNameExtension)
                
                suffixNumber++
            } while fileManager.fileExistsAtPath(newURL.path!)
            
            print("Copying file to: \(newURL.path!)")
            
            do {
                try fileManager.moveItemAtURL(url, toURL: newURL)
                
                NSNotificationCenter.defaultCenter().postNotificationName(UsbongNotification.CopiedTreeInApp, object: nil)
                
                print("Successfully copied file!")
                return true
            } catch {
                print("Failed to copy file")
                return false
            }
        default:
            return false
        }
    }
}

extension UIApplication {
    static var appVersion: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "0.0"
    }
}
