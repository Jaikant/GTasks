//
//  TasksTableViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit
extension UIColor {
    class func applicationGreenColor() -> UIColor {
        return UIColor(red: 0.255, green: 0.804, blue: 0.470, alpha: 1)
    }
    
    class func applicationBlueColor() -> UIColor {
        return UIColor(red: 0.333, green: 0.784, blue: 1, alpha: 1)
    }
    
    class func applicationPurpleColor() -> UIColor {
        return UIColor(red: 0.659, green: 0.271, blue: 0.988, alpha: 1)
    }
}


// We may want to separate out the transitioningdelegate as a separate object.
class TasksTableViewController: UITableViewController, UIViewControllerRestoration, UIDataSourceModelAssociation {
    
    //MARK: CONTROLLERS
    
    lazy var tasklistsController: TaskListsTableViewController? = {
        var _tasklistsController = TaskListsTableViewController()
        return _tasklistsController }()
    
    
    lazy var transitiondel : overlayTransitionDelegate? = {
        var _transitiondel = overlayTransitionDelegate()
        return _transitiondel    }()

    
    lazy var addTaskController: AddTaskViewController? = {
        var _addTaskController = AddTaskViewController()
        return _addTaskController    }()
    
    
    lazy var modifyTaskViewController: ModifyTaskViewController? = {
        var _editTaskViewController = ModifyTaskViewController()
        return _editTaskViewController    }()

    
    lazy var loadingIndicator : UIActivityIndicatorView? = {
        var _loadingIndicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: CGRectGetMinX(self.view.bounds), y: CGRectGetMinY(self.view.bounds) + 150), size: CGSize(width: self.view.bounds.width, height: 20)))
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        //_loadingIndicator.hidesWhenStopped = false //remains on screen even on error conditions
        return _loadingIndicator
        } ()

    
    let errorController = UIAlertController()
    

    
    //MARK: DATASOURCE RELATED PROPERTIES
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    var countOfRows : Int = 0
    var tasksFromModel : Array<tasksStructWithListName> = []
    
    var userNowTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var userNextTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var userLaterTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    
    
    
    //Datasource for add task
    var tasklistsForPicker : Array<tasklistStruct> = []
    //defaulttasklist information for setting title of view controller
    var defaultTasklist : tasklistStruct?
    
    
    //cell type
    let kcellTask : String = "cellTask"
    let knotificationTaskSynced : String = "knotificationTaskSynced"
    
    

    //MARK: INIT
    override init() {
        super.init()
        
        self.taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
        

        
        var notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "modelInitialized", name: "ModelReady", object: nil)
    //    notify.addObserver(self, selector: "includeNewOfflineTaskIntoDataSource", name: "NEWTASK", object: nil)
        notify.addObserver(self, selector: "deleteFailAlert", name: "NOTIFYDELETEFAILED", object: nil)
        notify.addObserver(self, selector: "updateTaskSyncOnCell", name: knotificationTaskSynced, object: nil)
        notify.addObserver(self, selector: "updateDefaultTasksOnInitialization", name: "FILTEREDTASKSREADY", object: nil)


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
   
    func updateDefaultTasksOnInitialization() {
        
        LogError.log("**** Received  Init Complete notification****")

        
        if defaultTasklist == nil && taskAndTasklistsSharedObject?.tasklistsArray.count != 0 {
            defaultTasklist = taskAndTasklistsSharedObject?.tasklistsArray[0]
            taskAndTasklistsSharedObject!.updateDefaultTaskDataSourcesAndSendNotification(defaultTasklist!)
        }
    }
    
    //MARK: INIT MODEL FUNCTIONS
    func modelInitialized() {
        LogError.log("Received ModelReady notification")
        
        
        if taskAndTasklistsSharedObject != nil {
            initializeTableData()
            setDefaultTasklist();
            setTitleOnVc()
            self.tableView.reloadData()
        }
    }
    
    func initializeTableData() {
    
    LogError.log("Reseting default VC datasource to shared object datasource")

    tasksFromModel.removeAll(keepCapacity: false)
    tasksFromModel = taskAndTasklistsSharedObject!.defaultTasksDataSource
    tasksFromModel += taskAndTasklistsSharedObject!.userDefaultTasksDataSource
    sort(&tasksFromModel, { (d1: tasksStructWithListName, d2: tasksStructWithListName) -> Bool in
        if d2.taskInfo.updated != nil {
            var comparisonResults = d1.taskInfo.updated?.compare(d2.taskInfo.updated!)
            if comparisonResults == NSComparisonResult.OrderedDescending {
                return true } else {
                return false
            }
        }
        return true
        })
    countOfRows = tasksFromModel.count
    // The below if loop will prevent the tasklists to get "reset" when the app is being
    // worked on in a offline mode from initialization onwards.
    if taskAndTasklistsSharedObject!.tasklistsArray.count != 0 {
        tasklistsForPicker = taskAndTasklistsSharedObject!.tasklistsArray
    }
    //Free the memory in the model
    //taskAndTasklistsSharedObject!.defaultTasksDataSource = []
    }

    
   
    
    //Commenting out this function, wbut will leave it here if it is needed later. For now every time
    //the controller appears i.e in viewwillappear we are reseting the datasource. This will ensure all
    //new tasks are included in the view. There is no evident disadvantage of this mechanism and it adds
    //to the simplicity of the design or rather avoids the complications or messiness of notifications.
    

    /*
    
    func includeNewOfflineTaskIntoDataSource() {
        println("Received notification of new task in default VC")
        
        //If loop to prevent a race condition crash is the last element is deleted before it is appeneded here.
        //This race condition is just a remote possibility as the model runs independently and will empty the the
        // userDefaultTasksDataSource array as soon as it downloads the task into the synced datasource. So if the
        // loop fails it means that - In the timebetween adding the task into userDefaults, the download of the task
        // was also completed and hence the array was cleared before the notification response kicked in.

        
        if taskAndTasklistsSharedObject!.userDefaultTasksDataSource.last != nil {
            tasksFromModel.append(taskAndTasklistsSharedObject!.userDefaultTasksDataSource.last!)
            
            // Sort the task by due date
            sort(&tasksFromModel, { (d1: tasksStructWithListName, d2: tasksStructWithListName) -> Bool in
                if d2.taskInfo.updated != nil {
                    var comparisonResults = d1.taskInfo.updated?.compare(d2.taskInfo.updated!)
                    if comparisonResults == NSComparisonResult.OrderedDescending {
                        return true } else {
                        return false
                    }
                }
                return true
            })
        }
        
        //Now that the only added task has been included in the dataSource. Lets check all the tasks for their sync status
        // and update the image on the cell to convey where the task resides. Actually only one task has changed, but we are
        // going through the whole list, because this task sits in a sorted manner in the tableView. 
        // We could also get the task identifier and update the sync image only on the aded task. - Performance improvement
        
        // Another way to do it would have been to keep the newly added tasks right on top. -  User experience enhancement?

        updateSyncImageOnTask()
    }
    */
    
    func setDefaultTasklist() {
        if taskAndTasklistsSharedObject?.defaultTasklist != nil {
            defaultTasklist = taskAndTasklistsSharedObject?.defaultTasklist
        }
    }
    
    
    //MARK: STANDARD VIEWCONTROLLER FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // The estimatedrowheight helps in the tableview automatic sizing look smooth
        // else there will be a visible resizing to the user. Also helps during rotation.
        tableView.estimatedRowHeight = 200.0

        
        self.tableView.separatorColor = UIColor.lightGrayColor()
        
        //The background view could be used to display activity indicators or error messages.
        // Currently nothing is happening on this.
        self.tableView.backgroundView = UIView()
        
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        //register the cell
        self.tableView.registerClass(TasksTableViewCell.classForCoder(), forCellReuseIdentifier: kcellTask)

       
        
        //Configure the navigation bar
        
        
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("pushAddTaskController"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: Selector("presentTaskListController"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
        
        
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // When the addTask or Modify Task is popped, we are checking to see if we need to 
        // update our datasources to the model. Doing this is easier than expecting the 
        // modify controller to update the datasource for this controller.
        // This step should not affect user experience as the user popped the view controller
        // so it gives us an opportunity to prepare our datasource without the user seeing any aberrations.
        // The modifications and additions done by the user in the previous controller should get 
        // reflected here.
        
        if taskAndTasklistsSharedObject?.initSuccessAndDataSourcesValid == true {
            
            if taskAndTasklistsSharedObject?.defaultTasksDataSource.count == 0{
                // This check is only applicable for the first time after the app is started from a restore, when a user
                // selects to modify or add a task and returns back to default task controller.
                println("Initializing the defaultTasksDataSource")
                taskAndTasklistsSharedObject!.updateDefaultTaskDataSourcesAndSendNotification(defaultTasklist!)
            }
            initializeTableData()
        } else {
            LogError.log("ALERT: Using VC datasource as shared object datasource is not ready")
        }
        
        setTitleOnVc()
    }
    
    //Not really sure if the notification should be kept on for so long.
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //var notify = NSNotificationCenter.defaultCenter()
        //notify.removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        modifyTaskViewController?.customTask = tasksFromModel[indexPath.row]
        modifyTaskViewController?.tasklistsForPicker = tasklistsForPicker
        //modifyTaskViewController?.transitioningDelegate = transitiondel
        //modifyTaskViewController?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

        self.navigationController?.pushViewController(modifyTaskViewController!, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TasksTableViewCell {
        
        var tasksCell : TasksTableViewCell?
        
        
        tasksCell = tableView.dequeueReusableCellWithIdentifier(kcellTask, forIndexPath: indexPath) as? TasksTableViewCell

       
        var task = tasksFromModel[indexPath.row].taskInfo
        
        if tasksFromModel[indexPath.row].sync == true {
            tasksCell?.syncStatusImageView.image = UIImage(named: "syncTrue.png")
        } else {
            tasksCell?.syncStatusImageView.image = UIImage(named: "syncFalse.png")
        }
        
        tasksCell?.lbl.text = task.title //+ "--" + task.identifier //debug
        //tasksCell?.lbl.numberOfLines = 0  //debug
        
        if tasksCell != nil {
        updateDetailLabelOnCell(tasksCell!, row: indexPath.row)
        }
        
        /*
        if task.status == "completed" {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
        } else {
            tasksCell?.statusImgGreyBut.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
        }*/
        tasksCell?.statusImgGreyBut.addTarget(self, action: "updateStatusOnTask:", forControlEvents: UIControlEvents.TouchUpInside)
        
        tasksCell?.firstImgGreyBut.addTarget(self, action: "promptForDelete:", forControlEvents: UIControlEvents.TouchUpInside)
        
        tasksCell?.secondImgGreyBut.addTarget(self, action: "promptForDateChange:", forControlEvents: UIControlEvents.TouchUpInside)

        return tasksCell!
    }


    
    //MARK: CONTROLLER - CONTROLLER INTERACTION FUNCTIONS
    func presentTaskListController() {
        
        
        tasklistsController?.tasksController = self
        tasklistsController?.tasklistsDataSource = tasklistsForPicker
        tasklistsController?.transitioningDelegate = transitiondel
        tasklistsController?.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(tasklistsController!, animated: true, completion: {})
    }
    
    
    func pushAddTaskController() -> Void {
     //   addTaskController?.tasksService = self.tasksService
       // addTaskController?.taskAndTasklistsSharedObject = self.taskAndTasklistsSharedObject
        //self.fetchTasks = true
        
        addTaskController?.tasklistsForPicker = tasklistsForPicker
        self.navigationController?.pushViewController(addTaskController!, animated: true)
    }

    

    //MARK: CONTROLLER - VIEW INTERACTIONS FUNCTIONS
    
    func deleteFailAlert() {
        showSimpleAlert(self, "Delete Unsucessful", "Task not deleted. Check your connection.")
    }
    
    func noDueDateAlert() {
        showSimpleAlert(self, "End Date Not Set", "Selected task does not have an end date. First set an end date.")
    }

    
    func updateDetailLabelOnCell(tasksCell : TasksTableViewCell, row: Int) {
    
    var customTask = tasksFromModel[row]

    var combined = "Notes: "
    var strdate = "\nDue Date: None"

    var notes : String?
    
    if customTask.taskInfo.notes != nil {
    notes = customTask.taskInfo.notes }
    
    if customTask.taskInfo.duedate != nil {
    strdate = "\nDue Date: " + (dateFormatter!.stringFromDate(customTask.taskInfo.duedate!))
    }
    
    let statusDetail = "Status: " + customTask.taskInfo.status
    if notes != nil {
    combined = notes! + strdate + ", " + statusDetail
    } else {
    combined = strdate + "," + statusDetail
    }
    tasksCell.sublbl.text = combined
        
    // Update the view
    if customTask.taskInfo.status == "completed" {
        tasksCell.statusImgGreyBut.setImage(UIImage(named: "4-green.png"), forState: UIControlState.Normal)
    } else {
        tasksCell.statusImgGreyBut.setImage(UIImage(named: "4-grey.png"), forState: UIControlState.Normal)
    }

    tasksCell.secondImgGreyBut.setImage(UIImage(named: "calendar.png"), forState: UIControlState.Normal)
    tasksCell.firstImgGreyBut.setImage(UIImage(named: "1-grey.png"), forState: UIControlState.Normal)

    }
    
    func updateStatusOnTask(but: UIButton) {
        //Retrieve the indexpath
        let cell = but.superview?.superview as TasksTableViewCell
        var index = self.tableView.indexPathForCell(cell)
        var currentRow: Int? = index?.row

        //retrieve the task
        var customTask = tasksFromModel[currentRow!]
        
        if customTask.taskInfo.status == "completed" {
            customTask.taskInfo.status = "needsAction"
            //     taskToUpdate.completed = nil (To be fixed)
        } else {
            customTask.taskInfo.status = "completed"
            //  taskToUpdate.completed = GTLDateTime(date: NSDate(), timeZone: NSTimeZone()) (To be fixed)
        }
        
        updateDetailLabelOnCell(cell, row: currentRow!)
        if customTask.sync == true {
        self.taskAndTasklistsSharedObject!.modifyTaskForSpecifiedTasklist(customTask)
        }

        LogError.log("\(tasksFromModel[currentRow!].taskInfo.status)")
    }
    
    func updateTaskSyncOnCell() {
        tableView.reloadData()
    }
    
    func promptForDelete(but: UIButton) -> Void {
        
        //Retrieve the indexpath
        let cell = but.superview?.superview as TasksTableViewCell
        var index = self.tableView.indexPathForCell(cell)
        var currentRow: Int? = index?.row
        
        //retrieve the task
        var customTask = tasksFromModel[currentRow!]
        
        // Update the view
        but.setImage(UIImage(named: "1-red.png"), forState: UIControlState.Normal)
        
        LogError.log("About to present  error controller")
        if index != nil {
            showDeleteActionSheet(index!, customTask, cell, self)
        } else {
            LogError.log("indexpath is nil, delete failed")
        }
        
    }
    
    
    func promptForDateChange(but: UIButton) -> Void {
        
        //Retrieve the indexpath
        let cell = but.superview?.superview as TasksTableViewCell
        var index = self.tableView.indexPathForCell(cell)
        var currentRow: Int? = index?.row
        
        //retrieve the task
        var customTask = tasksFromModel[currentRow!]
        
        // Update the view
        but.setImage(UIImage(named: "calendar-red.png"), forState: UIControlState.Normal)
        
        if index != nil {
            if customTask.taskInfo.duedate != nil {
               showDueDateActionSheet(index!, customTask, cell, self)
            } else {
               noDueDateAlert()
               updateDetailLabelOnCell(cell, row: currentRow!)

            }
        } else {
            LogError.log("indexpath is nil, change date failed failed")
        }
        //configureAndPresentDismissErrorController(errorTitle: "Delete Task?", errorMsg: customTask.taskInfo.title)
    }

    
    func updateSyncImageOnTask() -> Void {
        //Retrieve the indexpath
        var i = 0
        for tasks in tasksFromModel {
            if tasks.sync == false {
                updateImage(i)
                return
            }
            i++
        }
    }
    
    func updateImage(row : Int) {
        var indexpath = NSIndexPath(forRow: row, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexpath) as? TasksTableViewCell
        if cell != nil {
        cell!.syncStatusImageView.image = UIImage(named: "syncFalse.png")
        } else {
            LogError.log("ERROR: cell is nil")
        }
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
    
    
    func setTitleOnVc(){
        if defaultTasklist != nil {
            self.navigationItem.title = defaultTasklist?.title
        } else {
            self.navigationItem.title = "Google Tasks Buddy"
        }
    }
    

    //MARK: RESTORATION RELATED METHODS

    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        var ret = false
        var saveurl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        saveurl = saveurl.URLByAppendingPathComponent("gtasksData")
        
        var tasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        tasklisturl = tasklisturl.URLByAppendingPathComponent("tasklistData")
        
        var nowtasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        nowtasklisturl = nowtasklisturl.URLByAppendingPathComponent("nowtasklistData")

        var nexttasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        nexttasklisturl = nexttasklisturl.URLByAppendingPathComponent("nexttasklistData")

        var latertasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        latertasklisturl = latertasklisturl.URLByAppendingPathComponent("latertasklistData")

        
        var defaulttasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        defaulttasklisturl = defaulttasklisturl.URLByAppendingPathComponent("defaulttasklistData")
        
        var usernowtasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        usernowtasklisturl = usernowtasklisturl.URLByAppendingPathComponent("usernowtasklistData")
        
        var usernexttasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        usernexttasklisturl = usernexttasklisturl.URLByAppendingPathComponent("usernexttasklistData")
        
        var userlatertasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        userlatertasklisturl = userlatertasklisturl.URLByAppendingPathComponent("userlatertasklistData")

        
        
        ret = NSKeyedArchiver.archiveRootObject(tasksFromModel, toFile: saveurl.path!)
        ret = NSKeyedArchiver.archiveRootObject(tasklistsForPicker, toFile: tasklisturl.path!)
        ret = NSKeyedArchiver.archiveRootObject(taskAndTasklistsSharedObject!.userNowTasksDataSource, toFile: usernowtasklisturl.path!)
        ret = NSKeyedArchiver.archiveRootObject(taskAndTasklistsSharedObject!.userNextTasksDataSource, toFile: usernexttasklisturl.path!)
        ret = NSKeyedArchiver.archiveRootObject(taskAndTasklistsSharedObject!.userLaterTasksDataSource, toFile: userlatertasklisturl.path!)
        ret = NSKeyedArchiver.archiveRootObject(defaultTasklist!, toFile: defaulttasklisturl.path!)
        
        ret = NSKeyedArchiver.archiveRootObject(taskAndTasklistsSharedObject!.nowTasksDataSource, toFile: nowtasklisturl.path!)
        ret = NSKeyedArchiver.archiveRootObject(taskAndTasklistsSharedObject!.nextTasksDataSource, toFile: nexttasklisturl.path!)
        ret = NSKeyedArchiver.archiveRootObject(taskAndTasklistsSharedObject!.laterTasksDataSource, toFile: latertasklisturl.path!)


        
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
        } else {
            println("did not unarchive no file present")
        }
        
        
        var tasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        tasklisturl = tasklisturl.URLByAppendingPathComponent("tasklistData")
       
        if NSFileManager.defaultManager().fileExistsAtPath(tasklisturl.path!){
            self.tasklistsForPicker = NSKeyedUnarchiver.unarchiveObjectWithFile(tasklisturl.path!) as Array<tasklistStruct>
        } else {
            println("did not unarchive no file present")
        }
        
        
        var usernowtasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        usernowtasklisturl = usernowtasklisturl.URLByAppendingPathComponent("usernowtasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(usernowtasklisturl.path!){
            self.userNowTasksDataSource = NSKeyedUnarchiver.unarchiveObjectWithFile(usernowtasklisturl.path!) as Array<tasksStructWithListName>
        } else {
            println("did not unarchive no usernowtasklisturl file present")
        }

        
        var usernexttasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        usernexttasklisturl = usernexttasklisturl.URLByAppendingPathComponent("usernexttasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(usernexttasklisturl.path!){
            self.userNextTasksDataSource = NSKeyedUnarchiver.unarchiveObjectWithFile(usernexttasklisturl.path!) as Array<tasksStructWithListName>
        } else {
            println("did not unarchive no usernexttasklisturl file present")
        }

        
        var userlatertasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        userlatertasklisturl = userlatertasklisturl.URLByAppendingPathComponent("userlatertasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(userlatertasklisturl.path!){
            self.userLaterTasksDataSource = NSKeyedUnarchiver.unarchiveObjectWithFile(userlatertasklisturl.path!) as Array<tasksStructWithListName>
        } else {
            println("did not unarchive no userlatertasklisturl file present")
        }
        
        
        var defaulttasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        defaulttasklisturl = defaulttasklisturl.URLByAppendingPathComponent("defaulttasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(defaulttasklisturl.path!){
            self.defaultTasklist = NSKeyedUnarchiver.unarchiveObjectWithFile(defaulttasklisturl.path!) as tasklistStruct
            taskAndTasklistsSharedObject?.defaultTasklist = defaultTasklist
        } else {
            println("did not unarchive no defaulttasklistData file present")
        }
        
        
        var nowtasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        nowtasklisturl = nowtasklisturl.URLByAppendingPathComponent("nowtasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(nowtasklisturl.path!){
            self.taskAndTasklistsSharedObject?.nowTasksDataSource = NSKeyedUnarchiver.unarchiveObjectWithFile(nowtasklisturl.path!) as Array<tasksStructWithListName>
        } else {
            println("did not unarchive no nowtasklisturl file present")
        }
        
        
        var nexttasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        nexttasklisturl = nexttasklisturl.URLByAppendingPathComponent("nexttasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(nexttasklisturl.path!){
             self.taskAndTasklistsSharedObject?.nextTasksDataSource = NSKeyedUnarchiver.unarchiveObjectWithFile(nexttasklisturl.path!) as Array<tasksStructWithListName>
        } else {
            println("did not unarchive no nexttasklisturl file present")
        }
        
        
        var latertasklisturl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        latertasklisturl = latertasklisturl.URLByAppendingPathComponent("latertasklistData")
        
        if NSFileManager.defaultManager().fileExistsAtPath(latertasklisturl.path!){
             self.taskAndTasklistsSharedObject?.laterTasksDataSource = NSKeyedUnarchiver.unarchiveObjectWithFile(latertasklisturl.path!) as Array<tasksStructWithListName>
        } else {
            println("did not unarchive no latertasklisturl file present")
        }

        
        //Update the model on restore.
        if userNowTasksDataSource.count != 0 {
            self.taskAndTasklistsSharedObject?.userNowTasksDataSource = userNowTasksDataSource
        }
        if userNextTasksDataSource.count != 0 {
            self.taskAndTasklistsSharedObject?.userNextTasksDataSource = userNextTasksDataSource
        }
        if userLaterTasksDataSource.count != 0 {
            self.taskAndTasklistsSharedObject?.userLaterTasksDataSource = userLaterTasksDataSource
        }

        taskAndTasklistsSharedObject?.checkTasksForSyncToGoogle()
        
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
        
        return identifier

    }
    
    func indexPathForElementWithModelIdentifier(identifier: String, inView view: UIView) -> NSIndexPath? {
        var indx = NSIndexPath(forRow: 0, inSection: 1)
        
        var i = 0
        for obj in tasksFromModel {
            var txt = obj.taskInfo.title
            if txt == identifier {
                indx = NSIndexPath(forRow: i, inSection: 1)
                self.tableView.reloadData()
                return indx
            }
            i++
        }
        
        return indx
    }

    
    class func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        
        var identifier = identifierComponents.last as String
        if identifier == "firstController" {
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
