//
//  TaskListsTableViewController.swift
//  GTasks
//
//  Created by Jai on 18/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TaskListsTableViewController: UITableViewController, RMSwipeTableViewCellDelegate {
    
   
    // Controller related properties
    
    lazy var addTasklistController: AddTasklistViewController? = {
        var _addTasklistController = AddTasklistViewController()
        return _addTasklistController    }()
    
    /* Not needed now
    lazy var tasksController: TasksTableViewController? = {
        var _tasksController = TasksTableViewController()
        return _tasksController    }()
     */
    
    var tasksController: TasksTableViewController?
    
    lazy var editTasklistController: EditTaskListViewController? = {
        var _editTasklistController = EditTaskListViewController()
        return _editTasklistController    }()
    
    
    lazy var loadingIndicator : UIActivityIndicatorView? = {
        var _loadingIndicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: CGRectGetMinX(self.view.bounds), y: CGRectGetMinY(self.view.bounds) + 150), size: CGSize(width: self.view.bounds.width, height: 20)))
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        //_loadingIndicator.hidesWhenStopped = false //remains on screen even on error conditions
        return _loadingIndicator
    } ()
    
    
    /* lazy var errorController : UIAlertController? = {
        var _errorController = UIAlertController()
        return _errorController } ()
    */
    let errorController = UIAlertController()
    
    // If I remove the lazy from this it gives a weird kind of compiler error!
    lazy var alertAction : UIAlertAction? = {
        var _alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in println("")})
        return _alertAction } ()
    
    //var alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in println("Alert given")})
    

    // Model related properties

    let kKeychainItemName : NSString = "Google Tasks Ver 0.14"
    let kClientID : NSString = "584241963529-vm7kjt16b0cfd9nq6lsjqtjl5tp9svb8.apps.googleusercontent.com"
    let kClientSecret : NSString = "pLWU-ReJN4j7wQ6cBSisZl0l"

    //Needed for Authentication
    var tasksService = GTLServiceTasks()
    
    
    //To Store the fetched Task lists
    var tasklists: GTLTasksTaskLists? = GTLTasksTaskLists()
    
    // To store the ticket received for the query.
    var tasklistsTicket = GTLServiceTicket()
    
    // An array of task list objects, so that we can retrieve the count and populate the table.
    var listTitleIdentifier : Array<GTLTasksTaskList?> = [GTLTasksTaskList?]()
    
    //Flag to fetch task lists
    var fetchTasklist:Bool = true

    
    var taskRelatedFetchError:NSError? = NSError()
    
    
    
    lazy var dateFormatter: NSDateFormatter? = {
        var _dateformatter = NSDateFormatter()
        _dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return _dateformatter
    } ()
    
    
    var taskAndTasklistsData = TaskAndTasklistStore()
    
    
    var dispatch_q : dispatch_queue_t?
    
    func drawErrorTxt(#errorTitle: String, errorMsg: String?) {
        
        // Text view which starts at 20,20 relative to current bounds. With a width of 40 pixels less than bounding view and a height of 
        // 80 pixels
        // Fixit - Does this work on iphone 6? The view below can be made a tableView instead!
        let bnds = self.view.bounds
        var errorlbl = UILabel(frame: CGRect(origin: CGPoint(x: CGRectGetMinX(bnds), y: CGRectGetMinY(bnds) + 150), size: CGSize(width: bnds.width, height: 20)))
        errorlbl.text = errorTitle
        errorlbl.textAlignment = NSTextAlignment.Center
        //fixit if the dynamic font size is max the text clips.
        errorlbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        
        var errDesclbl = UILabel(frame: CGRect(origin: CGPoint(x: CGRectGetMinX(bnds), y: CGRectGetMinY(bnds) + 170), size: CGSize(width: bnds.width, height: 20)))
        errDesclbl.text = "Tap to retry"
        errDesclbl.textAlignment = NSTextAlignment.Center
        errDesclbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        
        
        self.tableView.backgroundView?.addSubview(errorlbl)
        //self.tableView.backgroundView?.bringSubviewToFront(errorlbl)
        
        self.tableView.backgroundView?.addSubview(errDesclbl)
        //self.tableView.backgroundView?.bringSubviewToFront(errDesclbl)

    }
    
    
    func configureAndPresentDismissErrorController(#errorTitle: String, errorMsg: String?) {
        self.errorController.title = errorTitle
        self.errorController.message = errorMsg?
        
        if self.errorController.actions.isEmpty == true {
            self.errorController.addAction(self.alertAction!)
            }
        self.presentViewController(self.errorController, animated: true, completion: {})
    }
    
    // checks if we have authorization in the key chain. In ViewDidLoad we update this value from the keychain.
    // In viewDidAppear we check for it.
    func isTaskAuthorized() -> Bool {
        return (self.tasksService.authorizer as GTMOAuth2Authentication).canAuthorize
    }
    
    // This function not only checks authorization in key chain, but also checks the level of authorization by checking
    // if the email address is accessbile. If the email address is accessible.
    func signedInUserName() -> NSString? {
        
        var auth = self.tasksService.authorizer
        var isSignedIn = auth.canAuthorize
        
        if (isSignedIn == true) {
            return auth.userEmail
        } else {
            return nil
        }
    }
    
    //If for some reason this call fails, there is no fallback. This call should not fail because we always
    //authorize asking for full access.
    func isSignedIn() -> Bool {
        var name = signedInUserName()
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
            self.tasksService.authorizer = nil
        } else {
            self.tasksService.authorizer = authResult
            self.dismissViewControllerAnimated(false, completion: {})
        }
    }
    
    
    func getTasksList() {
        
        if isSignedIn() {

            var query = GTLQueryTasks.queryForTasklistsList() as GTLQueryTasks
            var service = self.tasksService
            
            self.tableView.backgroundView?.addSubview(loadingIndicator!)
            self.loadingIndicator?.startAnimating()
            tasklistsTicket = service.executeQuery(query, completionHandler: {(ticket, tasklistsReturned, error)-> Void in
                self.tasklists = tasklistsReturned as? GTLTasksTaskLists
                self.taskRelatedFetchError = error
                if error == nil {
                    self.loadingIndicator?.stopAnimating()
                    self.updatelistTitleIdentifier()
                } else {
                    self.loadingIndicator?.stopAnimating()
                    LogError.log("\(error)")
                    // fix it, need a list of errors for below.
                    let errmsg = error.localizedDescription
                    var failurereason : String? = error.localizedFailureReason
                    
                    self.drawErrorTxt(errorTitle: errmsg, errorMsg: failurereason?)
                    //self.configureAndPresentDismissErrorController(errorTitle: errmsg, errorMsg: failurereason?) //Internet not working, There was no response from Google, check your internet connection
                }
                
            })
        } else {
            LogError.log(" User not signed in")
        }
        
    }
    
    func updatelistTitleIdentifier() -> Void {
        var list : GTLTasksTaskList? = nil
        var index2:UInt = 0
        //temp storage of title and list.
        var _listTitleIdentifier : Array<GTLTasksTaskList?> = [GTLTasksTaskList?]()

        do {
            list = self.tasklists?.itemAtIndex(index2++ as UInt) as? GTLTasksTaskList
        if list != nil { /* if condition to prevent the last item to be nil */
            _listTitleIdentifier.append(list)}
        }  while list != nil
        self.listTitleIdentifier = _listTitleIdentifier
        // Will need update dynamically as it will fetch only once now
        self.tableView.reloadData()
        self.fetchTasklist = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Configure the background of the tableView
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor.lightGrayColor()
        tableView.layer.cornerRadius = 5.0


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.registerClass(TaskListsTableViewCell.classForCoder(), forCellReuseIdentifier: "tasklists")
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.toolbarHidden = true
        
        dispatch_q = dispatch_queue_create("tasklists_queue", nil)
        
        
        // fixit for tasklist addition or deletion
        /*
        if fetchTasklist {
            getTasksList()
        } */
    }
    /*
    override func prefersStatusBarHidden() -> Bool {
        return true
    } */
    
    func RunAddTasklistController() -> Void {
        addTasklistController?.tasksService = self.tasksService
        self.fetchTasklist = true
        self.navigationController?.pushViewController(addTasklistController!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        //return listTitleIdentifier.count
        return Int(taskAndTasklistsData.countOfTasklists)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TaskListsTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tasklists", forIndexPath: indexPath) as TaskListsTableViewCell

        // Configure the cell...
        
        var tasklist = taskAndTasklistsData.fetchedSetOfTasklists.itemAtIndex(UInt(indexPath.row)) as GTLTasksTaskList
        cell.textLabel?.text = tasklist.title
        var strdate = dateFormatter?.stringFromDate((tasklist.updated.date)!)
        cell.detailTextLabel?.text = "Last Update: " + strdate!
        
        cell.delegate = self
        cell.animationDuration = 0.2
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var currentRow: Int? = indexPath.row
        LogError.log("\(currentRow)")

        var selectedTasklist : GTLTasksTaskList = taskAndTasklistsData.fetchedSetOfTasklists.itemAtIndex(UInt(indexPath.row)) as GTLTasksTaskList
        taskAndTasklistsData.defaultTasklist = selectedTasklist
        taskAndTasklistsData.getTasksForSpecifiedTasklist(selectedTasklist)
        
        dispatch_async(dispatch_get_main_queue(), {self.dismissViewControllerAnimated(true, completion: {println("Viewcontroller dismissed")})})
    }
    
    func swipeTableViewCellShouldCleanupBackView(swipeTableViewCell: RMSwipeTableViewCell!) -> Bool {
        return false
    }
    
    func swipeTableViewCellWillResetState(swipeTableViewCell: RMSwipeTableViewCell!, fromPoint point: CGPoint, animation: RMSwipeTableViewCellAnimationType, velocity: CGPoint) {
        
        if (point.x > 0 && point.x > CGRectGetHeight(swipeTableViewCell.frame)) {
            var index:NSIndexPath? = self.tableView.indexPathForCell(swipeTableViewCell)
            var currentRow: Int? = index?.row
            self.editTasklistController!.tasklist = self.listTitleIdentifier[currentRow!]?
            editTasklistController?.tasksService = self.tasksService
            self.fetchTasklist = true
            /* not needed now
            self.navigationController?.pushViewController(editTasklistController!, animated: true) */
        }
        
        if  (point.x < 0 && -point.x > CGRectGetHeight(swipeTableViewCell.frame)){
            self.tasksController?.tasksService = self.tasksService
            var index:NSIndexPath? = self.tableView.indexPathForCell(swipeTableViewCell)
            var currentRow: Int? = index?.row
            self.tasksController?.tasklist = self.listTitleIdentifier[currentRow!]?
            self.tasksController?.fetchTasks = true
            /* not needed now
            self.navigationController?.pushViewController(tasksController!, animated: true) */
        }
    }
    

}
