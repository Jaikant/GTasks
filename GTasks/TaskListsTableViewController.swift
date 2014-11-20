//
//  TaskListsTableViewController.swift
//  GTasks
//
//  Created by Jai on 18/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TaskListsTableViewController: UITableViewController {
    
    
    let kCellTasklistHeader : String = "kCellTasklistHeader"
    let kCellTasklist : String = "kCellTasklist"

    
   
    // Controller related properties
    
    lazy var dismissVC: UIViewController? = {
        var _dismissVC = UIViewController()
        return _dismissVC }()
    
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
        
    
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    var tasklistsDataSource : Array<tasklistStruct> = []

    let addTasklistButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton

    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Configure the background of the tableView
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundView = UIView()
        //self.tableView.backgroundView?.backgroundColor = UIColor.lightGrayColor()
        tableView.layer.cornerRadius = 5.0
        configureAddTasklistButton()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.registerClass(TaskListsTableViewCell.classForCoder(), forCellReuseIdentifier: kCellTasklistHeader)
        self.tableView.registerClass(TaskListsTableViewCell.classForCoder(), forCellReuseIdentifier: kCellTasklist)

        taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
       // var notify = NSNotificationCenter.defaultCenter()
        //notify.addObserver(self, selector: "modelInitialized", name: "ModelReady", object: nil)

    
    
   /* dismissVC?.view.addSubview(dismissButton)
    dismissVC?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    presentViewController(dismissVC!, animated: true, completion: {})*/
}
    

func dismissTasklistController() {
    dismissVC?.dismissViewControllerAnimated(true, completion: {})
    self.dismissViewControllerAnimated(true, completion: {})
    
}

    func configureAttributedTextSystemButton(attributedTextButton: UIButton) {
        let buttonTitle = NSLocalizedString("Dismiss", comment: "")
        
        // Set the button's title for normal state.
        let normalTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.applicationBlueColor(),
        ]
        let normalAttributedTitle = NSAttributedString(string: buttonTitle, attributes: normalTitleAttributes)
        attributedTextButton.setAttributedTitle(normalAttributedTitle, forState: .Normal)
        
        // Set the button's title for highlighted state.
        let highlightedTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.greenColor(),
            NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleThick.rawValue
        ]
        let highlightedAttributedTitle = NSAttributedString(string: buttonTitle, attributes: highlightedTitleAttributes)
        attributedTextButton.setAttributedTitle(highlightedAttributedTitle, forState: .Highlighted)
        
        attributedTextButton.addTarget(self, action: "dismissTasklistController", forControlEvents: .TouchUpInside)
    }


    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.toolbarHidden = false
        
        dispatch_q = dispatch_queue_create("tasklists_queue", nil)
        
        var notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "tasklistNameAddFailAlert", name: "NOTIFYTASKLISTADDFAILED", object: nil)
        notify.addObserver(self, selector: "modelInitialized", name: "NOTIFYTASKLISTADD", object: nil)

        
    }
    /*
    override func prefersStatusBarHidden() -> Bool {
        return true
    } */
    
    func modelInitialized() {
        tableView.reloadData()
        tasklistsDataSource = TaskAndTasklistStore.singleInstance().tasklistsArray
    }
    
    func addTasklistToGoogleIfNetworkUp() {
        showTasklistNameEntryAlert(self)
    }
    
    func tasklistNameAddFailAlert() {
        showSimpleAlert(self, "Tasklist not added", "Check your connection.")
        deleteCellOnDeleteFail()
    }

    
    func RunAddTasklistController() -> Void {
        //addTasklistController?.tasksService = self.tasksService
        self.navigationController?.pushViewController(addTasklistController!, animated: true)
    }
    
    func configureAddTasklistButton() {
        addTasklistButton.backgroundColor = UIColor.clearColor()
        addTasklistButton.addTarget(self, action: "addTasklistToGoogleIfNetworkUp", forControlEvents: .TouchUpInside)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        //return listTitleIdentifier.count
        switch section {
        case 0 : return 1
        case 1 : return tasklistsDataSource.count
        default : return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TaskListsTableViewCell {
      
        var resuseIdentifier : String? = nil
        if indexPath.section == 0 {
            resuseIdentifier = kCellTasklistHeader
        } else {
            resuseIdentifier = kCellTasklist
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(resuseIdentifier!, forIndexPath: indexPath) as TaskListsTableViewCell

        // Configure the cell...
        if indexPath.section == 0 {
            cell.textLabel?.text = "Select A Tasklist"
            cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            
           var frame =  CGRect(origin: CGPoint(x: CGRectGetMaxX(cell.contentView.bounds)*0.8, y: CGRectGetMaxY(cell.contentView.bounds)*0.0), size: CGSize(width: cell.contentView.bounds.width * 0.15, height: cell.contentView.bounds.height * 1))

            addTasklistButton.frame = frame
            cell.contentView.addSubview(addTasklistButton)

        }
        
        if indexPath.section == 1 {
        var tasklist = tasklistsDataSource[indexPath.row]
        cell.textLabel?.text = tasklist.title
        //To be fixed
        //var strdate = dateFormatter?.stringFromDate((tasklist.updated.date)!)
        //cell.detailTextLabel?.text = "Last Update: " + strdate!
            
        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        }

        return cell
    }
    
    func disableCellSelection() {
        drawCellsToDepictSelectable()
    }
    
    func deleteCellOnDeleteFail() {
        if (tasklistsDataSource.last)!.identifier == "--" {
            tasklistsDataSource.removeLast()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: tasklistsDataSource.count, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Bottom)
        }
    }

    func drawCellsToDepictSelectable() {
        if tasklistsDataSource[tasklistsDataSource.count-1].identifier == "--" {
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tasklistsDataSource.count-1, inSection: 1))
            cell?.textLabel?.textColor = UIColor.lightGrayColor()
        } else {
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tasklistsDataSource.count-1, inSection: 1))
            cell?.textLabel?.textColor = UIColor.blackColor()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var currentRow: Int? = indexPath.row

        var selectedTasklist : tasklistStruct = tasklistsDataSource[indexPath.row]
        if selectedTasklist.identifier != "--" {
            taskAndTasklistsSharedObject!.updateDefaultTaskDataSourcesAndSendNotification(selectedTasklist)
            dispatch_async(dispatch_get_main_queue(), {self.dismissTasklistController()})
            }
        
        }
    
}
