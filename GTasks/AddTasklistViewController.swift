//
//  AddTaskListViewController.swift
//  GTasks
//
//  Created by Jai on 18/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class AddTasklistViewController: UIViewController {
    
    var tasklistField:UITextField? = nil
    
   // var tasksService = GTLServiceTasks()
    
    //To check if a task is in progress
    var tasklistsTicket:GTLServiceTicket? = nil
    
    func createTaskList() {
    
        var tasklist = GTLTasksTaskList()
        if self.tasklistField?.text != nil
        {
        tasklist.title = self.tasklistField?.text
        var query = GTLQueryTasks.queryForTasklistsInsertWithObject(tasklist) as GTLQueryTasks
        //var service = self.tasksService
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        self.tasklistField = UITextField(frame: CGRectMake(10, 50, CGRectGetWidth(self.view.bounds) - 20, 100))
        
        tasklistField?.backgroundColor = UIColor.grayColor()
        
        self.view.addSubview(tasklistField!)
        
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("createTaskList"))
        self.navigationItem.rightBarButtonItem = rightButton
        
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("gobackfornow"))
        self.navigationItem.leftBarButtonItem = leftButton
        
        self.navigationItem.title = "Add Task List"
        //var navigationbarTextAttr : Dictionary<NSObject, AnyObject> = [NSFontAttributeName : UIFont(name: "Zapfino", size: 15)]
        //self.navigationController?.navigationBar.titleTextAttributes = navigationbarTextAttr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gobackfornow() -> Void {
        self.navigationController?.popViewControllerAnimated(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
