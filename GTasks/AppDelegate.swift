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
    
    var firstController : TasksTableViewController?
    var tasksNavigationController : UINavigationController?
    
    var nowController : UrgentTasksTableViewController?
    var nowtasksNavigationController : UINavigationController?
    
    var mainTabBarController : UITabBarController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                
        let authObj = GoogleAuth()
        var sharedinst = TaskAndTasklistStore.singleInstance()
        sharedinst.initializeTheTasklistsAndTasks()
        
        // Get the size in CGRect for the physical screen on the phone
        let screen = UIScreen.mainScreen()
        let bounds = screen.bounds
        
        // Instantiate the main window for the size of the physical screen
        window = UIWindow(frame: bounds)
        
        if firstController == nil {
            firstController = TasksTableViewController()
            let barItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Favorites, tag: 0)
            firstController?.tabBarItem = barItem
            firstController?.restorationIdentifier = "firstController"
            firstController?.restorationClass = TasksTableViewController.classForCoder()
            firstController?.tableView.restorationIdentifier = "firstTableView"
        }
        
        
        if nowController == nil {
            nowController = UrgentTasksTableViewController()
            let barItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.MostRecent, tag: 0)
            nowController?.tabBarItem = barItem
            nowController?.restorationIdentifier = "nowController"
            nowController?.restorationClass = UrgentTasksTableViewController.classForCoder()
            nowController?.tableView.restorationIdentifier = "nowTableView"
        }

        
        // Create a Navigation Controller, with the TaskListsTableViewController as its root controller
        if tasksNavigationController == nil {
            tasksNavigationController = UINavigationController(rootViewController: firstController!)
            //Global Settings
            let navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName : UIColor.blackColor()]
            let baritem = UIBarButtonItem.appearance()
            baritem.setTitleTextAttributes(navigationbarTextAttr, forState: UIControlState.Normal)
            baritem.tintColor = UIColor.blackColor()
            tasksNavigationController?.navigationBar.tintColor = UIColor.blackColor()
            tasksNavigationController?.restorationIdentifier = "tasksNavigationController"
            tasksNavigationController?.restorationClass = UINavigationController.classForCoder()
        }
        
        
        if nowtasksNavigationController == nil {
            nowtasksNavigationController = UINavigationController(rootViewController: nowController!)
            //Global Settings
            let navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName : UIColor.blackColor()]
            let baritem = UIBarButtonItem.appearance()
            baritem.setTitleTextAttributes(navigationbarTextAttr, forState: UIControlState.Normal)
            baritem.tintColor = UIColor.blackColor()
            nowtasksNavigationController?.navigationBar.tintColor = UIColor.blackColor()
            nowtasksNavigationController?.restorationIdentifier = "nowtasksNavigationController"
            nowtasksNavigationController?.restorationClass = UINavigationController.classForCoder()
        }

        
        
        if mainTabBarController == nil {
            mainTabBarController = UITabBarController()
            mainTabBarController?.restorationIdentifier = "mainTabBarController"
            mainTabBarController?.restorationClass = UITabBarController.classForCoder()
            mainTabBarController?.view.restorationIdentifier = "tabbarView"
        }
        
        mainTabBarController?.viewControllers = [tasksNavigationController!, nowtasksNavigationController!]
        
        // Create and attach the navigation controller to the main windows rootviewcontroller
        // and we are done!
        self.window?.rootViewController = mainTabBarController
        self.window?.makeKeyAndVisible()
        
        if authObj.isTaskAuthorized() != true {
            mainTabBarController?.presentViewController(authObj.createAuthController(), animated: true, completion: {})
        }
        
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
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        var identifier = identifierComponents.last as? String
        println("\(identifier)")
       
        
        if identifier == "firstController" {
            println("creating first view controller")
            firstController = TasksTableViewController()
            var barItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Favorites, tag: 0)
            firstController?.tabBarItem = barItem
            firstController?.restorationIdentifier = "firstController"
            firstController?.restorationClass = TasksTableViewController.classForCoder()
            firstController?.tableView.restorationIdentifier = "firstTableView"
            return firstController
        }
        
        
        if identifier == "nowController" {
            println("creating nowController")
            nowController = UrgentTasksTableViewController()
            var barItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.MostRecent, tag: 0)
            nowController?.tabBarItem = barItem
            nowController?.restorationIdentifier = "nowController"
            nowController?.restorationClass = UrgentTasksTableViewController.classForCoder()
            nowController?.tableView.restorationIdentifier = "nowTableView"
            return nowController
        }

        
        if identifier == "tasksNavigationController" {
            println("creating tasksNavigationController!")
            tasksNavigationController = UINavigationController()
            //Global Settings
            var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName : UIColor.blackColor()]
            var baritem = UIBarButtonItem.appearance()
            baritem.setTitleTextAttributes(navigationbarTextAttr, forState: UIControlState.Normal)
            baritem.tintColor = UIColor.blackColor()
            tasksNavigationController?.navigationBar.tintColor = UIColor.blackColor()
            tasksNavigationController?.restorationIdentifier = "tasksNavigationController"
            tasksNavigationController?.restorationClass = UINavigationController.classForCoder()
            return tasksNavigationController
        }
        
        if identifier == "nowtasksNavigationController" {
            println("creating nowtasksNavigationController!")
            nowtasksNavigationController = UINavigationController()
            //Global Settings
            var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName : UIColor.blackColor()]
            var baritem = UIBarButtonItem.appearance()
            baritem.setTitleTextAttributes(navigationbarTextAttr, forState: UIControlState.Normal)
            baritem.tintColor = UIColor.blackColor()
            nowtasksNavigationController?.navigationBar.tintColor = UIColor.blackColor()
            nowtasksNavigationController?.restorationIdentifier = "nowtasksNavigationController"
            nowtasksNavigationController?.restorationClass = UINavigationController.classForCoder()

            return nowtasksNavigationController
        }

        if identifier == "tabbarcontroller" {
            println("creating tabbarcontroller!")
            mainTabBarController = UITabBarController()
            mainTabBarController?.restorationIdentifier = "mainTabBarController"
            mainTabBarController?.restorationClass = UITabBarController.classForCoder()
            mainTabBarController?.view.restorationIdentifier = "tabbarView"

            return mainTabBarController
        }
        return nil
    }
    
    func application(application: UIApplication, willEncodeRestorableStateWithCoder coder: NSCoder) {
        coder.encodeInteger(mainTabBarController!.selectedIndex, forKey: "selectedIndex")
    }
    
    func application(application: UIApplication, didDecodeRestorableStateWithCoder coder: NSCoder) {
        
        //Add the tableviewcontrollers to the stack of the navigation controller
        if firstController != nil {
            tasksNavigationController?.viewControllers = [firstController!] }
        if nowController != nil {
            nowtasksNavigationController?.viewControllers = [nowController!] }
        
        //Set the array of controllers for the tab bar controller
        mainTabBarController?.viewControllers = [tasksNavigationController!, nowtasksNavigationController!]
        
        //Restore the selected tab on the tab bar controller
        var selectedIndex = coder.decodeIntegerForKey("selectedIndex") as Int?
        if selectedIndex != nil {
        mainTabBarController?.selectedIndex = selectedIndex!
        }
    }

}

