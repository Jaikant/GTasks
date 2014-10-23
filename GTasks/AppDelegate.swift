//
//  AppDelegate.swift
//  GTasks
//
//  Created by Jai on 18/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

@UIApplicationMain

//static const int ddLogLevel = LOG_LEVEL_VERBOSE;


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                
        
        // Get the size in CGRect for the physical screen on the phone
        var screen = UIScreen.mainScreen()
        var bounds = screen.bounds
        
        // Instantiate the main window for the size of the physical screen
        window = UIWindow(frame: bounds)
        
        //Create the Table View Controller
        /* Not needed now
        var firstController = TaskListsTableViewController() */
        
        var firstController = TasksTableViewController()
        
        // Create a Navigation Controller, with the TaskListsTableViewController as its root controller
        var tasksNavigationController = TasksNavigationController(rootViewController: firstController)
        
        //Global Settings
        var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName : UIColor.blackColor()]
        var baritem = UIBarButtonItem.appearance()
        baritem.setTitleTextAttributes(navigationbarTextAttr, forState: UIControlState.Normal)
        baritem.tintColor = UIColor.blackColor()
        tasksNavigationController.navigationBar.tintColor = UIColor.blackColor()
        
        
        //cofigure the toolbar

        tasksNavigationController.toolbarHidden = false
    
        
        // Create and attach the navigation controller to the main windows rootviewcontroller
        // and we are done!
        self.window?.rootViewController = tasksNavigationController
        self.window?.makeKeyAndVisible()
        
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


}

