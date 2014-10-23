//
//  EditTaskListViewController.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class EditTaskListViewController: UIViewController {

    var tasklist : GTLTasksTaskList? = nil
    var tasklistField:UITextField? = nil
    
    var tasksService = GTLServiceTasks()
    
    //To check if a task is in progress
    var tasklistsTicket:GTLServiceTicket? = nil
    
    func editTaskList() {
        
        if self.tasklistField?.text != nil
        {
            tasklist?.title = tasklistField?.text
            var query = GTLQueryTasks.queryForTasklistsUpdateWithObject(tasklist, tasklist: tasklist?.identifier) as GTLQueryTasks
            if tasklistsTicket == nil {
                tasklistsTicket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistReturned, error)-> Void in
                    if error == nil {
                        self.tasklistsTicket = nil
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        println("error is \(error)")
                        self.tasklistsTicket = nil
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            } else {
                println("Error: Query Operation in Progress")
            }
        }
    }
    
    func deleteTaskList() {
        
        if self.tasklistField?.text != nil
        {
            var query = GTLQueryTasks.queryForTasklistsDeleteWithTasklist(tasklist?.identifier) as GTLQueryTasks
            if tasklistsTicket == nil {
                tasklistsTicket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistReturned, error)-> Void in
                    if error == nil {
                        self.tasklistsTicket = nil
                        println("deleted tasklist")
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        println("error is \(error)")
                        self.tasklistsTicket = nil
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            } else {
                println("Error: Query Operation in Progress")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        self.tasklistField = UITextField(frame: CGRectMake(10, 40, CGRectGetWidth(self.view.bounds) - 20, 100))
        
        tasklistField?.backgroundColor = UIColor.grayColor()
        self.tasklistField?.text = tasklist?.title
        self.view.addSubview(tasklistField!)
        
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("editTaskList"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: Selector("deleteTaskList"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        self.navigationItem.title = "Edit Task List"
        //var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont(name: "Zapfino", size: 15)]
        //self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
    }
    
    override func viewDidAppear(animated: Bool) {
        // Updating the text field to the title of the latest task list object
        self.tasklistField?.text = tasklist?.title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gobackfornow() -> Void {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
