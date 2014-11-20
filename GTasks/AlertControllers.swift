//
//  File.swift
//  GTasks
//
//  Created by Jai on 06/11/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import Foundation

/// Show a dialog with two custom buttons.
func showDeleteActionSheet(index : NSIndexPath, customTask: tasksStructWithListName, selectedCell: TasksTableViewCell, controller: TasksTableViewController) {
    let destructiveButtonTitle = NSLocalizedString("Delete", comment: customTask.taskInfo.title)
    let otherButtonTitle = NSLocalizedString("Cancel", comment: "")
    
    let alertController = UIAlertController(title: "Delete Task", message: "This action will permanently delete the task!", preferredStyle: .ActionSheet)
    
    // Create the actions.
    let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
        
        LogError.log("Indexpath is: \(index)")

        controller.taskAndTasklistsSharedObject?.deleteTaskFromSpecifiedTasklist(customTask)
        var temp = controller.tasksFromModel.filter({ (existingTask) -> Bool in
            return(existingTask.taskInfo.title != customTask.taskInfo.title)
        })
        controller.tableView.beginUpdates()
            controller.tasksFromModel = temp
            LogError.log("The number of rows in tasksFromModel is \(controller.tasksFromModel.count)")
            controller.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
        controller.tableView.endUpdates()
        //controller.updateDetailLabelOnCell(selectedCell, row: index.row)
    }
    
    let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
        controller.updateDetailLabelOnCell(selectedCell, row: index.row)
        NSLog("Delete Cancelled.")
    }
    
    // Add the actions.
    alertController.addAction(destructiveAction)
    alertController.addAction(otherAction)
    
    // Configure the alert controller's popover presentation controller if it has one.
    if let popoverPresentationController = alertController.popoverPresentationController {
    // This method expects a valid cell to display from.
    // selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath)!
    popoverPresentationController.sourceRect = selectedCell.frame
    //Fix it for ipad
    popoverPresentationController.sourceView = controller.view
    popoverPresentationController.permittedArrowDirections = .Up
    }
    
    controller.presentViewController(alertController, animated: true, completion: nil)
}


/// Show a dialog with two custom buttons.
func showDeleteActionSheetForModifyControl(selectedCell: TasksDetailViewCell, customTask: tasksStructWithListName, controller: ModifyTaskViewController) {
    let destructiveButtonTitle = NSLocalizedString("Delete", comment: customTask.taskInfo.title)
    let otherButtonTitle = NSLocalizedString("Cancel", comment: "")
    
    let alertController = UIAlertController(title: "Delete Task", message: "This action will permanently delete the task!", preferredStyle: .ActionSheet)
    
    // Create the actions.
    let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
        
        controller.taskAndTasklistsSharedObject?.deleteTaskFromSpecifiedTasklist(customTask)
        controller.resetAndPopController()
    }
    
    let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
        var indexPath = controller.tableView.indexPathForCell(selectedCell)
        controller.restoreSelectButton(indexPath!)
        NSLog("Delete Cancelled.")
    }
    
    // Add the actions.
    alertController.addAction(destructiveAction)
    alertController.addAction(otherAction)
    
    // Configure the alert controller's popover presentation controller if it has one.
    if let popoverPresentationController = alertController.popoverPresentationController {
        // This method expects a valid cell to display from.
        // selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath)!
        popoverPresentationController.sourceRect = selectedCell.frame
        //Fix it for ipad
        popoverPresentationController.sourceView = controller.view
        popoverPresentationController.permittedArrowDirections = .Up
    }
    
    controller.presentViewController(alertController, animated: true, completion: nil)
}



// MARK: UIAlertControllerStyleAlert Style Alerts

/// Show an alert with an "Okay" button.
func showSimpleAlert(controller: UITableViewController, title: String, message: String) {
    
    let localizedTitle = NSLocalizedString(title, comment: "")
    let localizedMessage = NSLocalizedString(message, comment: "")
    let localizedCancelButtonTitle = NSLocalizedString("OK", comment: "")

    let alertController = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .Alert)
    
    // Create the action.
    let cancelAction = UIAlertAction(title: localizedCancelButtonTitle, style: .Cancel) { action in

        NSLog("The simple alert's cancel action occured.")
    }
    
    // Add the action.
    alertController.addAction(cancelAction)
    
    controller.presentViewController(alertController, animated: true, completion: nil)
}


