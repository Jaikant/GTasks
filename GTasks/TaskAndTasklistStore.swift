//
//  TaskAndTasklistStore.swift
//  GTasks
//
//  Created by Jai on 16/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import Foundation

extension GTLTasksTaskLists : SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

extension GTLTasksTasks : SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}



class TaskAndTasklistStore {
    
    //To Store the fetched Task lists
    var fetchedSetOfTasklists: GTLTasksTaskLists = GTLTasksTaskLists()
    
    var fetchedSetOfTasks: GTLTasksTasks = GTLTasksTasks()
    
    var countOfTasklists:UInt = 0
    
    var countOfTasks:UInt = 0

    
    var defaultTasklist : GTLTasksTaskList?

    //Dictionary which will store the entire list of tasks.
    // Along with the tasklist identifier which is the key to the dictionary.
    // Using this dictionary we will be able to do the following:
    // 1. Populate the TasksTableView, for all the tasklists.
    // 2. Populate the ModifyTasksTableView with needed information. 
    // We will need to keep this dictionary synced with Google at all times.
    var dictionaryOfTaskSets = Dictionary<String, GTLTasksTasks> ()

    
    
    //Needed for Authentication
    let tasksService = GTLServiceTasks()
    
    
    
    
    //Properties to control the communication with google api
    var fetchTasks: Bool = false
    var ticket:GTLServiceTicket? = nil

    init() {
    }


    init(tasksService: GTLServiceTasks) {
        
        self.tasksService = tasksService

        
        
        
        // Download the tasklists and tasks from google and populate the data structures.
        // We will keep the authentication and authorization in the view controller for now.
        // The authentication keys would have to be passed on from the view controller
        // during instantiation, these keys would be saved for apps life time.

        
        LogError.log("Init starting")
        initializeTheTasklistsAndTasks()
        LogError.log("init completed")
    }
    
