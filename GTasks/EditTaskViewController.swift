//
//  EditTaskViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class EditTaskViewController: UIViewController {

    var task : taskStruct = taskStruct(title: "--", notes: nil, duedate: nil, status: "--", identifier: "--")
    var tasklist : GTLTasksTaskList? = nil
    var taskField:UITextField? = nil
    
    
    //To check if a task is in progress
    var taskTicket:GTLServiceTicket? = nil
    /* redundant moved to model
    func editTask() {
        
        if self.taskField?.text != nil
        {
            task?.title = taskField?.text
            var query = GTLQueryTasks.queryForTasksUpdateWithObject(task, tasklist: tasklist?.identifier, task: task?.identifier) as GTLQueryTasks
            if taskTicket == nil {
                taskTicket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                    if error == nil {
                        self.taskTicket = nil
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        println("error is \(error)")
                        self.taskTicket = nil
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            } else {
                println("Error: Query Operation in Progress")
            }
        }
    }
    
    func deleteTask() {
        
        if self.taskField?.text != nil
        {
            var query = GTLQueryTasks.queryForTasksDeleteWithTasklist(tasklist?.identifier, task: task?.identifier) as GTLQueryTasks
            if taskTicket == nil {
                taskTicket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                    if error == nil {
                        self.taskTicket = nil
                        println("deleted tasklist")
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        println("error is \(error)")
                        self.taskTicket = nil
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            } else {
                println("Error: Query Operation in Progress")
            }
        }
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        self.taskField = UITextField(frame: CGRectMake(10, 50, CGRectGetWidth(self.view.bounds) - 20, 100))
        
        taskField?.backgroundColor = UIColor.grayColor()
        self.taskField?.text = task.title
        self.view.addSubview(taskField!)
        
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("editTask"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: Selector("deleteTask"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        self.navigationItem.title = "Edit Task"
        //var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont(name: "Zapfino", size: 15)]
        //self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
    }
    
    override func viewDidAppear(animated: Bool) {
        // Updating the text field to the title of the latest task list object
        self.taskField?.text = task.title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