/// Show a dialog with two custom buttons.
func showDueDateActionSheet(index : NSIndexPath, customTask: tasksStructWithListName, selectedCell: TasksTableViewCell, controller: TasksTableViewController) {
    let tomorrowButtonTitle = NSLocalizedString("One Day", comment: customTask.taskInfo.title)
    let dayAfterButtonTitle = NSLocalizedString("Two Days", comment: customTask.taskInfo.title)
    let nextWeekButtonTitle = NSLocalizedString("One Week", comment: customTask.taskInfo.title)
    let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
    
    let alertController = UIAlertController(title: "Change Task End Date By:", message: "", preferredStyle: .ActionSheet)
    
    // Create the actions.
    let tomorrowAction = UIAlertAction(title: tomorrowButtonTitle, style: .Destructive) { action in
        calculateNewDueDate(1.0, customTask)
        controller.taskAndTasklistsSharedObject?.modifyTaskForSpecifiedTasklist(customTask)
        NSLog("Changed due date by one day.")
    }
    
    let dayAfterAction = UIAlertAction(title: dayAfterButtonTitle, style: .Destructive) { action in
        calculateNewDueDate(2.0, customTask)
        controller.taskAndTasklistsSharedObject?.modifyTaskForSpecifiedTasklist(customTask)
        controller.updateDetailLabelOnCell(selectedCell, row: index.row)
        NSLog("Changed due date by two days.")
    }
    
    let nextWeekAction = UIAlertAction(title: nextWeekButtonTitle, style: .Destructive) { action in
        calculateNewDueDate(7.0, customTask)
        controller.taskAndTasklistsSharedObject?.modifyTaskForSpecifiedTasklist(customTask)
        controller.updateDetailLabelOnCell(selectedCell, row: index.row)
        NSLog("Changed due date to next week")
    }

    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel) { action in
        controller.updateDetailLabelOnCell(selectedCell, row: index.row)
        NSLog("Delete Cancelled.")
    }

    
    // Add the actions.
    alertController.addAction(nextWeekAction)
    alertController.addAction(dayAfterAction)
    alertController.addAction(tomorrowAction)
    alertController.addAction(cancelAction)


    // Configure the alert controller's popover presentation controller if it has one.
    if let popoverPresentationController = alertController.popoverPresentationController {
        // This method expects a valid cell to display from.
        // selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath)!
        popoverPresentationController.sourceRect = selectedCell.frame
        //Fix it for ipad
        popoverPresentationController.sourceView = controller.view
        popoverPresentationController.permittedArrowDirections = .Up
    }
    
    controller.presentViewController(alertController, animated: true, completion: nil)
}


func calculateNewDueDate(noOfDays : Double, customTask : tasksStructWithListName) {
    let currentDueDate = customTask.taskInfo.duedate
    let newDueDate = currentDueDate?.dateByAddingTimeInterval(NSTimeInterval(60*60*24)*noOfDays)
    customTask.taskInfo.duedate = newDueDate
}


/// Show a text entry alert with two custom buttons.
func showTasklistNameEntryAlert(controller: TaskListsTableViewController) {
    let title = NSLocalizedString("Tasklist Name", comment: "")
    let message = NSLocalizedString("Please enter desired tasklist name", comment: "")
    let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
    let otherButtonTitle = NSLocalizedString("OK", comment: "")
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    var tasklistField : UITextField = UITextField()
    var tasklistName : String?
    // Add the text field for text entry.
    alertController.addTextFieldWithConfigurationHandler { textField in
        // If you need to customize the text field, you can do so here.
        textField.placeholder = "Tasklist Name"
        tasklistField = textField
    }
    
    // Create the actions.
    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
        NSLog("The add tasklist cancel action occured.")
    }
    
    let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
        tasklistName = tasklistField.text
        NSLog("Attempting to add a tasklist \(tasklistName)")
        if tasklistName != nil {
        controller.taskAndTasklistsSharedObject?.addSpecifiedTasklist(tasklistName!)
        var customTasklist = tasklistStruct(identifier: "--", title: tasklistName!)
        controller.tasklistsDataSource.append(customTasklist)
        controller.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: controller.tasklistsDataSource.count - 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Bottom)
            controller.disableCellSelection()
        } else {
            showSimpleAlert(controller, "Tasklist name not entered", "Did not create the tasklist as no name was entered.")
        }
    }
    
    // Add the actions.
    alertController.addAction(cancelAction)
    alertController.addAction(otherAction)
    
    controller.presentViewController(alertController, animated: true, completion: nil)
}


