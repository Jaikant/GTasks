//
//  AddTaskViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

//Adding the textviewdelegate so we can implement the keyboard hiding for uitextfield
class ModifyTaskViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    lazy var datePickerController: DatePickerController? = {
        var _datePickerController = DatePickerController()
        return _datePickerController    }()
    
    lazy var transitiondel : ModifyTaskTransitonDelegate? = {
        var _transitiondel = ModifyTaskTransitonDelegate()
        return _transitiondel    }()

    
    var statusUpdated : Bool = false
    var statusCell : TasksDetailViewCell?
    
    //MARK: Properties containing updated values
    //For new date
    var datePicker : UIDatePicker?
    //txtview reference from cell for notes, will contain updated notes
    var txtview : NotesTextView?
    //The task list to which the task should be added, could have changed
    var updatedTasklist: tasklistStruct? = nil
    //The status is directly updated on the customTask object

    
    var taskAndTasklistsSharedObject : TaskAndTasklistStore?
    
    var defaultSwitch: UISwitch?
    
    
    var tasklistsForPicker : Array<tasklistStruct> = []
    
    
    
    //MARK: DATASOURCE FOR VIEW/MODIFY TASK
    var customTask: tasksStructWithListName?
    
    
    //To check if a task is in progress
    var taskTicket:GTLServiceTicket? = nil
    
    
    //IndexPaths
    var datePickerIndexPath : NSIndexPath? = nil
    var tasklistPickerIndexPath : NSIndexPath? = nil
    var dateIndexPath : NSIndexPath? = nil
    var tasklistIndexPath : NSIndexPath? = nil
    
    //Cell reuseidentifiers
    let cellDatePicker = "cellDatePicker"
    let cellTasklistPicker = "cellTasklistPicker"
    let cellDate = "cellDate"
    let cellTasklist = "cellTasklist"
    let cellNotes = "cellNotes"
    let cellStatus = "cellStatus"
    let cellTitle = "cellTitle"


    
    
    //MARK: - Actions
    
    func resetAndPopController() {
        self.taskTicket = nil
        self.txtview = nil
        hideKeyboard()
        self.statusCell = nil
        self.statusUpdated = false
        statuscellOff()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func resetAndPopControllerOnError() {
        
        // Do not reset the text in task and notes.
        self.taskTicket = nil
        hideKeyboard()
        self.statusCell = nil
        self.statusUpdated = false
        statuscellOff()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func hideKeyboard() {
        if txtview?.isFirstResponder() == true {
            txtview?.resignFirstResponder()
        }
    }
    
    func gobackfornow() -> Void {
        // The user decided to cancel the Addtask so a normal reset.
        //var tblvc = self.navigationController?.viewControllers[0] as TasksTableViewController
        // tblvc.fetchTasks = false
        // tblvc.fetchTasklist = false
        resetAndPopController()
    }
    
    func updateTask() {
        
        customTask?.taskInfo.notes = txtview?.text
        customTask?.taskInfo.duedate = datePicker?.date
        customTask?.taskInfo.updated = NSDate()

        if updatedTasklist == nil {
            taskAndTasklistsSharedObject?.modifyTaskForSpecifiedTasklist(customTask!)
        } else if customTask?.tasklistInfo.title == updatedTasklist?.title
        {
            taskAndTasklistsSharedObject?.modifyTaskForSpecifiedTasklist(customTask!)
        } else //Move and then update task as well.
        {
            customTask?.sync = false
            taskAndTasklistsSharedObject?.moveTask(customTask!, newTasklist: updatedTasklist!)
        }
        self.resetAndPopController()
    }
    
    //MARK: - TableViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(TasksDetailViewCell.classForCoder(), forCellReuseIdentifier: cellTitle)

        tableView.registerClass(TasksDetailViewCell.classForCoder(), forCellReuseIdentifier: cellDate)
        
        tableView.registerClass(DueDateTableViewCell.classForCoder(), forCellReuseIdentifier: cellDatePicker)
        
        tableView.registerClass(TaskNotesDetailViewCell.classForCoder(), forCellReuseIdentifier: cellNotes)
        
        tableView.registerClass(TasksDetailViewCell.classForCoder(), forCellReuseIdentifier: cellStatus)

        tableView.registerClass(TasksDetailViewCell.classForCoder(), forCellReuseIdentifier: cellTasklist)
        
        tableView.registerClass(TaskListPickerTableViewCell.classForCoder(), forCellReuseIdentifier: cellTasklistPicker)

        
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("updateTask"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("gobackfornow"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        
        tableView.estimatedRowHeight = 155;
        //The below does not work!
        //tableView.rowHeight = UITableViewAutomaticDimension;
        
        
        tableView.layer.borderWidth = 1.0;
        tableView.layer.borderColor = UIColor.lightGrayColor().CGColor;


        
        //var tblvc = self.navigationController?.viewControllers[0] as TasksTableViewController
        
        taskAndTasklistsSharedObject = TaskAndTasklistStore.singleInstance()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var section = NSIndexSet(index: 3)
        
        self.navigationItem.title = customTask?.taskInfo.title
        tableView.reloadData()
        
        //Not sure what this was for, commenting for now as it crashes.
        //self.tableView.reloadSections(section, withRowAnimation: UITableViewRowAnimation.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
       // self.navigationController?.toolbarHidden = true
       // self.navigationController?.hidesBarsOnSwipe = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if datePickerIndexPath != nil || tasklistPickerIndexPath != nil {
            return 5 + 1
        }
        return 5
    }
    
    func getDateIndexPath() -> NSIndexPath {
        dateIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        return dateIndexPath!
    }

    func getTasklistIndexPath() -> NSIndexPath {
        var row = 2
        if datePickerIndexPath != nil {
            row = 3
        }
        tasklistIndexPath = NSIndexPath(forRow: row, inSection: 0)
        return tasklistIndexPath!
    }
    
    
    func getNotesIndexPath() -> NSIndexPath {
        var row = 4
        if datePickerIndexPath != nil || tasklistPickerIndexPath != nil {
            row = 5
        }
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        return indexPath
    }
    
    func getStatusIndexPath() -> NSIndexPath {
        var row = 3
        if datePickerIndexPath != nil || tasklistPickerIndexPath != nil {
            row = 4
        }
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        return indexPath
    }

    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    
    if indexPath.row == datePickerIndexPath?.row || indexPath.row == tasklistPickerIndexPath?.row {
    return 155
    }
    if indexPath == getNotesIndexPath() {
    return 176
    }
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)


    
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let identifier = cell!.reuseIdentifier!
        
        switch identifier {
        case cellTitle:
            let thisCell = cell as TasksDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "1-red.png"), forState: UIControlState.Normal)
        case cellDate:
            let thisCell = cell as TasksDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "calendar-red.png"), forState: UIControlState.Normal)
        case cellNotes:
            let thisCell = cell as TaskNotesDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "icon-edit-green-50.png"), forState: UIControlState.Normal)
        case cellTasklist:
            let thisCell = cell as TasksDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "calendar-red.png"), forState: UIControlState.Normal)
        default:
            LogError.log("Default selection in willSelect")
        }
        return indexPath
    }
    
    func restoreSelectButton(indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)

        let identifier = cell!.reuseIdentifier!
        
        switch identifier {
        case cellTitle:
            let thisCell = cell as TasksDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "1-grey.png"), forState: UIControlState.Normal)
        case cellDate:
            let thisCell = cell as TasksDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "calendar.png"), forState: UIControlState.Normal)
        case cellNotes:
            let thisCell = cell as TaskNotesDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "calendar.png"), forState: UIControlState.Normal)
        case cellTasklist:
            let thisCell = cell as TasksDetailViewCell
            thisCell.iconBut.setImage(UIImage(named: "calendar.png"), forState: UIControlState.Normal)
        default:
            LogError.log("Default selection in didDeselect")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var justHidPicker : Bool = false
        var justHidDate : Bool = false
        var selectedTasklistRow : Bool?
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
    
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.row == 0 {
            promptForDelete(cell as TasksDetailViewCell)
        }
        
        if indexPath != getNotesIndexPath() {
            hideKeyboard()
        } else
        {
            
            if txtview?.isFirstResponder() == true
            {
                txtview?.resignFirstResponder()
            } else
            {
                txtview?.becomeFirstResponder()
            }
        }
      //  tableView.beginUpdates()
        if indexPath == tasklistIndexPath {
            selectedTasklistRow = true
        }
        
        //First hide if visible, to keep rows within limits of max rows in datasource
        
        if datePickerIndexPath != nil && indexPath != datePickerIndexPath {
            hideDatePicker()
            justHidDate = true
        }
        else if tasklistPickerIndexPath != nil && indexPath != tasklistPickerIndexPath {
            hideTasklistPicker()
            justHidPicker = true
        }
        
        if indexPath == dateIndexPath && datePickerIndexPath == nil {
            if (!justHidDate) {
                showDatePicker()
            }
        }
        else if selectedTasklistRow == true && tasklistPickerIndexPath == nil {
            if (!justHidPicker) {
                showTasklistPicker()
            }
        }
        
      //  tableView.endUpdates()
        
    }
    
    
    func hideDatePicker(){
        var row = datePickerIndexPath!.row
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        datePickerIndexPath = nil
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        // The tasklistIndexPath would have reduced by one row, so update it.
        tasklistIndexPath = getTasklistIndexPath()
        restoreSelectButton(dateIndexPath!)
    }
    
    func hideTasklistPicker(){
        var row = tasklistPickerIndexPath!.row
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        tasklistPickerIndexPath = nil
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        restoreSelectButton(tasklistIndexPath!)
    }
    
    func showDatePicker() {
        var newRow = dateIndexPath!.row + 1
        datePickerIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
        tableView.insertRowsAtIndexPaths([datePickerIndexPath!], withRowAnimation:UITableViewRowAnimation.Left)
        // The tasklistIndexPath would have increased by one row, so update it.
        tasklistIndexPath = getTasklistIndexPath()
    }
    
    func showTasklistPicker() {
        var newRow = tasklistIndexPath!.row + 1
        tasklistPickerIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
        tableView.insertRowsAtIndexPaths([tasklistPickerIndexPath!], withRowAnimation:UITableViewRowAnimation.Left)
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        var reuseIdentifier : String?
        var modelRowNo : Int
        
        if indexPath.row == 0 {
            reuseIdentifier = cellTitle
        }
        else if indexPath == getDateIndexPath() {
            reuseIdentifier = cellDate
        }
        else if datePickerIndexPath != nil && indexPath == datePickerIndexPath {
            reuseIdentifier = cellDatePicker
        }
        else if indexPath == getNotesIndexPath() {
            reuseIdentifier = cellNotes
        }
        else if indexPath == getStatusIndexPath() {
            reuseIdentifier = cellStatus
        }
        else if indexPath == getTasklistIndexPath() {
            reuseIdentifier = cellTasklist
        }
        else if tasklistPickerIndexPath != nil && indexPath == tasklistPickerIndexPath {
            reuseIdentifier = cellTasklistPicker
        }
        
        
        cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier!, forIndexPath: indexPath) as? UITableViewCell
        
        if datePickerIndexPath?.row != nil && indexPath.row > datePickerIndexPath?.row {
            modelRowNo = indexPath.row - 1
        } else {
            modelRowNo = indexPath.row
        }
        
        configureCellAtIndexPath(indexPath, modelRowNo: modelRowNo, cell: cell!)
        return cell!
        
    }
    

    func configureCellAtIndexPath(indexPath: NSIndexPath, modelRowNo : Int, cell : UITableViewCell) {
        
        if cell.reuseIdentifier == cellTitle {
            var titleCell = cell as TasksDetailViewCell
            titleCell.selectionStyle = UITableViewCellSelectionStyle.None
            titleCell.lbl.text = customTask!.taskInfo.title
            var img = UIImage(named: "1-grey.png")
            var imgpressed = UIImage(named: "1-red.png")
            titleCell.iconBut.setImage(img, forState: UIControlState.Normal)
            titleCell.iconBut.setImage(imgpressed, forState: UIControlState.Highlighted)
            titleCell.iconBut.addTarget(self, action: "promptForDelete:", forControlEvents: UIControlEvents.TouchDown)


        }
        else if cell.reuseIdentifier == cellDate {
            
            var lcellDate = cell as TasksDetailViewCell
            var strdate : String = "None"
            var date = customTask?.taskInfo.duedate
            if date != nil {
                strdate = longDateFormatter!.stringFromDate(date!)
            }
            lcellDate.lbl.text = "End Date:  " + strdate
            var img = UIImage(named: "calendar.png")
            lcellDate.iconBut.setImage(img, forState: UIControlState.Normal)
        }
        else if cell.reuseIdentifier == cellDatePicker {
            let datePickerCell = cell as DueDateTableViewCell
            datePickerCell.dateLabel.text = "Select Date"
            datePickerCell.dateLabel.textColor = UIColor.blackColor()
            datePicker = datePickerCell.datePicker
        }
        else if cell.reuseIdentifier == cellNotes {
            
            var lcellNotes = cell as TaskNotesDetailViewCell
            txtview = lcellNotes.txtvw
            txtview?.text = customTask!.taskInfo.notes
            var img = UIImage(named: "icon-edit-grey-50.png")
            lcellNotes.iconBut.setImage(img, forState: UIControlState.Normal)

            txtview?.autocorrectionType = UITextAutocorrectionType.Yes
            txtview?.returnKeyType = UIReturnKeyType.Default
            txtview?.delegate = self
            txtview?.scrollEnabled = true
            txtview?.editable = true
            txtview?.userInteractionEnabled = true
        }
        else if cell.reuseIdentifier == cellStatus {
            
            statusCell = cell as? TasksDetailViewCell
            
            //if statusUpdated != true {
            if customTask!.taskInfo.status == "completed" {
                statuscellOn()
            } else {
                statuscellOff()
            }
            statusCell?.iconBut.addTarget(self, action: "toggleTaskStatus", forControlEvents: UIControlEvents.TouchDown)
            
        }
        else if cell.reuseIdentifier == cellTasklist {
            
            var cellTasklist = cell as TasksDetailViewCell
            
            cellTasklist.lbl.text = customTask!.tasklistInfo.title
            var img = UIImage(named: "calendar.png")
            cellTasklist.iconBut.setImage(img, forState: UIControlState.Normal)

        }
        else if cell.reuseIdentifier == cellTasklistPicker {
            let cellpkr = cell as TaskListPickerTableViewCell
            cellpkr.pkrvw.delegate = self
            cellpkr.pkrvw.dataSource = self
            let startRow = tasklistRowForPickerInit(customTask!.tasklistInfo.title)
            cellpkr.pkrvw.selectRow(startRow, inComponent: 0, animated: true)
            //pickerView(cellpkr.pkrvw, didSelectRow: 1, inComponent: 0)
        }
    }

    func tasklistRowForPickerInit(tasklistTitle : String) -> Int {
        var row : Int = 0
        for tasklistItem in tasklistsForPicker {
            if tasklistItem.title == tasklistTitle {
                return row
            }
            row++
        }
        return 0
    }
    
    
    func promptForDelete(but: UIButton) -> Void {
        var cell = but.superview?.superview as TasksDetailViewCell
        but.setImage(UIImage(named: "1-red.png"), forState: UIControlState.Normal)
        promptForDelete(cell)
    }
    
    func promptForDelete(cell: TasksDetailViewCell) -> Void {
        showDeleteActionSheetForModifyControl(cell,customTask!, self)
    }
    
    // no users for this, instead use restorebutton...
    func updateDetailLabelOnCell(tasksCell : TasksDetailViewCell) {
        if tasksCell.reuseIdentifier == cellTitle {
            var img = UIImage(named: "1-grey.png")
            var imgpressed = UIImage(named: "1-red.png")
            tasksCell.iconBut.setImage(img, forState: UIControlState.Normal)
            tasksCell.iconBut.setImage(imgpressed, forState: UIControlState.Highlighted)
        }
    }
    
    func statuscellOff() {
        statusCell?.lbl.text = "Not completed"
        var img = UIImage(named: "4-grey.png")
        statusCell?.iconBut.setImage(img, forState: UIControlState.Normal)
    }
    
    func statuscellOn() {
        statusCell?.lbl.text = "Completed"
        var img = UIImage(named: "4-green.png")
        statusCell?.iconBut.setImage(img, forState: UIControlState.Normal)
    }
    
    func toggleTaskStatus() {
        self.statusUpdated = true
        if customTask?.taskInfo.status == "needsAction" {
            customTask?.taskInfo.status = "completed"
        } else {
            customTask?.taskInfo.status = "needsAction"
        }
        if statusUpdated {
            statusCell?.lbl.textColor = UIColor.redColor()
        }
        var indexpath = getStatusIndexPath()
        self.tableView.reloadRowsAtIndexPaths([indexpath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    // MARK: Actions
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideKeyboard()
        return false
    }
    
    
    //UIPickerView DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Int(tasklistsForPicker.count)
    }
    
    //UIPickerView Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if tasklistsForPicker.count != 0 {
            var containerView = pickerView.superview
            var cellContentView = containerView?.superview
            var cell = cellContentView?.superview as TaskListPickerTableViewCell
            updatedTasklist = tasklistsForPicker[row] as tasklistStruct
            cell.label.text = updatedTasklist?.title
            cell.label.textColor = UIColor.redColor()
            LogError.log("Selected tasklist: \(updatedTasklist!.title)")
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return tasklistsForPicker[row].title
        
    }
    
}
