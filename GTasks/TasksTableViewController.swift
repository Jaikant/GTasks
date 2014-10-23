//
//  TasksTableViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

// We may want to separate out the transitioningdelegate as a separate object.
class TasksTableViewController: UITableViewController, RMSwipeTableViewCellDelegate {
    
    lazy var tasklistsController: TaskListsTableViewController? = {
        var _tasklistsController = TaskListsTableViewController()
        return _tasklistsController    }()
    
    lazy var transitiondel : overlayTransitionDelegate? = {
        var _transitiondel = overlayTransitionDelegate()
        return _transitiondel    }()

    
    lazy var addTaskController: AddTaskViewController? = {
        var _addTaskController = AddTaskViewController()
        return _addTaskController    }()
    
    lazy var editTaskViewController: EditTaskViewController? = {
        var _editTaskViewController = EditTaskViewController()
        return _editTaskViewController    }()
    
    lazy var loadingIndicator : UIActivityIndicatorView? = {
        var _loadingIndicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: CGRectGetMinX(self.view.bounds), y: CGRectGetMinY(self.view.bounds) + 150), size: CGSize(width: self.view.bounds.width, height: 20)))
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        //_loadingIndicator.hidesWhenStopped = false //remains on screen even on error conditions
        return _loadingIndicator
        } ()

    
    var toolbar = UIToolbar()

    
    // Model related properties
    
    let kKeychainItemName : NSString = "Google Tasks Ver 0.14"
    let kClientID : NSString = "584241963529-vm7kjt16b0cfd9nq6lsjqtjl5tp9svb8.apps.googleusercontent.com"
    let kClientSecret : NSString = "pLWU-ReJN4j7wQ6cBSisZl0l"
    
    
    //Needed for Authentication
    var tasksService = GTLServiceTasks()

    var tasklist : GTLTasksTaskList? = nil
    
    var tasks : GTLTasksTasks? = nil
    
    //Flag to fetch task lists
    var fetchTasklist:Bool = true
    
    //Flag to fetch tasks
    var fetchTasks:Bool = false
    
    lazy var dateFormatter: NSDateFormatter? = {
        var _dateformatter = NSDateFormatter()
        _dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return _dateformatter
        } ()
    
    
    var taskAndTasklistsData = TaskAndTasklistStore()
    
    var initializeModel : Bool = true
    
    var countOfRows : Int = 0
    
    var tasksFromModel = GTLTasksTasks()

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
    
    func modelInitialized() {
    LogError.log("Received notification")
    initializeTableData()
    self.tableView.reloadData()
    }
    
    
    func initializeTableData() {
    countOfRows = Int(taskAndTasklistsData.countOfTasks)
    tasksFromModel = taskAndTasklistsData.fetchedSetOfTasks
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        //First authenticate
        var auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(kKeychainItemName, clientID: kClientID, clientSecret: kClientSecret)
        tasksService.authorizer = auth
        
        if initializeModel == true {
            self.taskAndTasklistsData = TaskAndTasklistStore(tasksService: tasksService)
            var notify = NSNotificationCenter.defaultCenter()
            notify.addObserver(self, selector: "modelInitialized", name: "ModelReady", object: nil)
            self.initializeModel = false
        }
        
        
        
        
        // The estimatedrowheight helps in the tableview automatic sizing look smooth
        // else there will be a visible resizing to the user. Also helps during rotation.
        tableView.estimatedRowHeight = 68.0
        
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor.lightGrayColor()

        
        //register the cell
        self.tableView.registerClass(TasksTableViewCell.classForCoder(), forCellReuseIdentifier: "tasks")
       
        /*
        //fetch the task lists
        if fetchTasklist {
            getTasksList()
        }

        //fetch the tasks, only after fetching the task list.
        if fetchTasks {
            getTasks()
        } */
        
        //Configure the navigation bar
        self.navigationItem.title = "Tasks"
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("RunAddTaskController"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: Selector("animateTaskListController"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
        
        
        //configure the toolbar
        var firsttoolitem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: Selector("firstToolItemSelector"))
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: Selector("secondToolItemSelector"))
        var secondtoolitem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: Selector("secondToolItemSelector"))
        
        var fourthtoolitem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: Selector("secondToolItemSelector"))

        var thirdtoolitem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: Selector("secondToolItemSelector"))
        
        var items : Array <AnyObject> = [space, firsttoolitem, space, secondtoolitem, space, thirdtoolitem, space, fourthtoolitem, space]

        self.toolbarItems = items
        

         }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.toolbarHidden = false
        self.navigationController?.hidesBarsOnSwipe = true
        
        
        LogError.log("1")
        
        
        if (isTaskAuthorized() == false) {
            self.presentViewController(self.createAuthController(), animated: true, completion: {})
        } else {            
            // Will need updation so it will fetch task list on change.
            
            /*
            
            if fetchTasklist {
                getTasksList()
            }
            if fetchTasks {
                getTasks()
            } */
        }
        //Possibly a bug in ios8, the cell does not resize till scroll
        // workaround to reload when view appears.
        // The estimated row size eems to fix this, hence no need to reload for now.
        self.tableView.reloadData()

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func animateTaskListController() {
        tasklistsController?.tasksController = self
        //tasklistsController?.tasksService = tasksService
        tasklistsController?.fetchTasklist = false
        //tasklistsController?.listTitleIdentifier = self.listTitleIdentifier
        //tasklistsController?.tasklists = tasklists  //To check fast enumeration
        tasklistsController?.taskAndTasklistsData = self.taskAndTasklistsData
        tasklistsController?.transitioningDelegate = transitiondel
        tasklistsController?.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        presentViewController(tasklistsController!, animated: true, completion: {})
    }

    func RunAddTaskController() -> Void {
        addTaskController?.tasklist = self.tasklist
        addTaskController?.tasksService = self.tasksService
        self.fetchTasks = true
        self.navigationController?.pushViewController(addTaskController!, animated: true)
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
        //return listTasks.count
        LogError.log("In tablview datasource")
        return countOfRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TasksTableViewCell {
       
        let tasksCell = tableView.dequeueReusableCellWithIdentifier("tasks", forIndexPath: indexPath) as? TasksTableViewCell
        
        // Configure the cell...
        
       
        var task = tasksFromModel.itemAtIndex(UInt(indexPath.row)) as GTLTasksTask

        tasksCell?.lbl.text = task.title

        var combined = "Notes: "
        var strdate = "\nDue Date: None"
        let note = task.notes
        
        let duedate = task.due
        
        if duedate != nil {
        strdate = "\nDue Date: " + (dateFormatter!.stringFromDate(task.due.date))
        }
        
        let statusDetail = "Status: " + task.status
        if note != nil {
            combined = note + strdate + ", " + statusDetail
        } else {
            combined = strdate + "," + statusDetail
        }
        tasksCell?.sublbl.text = combined
        

        tasksCell?.delegate = self
        tasksCell?.animationDuration = 0.5
        
        if task.status == "completed" {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
        } else {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
        }
        tasksCell?.statusImgGreyBut.addTarget(self, action: "updateStatusOnTask:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        return tasksCell!
    }

    func swipeTableViewCellWillResetState(swipeTableViewCell: RMSwipeTableViewCell!, fromPoint point: CGPoint, animation: RMSwipeTableViewCellAnimationType, velocity: CGPoint) {
        
        if (point.x < 0 && -point.x > CGRectGetHeight(swipeTableViewCell.frame)) {
            var index:NSIndexPath? = self.tableView.indexPathForCell(swipeTableViewCell)
            var currentRow: Int? = index?.row
            self.editTaskViewController!.tasklist = self.tasklist
            self.editTaskViewController?.task = self.taskAndTasklistsData.fetchedSetOfTasks.itemAtIndex(UInt(currentRow!)) as? GTLTasksTask
            editTaskViewController?.tasksService = self.tasksService
            self.fetchTasks = true
            self.navigationController?.pushViewController(editTaskViewController!, animated: true)
        }
        
        /*if (point.x > 0 && point.x > CGRectGetHeight(swipeTableViewCell.frame)) {
            self.navigationController?.pushViewController(tasksController!, animated: true)
        }*/

    }
    
    
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

    
    func firstToolItemSelector() {
        
    }
    
    func secondToolItemSelector() {
        
    }
    
    
    func updateStatusOnTask(but: UIButton) {
        //Retrieve the indexpath
        let cell = but.superview?.superview as TasksTableViewCell
        var index = self.tableView.indexPathForCell(cell)
        var currentRow: Int? = index?.row

        //retrieve the task
        var taskToUpdate : GTLTasksTask = taskAndTasklistsData.fetchedSetOfTasks.itemAtIndex(UInt(currentRow!)) as GTLTasksTask
        
        // Update the view
        if taskToUpdate.status == "completed" {
            but.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
            taskToUpdate.status = "needsAction"
            taskToUpdate.completed = nil
        } else {
            but.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
            taskToUpdate.status = "completed"
            taskToUpdate.completed = GTLDateTime(date: NSDate(), timeZone: NSTimeZone())
        }
        
        //update the model
        self.taskAndTasklistsData.modifyTaskForSpecifiedTasklist(taskAndTasklistsData.defaultTasklist!, task: taskToUpdate)
        
        //update the tableData
        tasksFromModel.itemAtIndex(UInt(currentRow!)).status = "completed"
    
    
    }
    
   /*
    func calAlertControl() {
        
        if secondImgGreyBut.alpha == 1.0 {
            
            LogError.log("setting alpha to 0")
            
            secondImgGreyBut.alpha = 0.0
            
        } else {
    
            LogError.log("setting alpha to 1")
            
            secondImgGreyBut.alpha = 1.0
            
        }
        
    }
    
    
    
    func delAlertControl() {
        
        if firstImgGreyBut.alpha == 1.0 {
            
            LogError.log("setting alpha to 0")
            
            firstImgGreyBut.alpha = 0.0
            
        } else {
            
            LogError.log("setting alpha to 1")
            
            firstImgGreyBut.alpha = 1.0
            
        }
        
    }
    

*/
    

    }
