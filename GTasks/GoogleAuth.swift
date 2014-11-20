//
//  GoogleAuth.swift
//  GTasks
//
//  Created by Jai on 02/11/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//


import Foundation
var tasksService = GTLServiceTasks()

class GoogleAuth : NSObject {
    
    let kKeychainItemName : NSString = "Google Tasks Ver 0.33"
    let kClientID : NSString = "584241963529-vm7kjt16b0cfd9nq6lsjqtjl5tp9svb8.apps.googleusercontent.com"
    let kClientSecret : NSString = "pLWU-ReJN4j7wQ6cBSisZl0l"
    
    struct authFlag {
        static var flag : dispatch_once_t = 0
        static var authInstance : GoogleAuth?
    }
    
    private override init() {
        //First authenticate
        super.init()
        tasksService.authorizer = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(kKeychainItemName, clientID: kClientID, clientSecret: kClientSecret)
    }
    
    class func sharedInstance() -> GoogleAuth {
        dispatch_once(&(authFlag.flag), { () -> Void in
            authFlag.authInstance = GoogleAuth()
        })
        if authFlag.authInstance != nil {
            return authFlag.authInstance!
        } else {
            sleep(1)
            LogError.log("ERROR:**** authInstance in NIL! This should never be the case")
            //To avoid crashing sleep and try again, , crash if need be.
            return authFlag.authInstance!
        }
    }
    
    
    // checks if we have authorization in the key chain. In ViewDidLoad we update this value from the keychain.
    // In viewDidAppear we check for it.
    func isTaskAuthorized() -> Bool {
        return (tasksService.authorizer as GTMOAuth2Authentication).canAuthorize
    }
    
    // This function not only checks authorization in key chain, but also checks the level of authorization by checking
    // if the email address is accessbile. If the email address is accessible.
    private func signedInUserName() -> NSString? {
        
        let auth = tasksService.authorizer
        let isSignedIn = auth.canAuthorize
        
        if (isSignedIn == true) {
            return auth.userEmail
        } else {
            return nil
        }
    }
    
    //If for some reason this call fails, there is no fallback. This call should not fail because we always
    //authorize asking for full access.
    private func isSignedIn() -> Bool {
        let name = signedInUserName()
        return (name != nil)
    }
    
    // Creates the auth controller for authorizing access to Google Tasks.
    func createAuthController() -> GTMOAuth2ViewControllerTouch {
        return GTMOAuth2ViewControllerTouch(scope: kGTLAuthScopeTasks,
            clientID: kClientID,
            clientSecret: kClientSecret,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: Selector("viewController:finishedWithAuth:error:"))
        
    }
    
    // Handle completion of the authorization process, and updates the Task service
    // with the new credentials.
    func viewController(viewController: GTMOAuth2ViewControllerTouch , finishedWithAuth authResult: GTMOAuth2Authentication , error:NSError! ) {
        if error != nil {
            LogError.log("Authorization error: \(error)")
            tasksService.authorizer = nil
        } else {
            tasksService.authorizer = authResult
            NSNotificationCenter.defaultCenter().postNotificationName("AuthComplete", object: nil)
            dispatch_async(dispatch_get_main_queue(), {
                viewController.dismissViewControllerAnimated(false, completion: {})
            })
        }
    }
    
}