//
//  TasksTableViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

// We may want to separate out the transitioningdelegate as a separate object.
class TasksTableViewController: UITableViewController, UIViewControllerRestoration, UIDataSourceModelAssociation {
    
    //MARK: CONTROLLERS
    
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

    
    //MARK: UTILITY 
    lazy var dateFormatter: NSDateFormatter? = {
        var _dateformatter = NSDateFormatter()
        _dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return _dateformatter
        } ()
    
    
    //MARK: DATASOURCE RELATED PROPERTIES
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    var countOfRows : Int = 0
    var tasksFromModel : Array<tasksStructWithListName> = []
    
    //MARK: ARCHIVING RELATED PROPERTIES

    //MARK: INIT
    override init() {
        super.init()
        self.taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
        var notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "modelInitialized", name: "ModelReady", object: nil)
        LogError.log("registered for notifications")
    }
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
   
    
    //MARK: INIT MODEL FUNCTIONS
    func modelInitialized() {
        LogError.log("Received notification")
        if taskAndTasklistsSharedObject != nil {
            initializeTableData()
            self.tableView.reloadData()
        }
    }
    
    func initializeTableData() {
    countOfRows = Int(taskAndTasklistsSharedObject!.defaultTasksDataSource.count)
    tasksFromModel = taskAndTasklistsSharedObject!.defaultTasksDataSource
    tasksFromModel += taskAndTasklistsSharedObject!.userDefaultTasksDataSource
    sort(&tasksFromModel, { (d1: tasksStructWithListName, d2: tasksStructWithListName) -> Bool in
        if d2.taskInfo.duedate != nil {
            var comparisonResults = d1.taskInfo.duedate?.compare(d2.taskInfo.duedate!)
            if comparisonResults == NSComparisonResult.OrderedAscending {
                return true } else {
                return false
            }
        }
        return true
        })
        
    //Free the memory in the model
    //taskAndTasklistsSharedObject!.defaultTasksDataSource = []
    }

    
    //MARK: STANDARD VIEWCONTROLLER FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // The estimatedrowheight helps in the tableview automatic sizing look smooth
        // else there will be a visible resizing to the user. Also helps during rotation.
        tableView.estimatedRowHeight = 68.0
        
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor.lightGrayColor()

        
        //register the cell
        self.tableView.registerClass(TasksTableViewCell.classForCoder(), forCellReuseIdentifier: "tasks")
       
        
        //Configure the navigation bar
        self.navigationItem.title = "Tasks"
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("RunAddTaskController"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: Selector("animateTaskListController"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
        
        
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Not really sure if the notification should be kept on for so long.
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //var notify = NSNotificationCenter.defaultCenter()
        //notify.removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.hidesBarsOnSwipe = true
        self.tabBarController?.hidesBottomBarWhenPushed = true
        
        //Possibly a bug in ios8, the cell does not resize till scroll
        // workaround to reload when view appears.
        // The estimated row size eems to fix this, hence no need to reload for now.
        self.tableView.reloadData()

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: TABLE VIEW DATA SOURCE

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksFromModel.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TasksTableViewCell {
       
        let tasksCell = tableView.dequeueReusableCellWithIdentifier("tasks", forIndexPath: indexPath) as? TasksTableViewCell
        
       
        var task = tasksFromModel[indexPath.row].taskInfo
        

        tasksCell?.lbl.text = task.title

        var combined = "Notes: "
        var strdate = "\nDue Date: None"
        
        var notes : String?
        
        if task.notes != nil {
            notes = task.notes }
        
        if task.duedate != nil {
            strdate = "\nDue Date: " + (dateFormatter!.stringFromDate(task.duedate!))
        }
        
        let statusDetail = "Status: " + task.status
        if notes != nil {
            combined = notes! + strdate + ", " + statusDetail
        } else {
            combined = strdate + "," + statusDetail
        }
        tasksCell?.sublbl.text = combined
        
        
        if task.status == "completed" {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
        } else {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
        }
        tasksCell?.statusImgGreyBut.addTarget(self, action: "updateStatusOnTask:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return tasksCell!
    }

    
    //MARK: CONTROLLER - CONTROLLER INTERACTION FUNCTIONS
    func animateTaskListController() {
        tasklistsController?.tasksController = self
        //tasklistsController?.tasksService = tasksService
        //tasklistsController?.listTitleIdentifier = self.listTitleIdentifier
        //tasklistsController?.tasklists = tasklists  //To check fast enumeration
        //tasklistsController?.taskAndTasklistsSharedObject = self.taskAndTasklistsSharedObject
        tasklistsController?.transitioningDelegate = transitiondel
        tasklistsController?.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        presentViewController(tasklistsController!, animated: true, completion: {})
    }
    
    func RunAddTaskController() -> Void {
     //   addTaskController?.tasksService = self.tasksService
       // addTaskController?.taskAndTasklistsSharedObject = self.taskAndTasklistsSharedObject
        //self.fetchTasks = true
        self.navigationController?.pushViewController(addTaskController!, animated: true)
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

    //MARK: CONTROLLER - VIEW INTERACTIONS FUNCTIONS
    
    func updateStatusOnTask(but: UIButton) {
        //Retrieve the indexpath
        let cell = but.superview?.superview as TasksTableViewCell
        var index = self.tableView.indexPathForCell(cell)
        var currentRow: Int? = index?.row

        //retrieve the task
        var taskToUpdate = tasksFromModel[currentRow!].taskInfo
        var tasklistToUpdate = tasksFromModel[currentRow!].tasklistInfo
        
        // Update the view
        if taskToUpdate.status == "completed" {
            but.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
            taskToUpdate.status = "needsAction"
       //     taskToUpdate.completed = nil (To be fixed)
        } else {
            but.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
            taskToUpdate.status = "completed"
          //  taskToUpdate.completed = GTLDateTime(date: NSDate(), timeZone: NSTimeZone()) (To be fixed)
        }
        
        //update the model
        //self.taskAndTasklistsSharedObject.modifyTaskForSpecifiedTasklist(taskAndTasklistsSharedObject.defaultTasklist!, task: taskToUpdate)
        self.taskAndTasklistsSharedObject!.modifyTaskForSpecifiedTasklist(tasklistToUpdate, task: taskToUpdate)
        //update the tableData
        //tasksFromModel.itemAtIndex(UInt(currentRow!)).status = "completed"
    
    
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
    

    //MARK: RESTORATION RELATED METHODS

    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        var ret = false
        var saveurl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        saveurl = saveurl.URLByAppendingPathComponent("gtasksData")
        
        ret = NSKeyedArchiver.archiveRootObject(tasksFromModel, toFile: saveurl.path!)
        println("In encode return for archive is \(ret)")
        
        
        
        var idx = self.tableView.indexPathForRowAtPoint(self.tableView.contentOffset)
        if idx != nil {
            var modelIdentifier : String = self.modelIdentifierForElementAtIndexPath(idx!, inView: self.tableView!)
            coder.encodeObject(modelIdentifier, forKey: "tableView.selectedModelIdentifier")
        }
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        //self.countOfRows = coder.decodeIntegerForKey("countOfRows")
        
        var saveurl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        saveurl = saveurl.URLByAppendingPathComponent("gtasksData")
        
        
        if NSFileManager.defaultManager().fileExistsAtPath(saveurl.path!){
            self.tasksFromModel = NSKeyedUnarchiver.unarchiveObjectWithFile(saveurl.path!) as Array<tasksStructWithListName>
            println("unarchived tasksfromModel \(self.tasksFromModel)")
        } else {
            println("did not unarchive no file present")
        }
        
        
        //For the view
        
        var modelIdentifier = coder.decodeObjectForKey("tableView.selectedModelIdentifier") as? String
        
        if modelIdentifier != nil {
            var indexPath = self.indexPathForElementWithModelIdentifier(modelIdentifier!, inView: self.tableView)
            
            if indexPath != nil {
                self.tableView.selectRowAtIndexPath(indexPath!, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
        }

    }
    
    func modelIdentifierForElementAtIndexPath(idx: NSIndexPath, inView view: UIView) -> String {
        
        var task = tasksFromModel[idx.row].taskInfo
        var identifier = task.title
        println("In modelIdentifierForElementAtIndexPath: \(identifier)")
        
        return identifier

    }
    
    func indexPathForElementWithModelIdentifier(identifier: String, inView view: UIView) -> NSIndexPath? {
        var indx = NSIndexPath(forRow: 0, inSection: 1)
        println("In indexPathForElementWithModelIdentifier \(identifier) ")
        
        var i = 0
        for obj in tasksFromModel {
            var txt = obj.taskInfo.title
            if txt == identifier {
                indx = NSIndexPath(forRow: i, inSection: 1)
                println("Setting indexpath for \(identifier)")
                self.tableView.reloadData()
                return indx
            }
            i++
        }
        
        println("In indexPathForElementWithModelIdentifier returning default")
        return indx
    }

    
    class func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        
        var identifier = identifierComponents.last as String
        println("viewControllerWithRestorationIdentifierPath are \(identifierComponents)")
        if identifier == "firstController" {
            println("creating first view controller")
            var shrdApp = UIApplication.sharedApplication()
            var delegate = shrdApp.delegate as AppDelegate
            delegate.firstController = TasksTableViewController()
            var barItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Favorites, tag: 0)
            delegate.firstController?.tabBarItem = barItem
            delegate.firstController?.restorationIdentifier = "firstController"
            delegate.firstController?.restorationClass = TasksTableViewController.classForCoder()
            delegate.firstController?.tableView.restorationIdentifier = "firstTableView"
            return delegate.firstController!
        }
        return nil
    }
    
}
