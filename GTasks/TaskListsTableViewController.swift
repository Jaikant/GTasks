//
//  TaskListsTableViewController.swift
//  GTasks
//
//  Created by Jai on 18/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TaskListsTableViewController: UITableViewController {
    
   
    // Controller related properties
    
    lazy var addTasklistController: AddTasklistViewController? = {
        var _addTasklistController = AddTasklistViewController()
        return _addTasklistController    }()
    
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
    
    
    let errorController = UIAlertController()
    
    // If I remove the lazy from this it gives a weird kind of compiler error!
    lazy var alertAction : UIAlertAction? = {
        var _alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in println("")})
        return _alertAction } ()
    
    //var alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in println("Alert given")})
    
    lazy var dateFormatter: NSDateFormatter? = {
        var _dateformatter = NSDateFormatter()
        _dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return _dateformatter
    } ()
    
    
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    
    
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
        taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.toolbarHidden = true
        
        dispatch_q = dispatch_queue_create("tasklists_queue", nil)
        
    }
    /*
    override func prefersStatusBarHidden() -> Bool {
        return true
    } */
    
    func RunAddTasklistController() -> Void {
        //addTasklistController?.tasksService = self.tasksService
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
        return Int(taskAndTasklistsSharedObject!.tasklistsArray.count)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TaskListsTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tasklists", forIndexPath: indexPath) as TaskListsTableViewCell

        // Configure the cell...
        
        var tasklist = taskAndTasklistsSharedObject!.tasklistsArray[indexPath.row]
        cell.textLabel?.text = tasklist.title
        //To be fixed
        //var strdate = dateFormatter?.stringFromDate((tasklist.updated.date)!)
        //cell.detailTextLabel?.text = "Last Update: " + strdate!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var currentRow: Int? = indexPath.row
        LogError.log("\(currentRow)")

        var selectedTasklist : tasklistStruct = taskAndTasklistsSharedObject!.tasklistsArray[indexPath.row]
        taskAndTasklistsSharedObject!.getTasksForSpecifiedTasklist(selectedTasklist)
        
        dispatch_async(dispatch_get_main_queue(), {self.dismissViewControllerAnimated(true, completion: {println("Viewcontroller dismissed")})})
    }
    
}
