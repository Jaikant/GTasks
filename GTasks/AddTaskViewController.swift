//
//  AddTaskViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

//Adding the textviewdelegate so we can implement the keyboard hiding for uitextfield
class AddTaskViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var taskStatus : Bool = false
    var statusCell : StatusTableViewCell?
    var dueDateCell : DueDateTableViewCell?
    
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    
    var defaultSwitch: UISwitch?

    lazy var taskField:UITextField? = {
       var _tskfield = UITextField()
        _tskfield.placeholder = "Enter Task Description"
        _tskfield.autocorrectionType = UITextAutocorrectionType.Yes
        _tskfield.returnKeyType = UIReturnKeyType.Done
        _tskfield.clearButtonMode = UITextFieldViewMode.Always
        return _tskfield
    }()
    
    var noteField:NotesTextView? = nil

    
    //The task list to which the task should be added
    var tasklist: tasklistStruct? = nil
    
   // var tasksService = GTLServiceTasks()
    
    //To check if a task is in progress
    var taskTicket:GTLServiceTicket? = nil

    
    //MARK: - Actions
    
    func resetAndPopController() {
        self.taskTicket = nil
        
        self.taskField?.text = nil  // Clear the text field
        self.noteField?.text = nil  // Clear the text field
        self.noteField?.viewWithTag(9999)?.alpha = 1  // Make placeholder text visible
        
        if self.noteField?.isFirstResponder() == true {   //Don't show keyboard when view loads
            self.noteField?.resignFirstResponder()
        }
        
        if self.taskField?.isFirstResponder() == true {  //Don't show keyboard when view loads
            self.taskField?.resignFirstResponder()
        }
        
        self.statusCell = nil
        self.taskStatus = false
        statuscellOff()
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func resetAndPopControllerOnError() {
        
        // Do not reset the text in task and notes.
        
        self.taskTicket = nil
        
        if self.noteField?.isFirstResponder() == true {   //Don't show keyboard when view loads
            self.noteField?.resignFirstResponder()
        }
        
        if self.taskField?.isFirstResponder() == true {  //Don't show keyboard when view loads
            self.taskField?.resignFirstResponder()
        }

        self.navigationController?.popViewControllerAnimated(true)
        self.statusCell = nil
        self.taskStatus = false
        statuscellOff()
    }

    func hideKeyboard() {
        if noteField?.isFirstResponder() == true {
            noteField?.resignFirstResponder()
        }
    
        if taskField?.isFirstResponder() == true {
            taskField?.resignFirstResponder()
        }
    }
    
    func gobackfornow() -> Void {
        // The user decided to cancel the Addtask so a normal reset.
        var tblvc = self.navigationController?.viewControllers[0] as TasksTableViewController
       // tblvc.fetchTasks = false
       // tblvc.fetchTasklist = false
        resetAndPopController()
    }
    
    func createTask() {
        if tasklist != nil {
        if self.taskField?.text != nil {
            let taskInfo = taskStruct(title: self.taskField!.text!, notes: self.noteField?.text, duedate: dueDateCell?.datePicker.date, status: "actionNeeded", identifier: "--")
            let customTask = tasksStructWithListName(tasklistInfo: tasklist!, taskInfo: taskInfo)
            taskAndTasklistsSharedObject?.addNewTask(customTask)
        } else {
            LogError.log("Task title is nil")
            }
        } else {
            LogError.log("Tasklist is nil")
        }
        self.resetAndPopController()
    }
    
    func addTask() {
        
        var task = GTLTasksTask()
        if self.taskField?.text != nil
        {
            task.title = self.taskField?.text
            
            if self.noteField?.text != nil {
                task.notes = self.noteField?.text
            }
            
            if dueDateCell?.datePicker.date != nil {
                task.due = GTLDateTime(date: dueDateCell!.datePicker.date , timeZone: NSTimeZone())
            }
            
            if taskStatus == true {
                task.completed = GTLDateTime(date: NSDate(), timeZone: NSTimeZone())
                task.status = "completed"
                //fix it task status
            }
            
            var query = GTLQueryTasks.queryForTasksInsertWithObject(task, tasklist: tasklist?.identifier) as GTLQueryTasks
            if taskTicket == nil {
                taskTicket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                    if error == nil {
                        self.resetAndPopController()
                    } else {
                        LogError.log("\(error)")
                        self.resetAndPopControllerOnError()
                    }
                })
            } else {
                println("Error: Query Operation in Progress")
            }
        }
    }
    
    //MARK: - TableViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "filler")
        self.tableView.registerClass(TaskListPickerTableViewCell.classForCoder(), forCellReuseIdentifier: "picker")
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "taskfield")
        self.tableView.registerClass(DueDateTableViewCell.classForCoder(), forCellReuseIdentifier: "duedate")
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "notes")
        self.tableView.registerClass(StatusTableViewCell.classForCoder(), forCellReuseIdentifier: "status")

        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("createTask"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("gobackfornow"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        self.navigationItem.title = "Add Task"
        
        var tblvc = self.navigationController?.viewControllers[0] as TasksTableViewController
        
        taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var section = NSIndexSet(index: 3)
        //Not sure what this was for, commenting for now as it crashes.
        //self.tableView.reloadSections(section, withRowAnimation: UITableViewRowAnimation.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
        self.navigationController?.hidesBarsOnSwipe = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        if (indexPath.section == 1){
            // UIdatepicker
            return 40 * 3
        }
        if (indexPath.section == 2) {
            // UITextView
            return 40 * 2
        }
        
        if (indexPath.section == 4) {
            // UIPickerView
            return 40 * 3
        }

        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        hideKeyboard()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        switch indexPath.section {
        case 0:
            cell = configuretaskfieldCell(indexPath)

        case 1:
            cell = configureduedateCell(indexPath)

        case 2:
            cell = configurenotesCell(indexPath)
            
        case 3:
            cell = configurestatusCell(indexPath)
            
        case 4:
            cell = configuremoveCell(indexPath)

        default:
            LogError.log("Section no: \(indexPath.section) is not valid")
            
        }
        
        return cell!
    }


    func configuretaskfieldCell(indexPath: NSIndexPath)-> UITableViewCell
    {
        var cell:UITableViewCell?
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("taskfield", forIndexPath: indexPath) as? UITableViewCell
            var cellbnds = cell?.contentView.bounds
            self.taskField?.frame = CGRectMake(cellbnds!.minX + 15, cellbnds!.minY, cellbnds!.width - 15, cellbnds!.height)
            taskField?.delegate = self
            // How to set the number of lines for taskfield?
            //LogError.log("subviews in the cell are: \(cell?.contentView.subviews)")
            cell?.contentView.addSubview(taskField!)

        default:
            LogError.log("Invalid row: \(indexPath.row)")
        }
        return cell!

    }

    
    
    func configureduedateCell(indexPath: NSIndexPath) -> DueDateTableViewCell
    {

        switch indexPath.row {
        case 0:
            dueDateCell = tableView.dequeueReusableCellWithIdentifier("duedate", forIndexPath: indexPath) as? DueDateTableViewCell
            
        default:
            LogError.log("Invalid row: \(indexPath.row)")
        }
        return dueDateCell!

    }
    


    
    func configurenotesCell(indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell?

        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("notes", forIndexPath: indexPath) as? UITableViewCell
            var cellbnds = cell?.contentView.bounds
            self.noteField = NotesTextView(frame: CGRectMake(cellbnds!.minX + 15, cellbnds!.minY, cellbnds!.width - 15, cellbnds!.height))
            //noteField?.placeholder = "Enter the task title/description"
            noteField?.autocorrectionType = UITextAutocorrectionType.Yes
            noteField?.returnKeyType = UIReturnKeyType.Done
            noteField?.delegate = self
            noteField?.scrollEnabled = true
            noteField?.editable = true
            noteField?.userInteractionEnabled = true
            noteField?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            noteField?.placeholderText = "Task Notes"
            // How to set the number of lines for taskfield?
            cell?.contentView.addSubview(noteField!)
        default:
            LogError.log("Invalid row: \(indexPath.row)")
        }
        return cell!

        
    }

    
    func configurestatusCell(indexPath: NSIndexPath) -> UITableViewCell
    {
        
         statusCell = tableView.dequeueReusableCellWithIdentifier("status", forIndexPath: indexPath) as? StatusTableViewCell
         LogError.log("Dequeued status cell")
        
        if taskStatus == false {
            statuscellOff()
        } else {
            statuscellOn()
        }
        statusCell?.stabut?.addTarget(self, action: "toggleTaskStatus", forControlEvents: UIControlEvents.TouchDown)
        
        return statusCell!
    
    }
    
    func statuscellOff() {
        statusCell?.lbl?.text = "Status"
        statusCell?.statusImage = UIImage(named: "4.png")
        statusCell?.stabut?.setImage(statusCell?.statusImage, forState: UIControlState.Normal)
    }
    
    func statuscellOn() {
    statusCell?.lbl?.text = "Completed"
    statusCell?.statusImage = UIImage(named: "4-green.png")
    statusCell?.stabut?.setImage(statusCell?.statusImage, forState: UIControlState.Normal)
    }
    
    func toggleTaskStatus() {
        if self.taskStatus == false {
            taskStatus = true
        } else {
            taskStatus = false
        }
       // let animationDuration : NSTimeInterval = 0.25
        var section = NSIndexSet(index: 3)
        self.tableView.reloadSections(section, withRowAnimation: UITableViewRowAnimation.Fade)
        //UIView.animateWithDuration(animationDuration, animations: {
            //self.tableView.reloadSections(section, withRowAnimation: UITableViewRowAnimation.Left)
        //})
        
    }
    
    func configuremoveCell(indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("picker", forIndexPath: indexPath) as TaskListPickerTableViewCell
        
        cell.pkrvw.delegate = self
        cell.pkrvw.dataSource = self
        
        cell.pkrvw.selectRow(1, inComponent: 0, animated: true)
        pickerView(cell.pkrvw, didSelectRow: 1, inComponent: 0)

        return cell
    }
    
    // MARK: Actions
    
    func switchValueDidChange(aSwitch: UISwitch) {
        LogError.log("A switch changed its value: \(aSwitch).")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideKeyboard()
        return false
    }
    
    /*
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        LogError.log("9")
        self.noteField?.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }*/
    
    
    //UIPickerView DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Int(taskAndTasklistsSharedObject!.tasklistsArray.count)
    }
    
    //UIPickerView Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if taskAndTasklistsSharedObject!.tasklistsArray.count != 0 {
        tasklist = taskAndTasklistsSharedObject!.tasklistsArray[row] as tasklistStruct
        LogError.log("Adding task to task list: \(tasklist?.title)")
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return taskAndTasklistsSharedObject!.tasklistsArray[row].title

    }
    
}
