//
//  TasksTableViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

// We may want to separate out the transitioningdelegate as a separate object.
class UrgentTasksTableViewController: UITableViewController {
    
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
    
    
    lazy var dateFormatter: NSDateFormatter? = {
        var _dateformatter = NSDateFormatter()
        _dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return _dateformatter
        } ()
    
    
    //MARK: DATASOURCE RELATED PROPERTIES
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    var countOfRows : Int = 0
    var tasksFromModel : Array<tasksStructWithListName> = []

    //MARK: INIT METHODS
    
    override init() {
        super.init()
        self.taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
        if taskAndTasklistsSharedObject != nil {
            // We force open optionals so the if check
            initializeDataSource()
        }
        registerForNotifications()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func registerForNotifications() {
        var notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "initializationComplete", name: "FILTEREDTASKSREADY", object: nil)
    }
    
    func initializationComplete() {
        initializeDataSource()
        dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})
    }
    
    func initializeDataSource() {
        countOfRows = Int(taskAndTasklistsSharedObject!.nowTasksDataSource.count)
        tasksFromModel = taskAndTasklistsSharedObject!.nowTasksDataSource
        //Free the memory in the model, this causing a few tasks from not getting updated
        // So commenting it out for now.
        //taskAndTasklistsSharedObject?.nowTasksDataSource = []
    }
    

    //MARK: CONTROLLER METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The estimatedrowheight helps in the tableview automatic sizing look smooth
        // else there will be a visible resizing to the user. Also helps during rotation.
        tableView.estimatedRowHeight = 68.0
        
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor.lightGrayColor()
        
        //register the cell
        self.tableView.registerClass(TasksTableViewCell.classForCoder(), forCellReuseIdentifier: "cellTask")
        
        
        //Configure the navigation bar
        self.navigationItem.title = "Tasks"
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("RunAddTaskController"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        /*
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: Selector("animateTaskListController"))
        self.navigationItem.leftBarButtonItem = leftButton */
        
        var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.navigationController?.hidesBarsOnSwipe = true
        self.tabBarController?.hidesBottomBarWhenPushed = true
        
        //Possibly a bug in ios8, the cell does not resize till scroll
        // workaround to reload when view appears.
        // The estimated row size eems to fix this, hence no need to reload for now.
        self.tableView.reloadData()
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func RunAddTaskController() -> Void {
        self.navigationController?.pushViewController(addTaskController!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksFromModel.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TasksTableViewCell {
        
        let tasksCell = tableView.dequeueReusableCellWithIdentifier("cellTask", forIndexPath: indexPath) as? TasksTableViewCell
        
        // Configure the cell...
        
        var task = tasksFromModel[indexPath.row].taskInfo
        
        tasksCell?.lbl.text = task.title
        
        var combined = "Notes: "
        var strdate = "Due Date: None"
        let note = task.notes
        let tasklist = "\nTasklist: " + tasksFromModel[indexPath.row].tasklistInfo.title
        
        let duedate = task.duedate
        if duedate != nil {
            strdate = "\nDue Date: " + (dateFormatter!.stringFromDate(task.duedate!))
        }
        
        let statusDetail = "Status: " + task.status
        combined = strdate + "," + statusDetail
        
        
        
        
        tasksCell?.sublbl.text = combined + " " + tasklist
        
        if task.status == "completed" {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
        } else {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
        }
        tasksCell?.statusImgGreyBut.addTarget(self, action: "updateStatusOnTask:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        return tasksCell!
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
    
    
    func updateStatusOnTask(but: UIButton) {
        /*
        //Retrieve the indexpath
        let cell = but.superview?.superview as TasksTableViewCell
        var index = self.tableView.indexPathForCell(cell)
        var currentRow: Int? = index?.row
        
        //retrieve the task
        var taskToUpdate : GTLTasksTask = taskAndTasklistsSharedObject.fetchedSetOfTasks.itemAtIndex(UInt(currentRow!)) as GTLTasksTask
        
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
        self.taskAndTasklistsSharedObject.modifyTaskForSpecifiedTasklist(taskAndTasklistsSharedObject.defaultTasklist!, task: taskToUpdate)
        
        //update the tableData
        //tasksFromModel.itemAtIndex(UInt(currentRow!)).status = "completed"
        
        */
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