    //Initialize the model
    func initializeTheTasklistsAndTasks() ->  Bool {
        var query = GTLQueryTasks.queryForTasklistsList() as GTLQueryTasks
        if ticket == nil {
        var ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistsReturned, error)-> Void in
            self.ticket = nil
            self.fetchedSetOfTasklists = tasklistsReturned as GTLTasksTaskLists
            if error == nil {
                for obj in self.fetchedSetOfTasklists {
                    self.countOfTasklists++

                }
                LogError.log("fetched the tasklists \(self.countOfTasklists)")
                self.setDefaultTasklist(self.fetchedSetOfTasklists.itemAtIndex(0) as? GTLTasksTaskList)
                self.initializeTheTasksWithinTheTasklists()
            } else {
                LogError.log("\(error)")
            }
        })
        }
        return true
    }
    
    //Initialize the model
    func initializeTheTasksWithinTheTasklists()  {
        if defaultTasklist != nil {
            getTasksForSpecifiedTasklist(defaultTasklist!)
        }
    }
    
    
    //Task related methods - get, add, delete, modify (patch, move)
    
    //For populating the Tasks Control
    func getTasksForSpecifiedTasklist(tasklist: GTLTasksTaskList) -> Bool {
        if ticket == nil {
                var query = GTLQueryTasks.queryForTasksListWithTasklist(tasklist.identifier) as GTLQueryTasks
                ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasksReturned, error)-> Void in
                    self.ticket = nil
                    self.fetchedSetOfTasks = tasksReturned as GTLTasksTasks
                    self.countOfTasks = 0
                    if error == nil {
                        for obj in self.fetchedSetOfTasks {
                            self.countOfTasks++
                        }
                        LogError.log("fetched the tasks \(self.countOfTasks)")
                        NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
                    } else {
                        LogError.log("\(error)")
                    }
                })
                self.fetchTasks = false
        } else {
            LogError.log("Get Task Query already in progress")
        }
        return true
    }

    //For AddTask Controller
    func addTaskToSpecifiedTasklist(tasklist: GTLTasksTaskList, task: GTLTasksTask) -> Bool {
        let query = GTLQueryTasks.queryForTasksInsertWithObject(task, tasklist: tasklist.identifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                } else
                {
                    LogError.log("\(error)")
                }
                })
        } else {
            println("Error: Query Operation in Progress")
            return false
        }
        return true
    }

    //For Delete Task Controller
    func deleteTaskFromSpecifiedTasklist(tasklistIdentifier: NSString, taskIdentifier: NSString) -> Bool {
        
        let query = GTLQueryTasks.queryForTasksDeleteWithTasklist(tasklistIdentifier, task: taskIdentifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                } else
                {
                    LogError.log("Error deleting: \(error)")
                }
            })
        } else {
            println("Error: Query Operation in Progress")
            return false
        }
        return true
    }

    
    //For ModifyTask control, could also be invoked from task control
    func modifyTaskForSpecifiedTasklist(tasklist: GTLTasksTaskList, task: GTLTasksTask) -> Bool {
        var query = GTLQueryTasks.queryForTasksUpdateWithObject(task, tasklist: tasklist.identifier, task: task.identifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                } else {
                    println("error modifying task \(error)")
                }
            })
        } else {
            println("Error: Query Operation in Progress")
        }
        return true
    }
    
    
    //For ModifyTask control, could also be invoked from task control
    func moveTaskToSpecifiedTasklist(tasklist: GTLTasksTaskList, task: GTLTasksTask) -> Bool {
        var query = GTLQueryTasks.queryForTasksMoveWithTasklist(tasklist.identifier, task: task.identifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    self.getTasksForSpecifiedTasklist(tasklist)
                } else {
                    println("error moving task \(error)")
                }
            })
        } else {
            println("Error: Query Operation in Progress")
        }
        return true
    }

    
    
    //Tasklists methods - get, add, delete, edit
    
    //For Tasklist Control
    func getAllTasklists() -> Bool {
        var query = GTLQueryTasks.queryForTasklistsList() as GTLQueryTasks
        if ticket == nil {
        ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistsReturned, error)-> Void in
            self.ticket = nil
            self.fetchedSetOfTasklists = tasklistsReturned as GTLTasksTaskLists
            if error == nil {
                for obj in self.fetchedSetOfTasklists {
                    self.countOfTasklists++
                }
            } else {
                LogError.log("While fetching All tasklists\(error)")
            }
        })
        }
        return true
    }
    
    //For EditTasklist control, could also be invoked from task control
    func editSpecifiedTasklist(tasklist: GTLTasksTaskList, tasklistIdentifer: String) -> Bool {
        var query = GTLQueryTasks.queryForTasklistsUpdateWithObject(tasklist, tasklist: tasklistIdentifer) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistsReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    self.getAllTasklists()
                } else {
                    LogError.log("While fetching All tasklists\(error)")
                }
            })
        }
        return true
    }
    
    
    //For EditTasklist control, could also be invoked from task control
    func deleteSpecifiedTasklist(tasklist: GTLTasksTaskList) -> Bool {
        var query = GTLQueryTasks.queryForTasklistsDeleteWithTasklist(tasklist.identifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    self.getAllTasklists()
                } else {
                    println("error is \(error)")
                }
            })
        } else {
            println("Error: Query Operation in Progress")
        }
        return true
    }
    
    //For EditTasklist control, could also be invoked from task control
    func addSpecifiedTasklist(tasklist: GTLTasksTaskList) -> Bool {
        var query = GTLQueryTasks.queryForTasklistsInsertWithObject(tasklist) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                } else {
                    println("error is \(error)")
                }
            })
        } else {
            println("Error: Query Operation in Progress")
        }
        return true
    }
    
    func setDefaultTasklist(tasklist: GTLTasksTaskList?) {
        if tasklist != nil {
        defaultTasklist = tasklist
        }
    }
    
}
