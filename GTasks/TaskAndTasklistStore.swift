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


class tasklistStruct: NSObject, NSCoding {
    var identifier : String = "--"
    var title : String = "--"
    
    init(identifier : String, title: String) {
        self.identifier = identifier
        self.title = title
    }
    
    required init(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as String
        self.title = aDecoder.decodeObjectForKey("title") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(identifier, forKey: "identifier")
        aCoder.encodeObject(title, forKey: "title")
    }
}

class taskStruct : NSObject, NSCoding {
    var title : String = "--"
    var notes : String? = nil
    var duedate : NSDate? = nil
    var status : String = "--"
    var identifier : String = "--"
    
    init(title: String, notes: String?, duedate: NSDate?, status: String, identifier: String) {
        self.title = title
        self.notes = notes
        self.duedate = duedate
        self.status = status
        self.identifier = identifier
    }
    
    required init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey("title") as String
        self.notes = aDecoder.decodeObjectForKey("notes") as? String
        self.duedate = aDecoder.decodeObjectForKey("duedate") as? NSDate
        self.status = aDecoder.decodeObjectForKey("status") as String
        self.identifier = aDecoder.decodeObjectForKey("identifier") as String

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        if notes != nil {
        aCoder.encodeObject(notes!, forKey: "notes")
        }
        if duedate != nil {
        aCoder.encodeObject(duedate!, forKey: "duedate")
        }
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(identifier, forKey: "identifier")

    }

}

class tasksStructWithListName: NSObject, NSCoding {
    var tasklistInfo : tasklistStruct
    var taskInfo : taskStruct
    var sync : Bool = true  //Default is true as this is the majority
    
    init(tasklistInfo: tasklistStruct, taskInfo: taskStruct){
        self.tasklistInfo = tasklistInfo
        self.taskInfo = taskInfo
    }
    
    required init(coder aDecoder: NSCoder) {
        self.tasklistInfo = aDecoder.decodeObjectForKey("tasklistInfo") as tasklistStruct
        self.taskInfo = aDecoder.decodeObjectForKey("taskInfo") as taskStruct
        self.sync = aDecoder.decodeBoolForKey("sync")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(tasklistInfo, forKey: "tasklistInfo")
        aCoder.encodeObject(taskInfo, forKey: "taskInfo")
        aCoder.encodeBool(sync, forKey: "sync")
    }

}


//MARK - Singleton
//The below is for the singleton global object
var instance : TaskAndTasklistStore?


class TaskAndTasklistStore:NSObject {
    
    //MARK: Datasource for tasklist viewcontroller 
    //To Store the fetched Task lists
    //var fetchedSetOfTasklists: GTLTasksTaskLists?
    //var countOfTasklists:UInt = 0
    var tasklistsArray : Array<tasklistStruct> = [tasklistStruct]()

    
   // var fetchedSetOfTasks: GTLTasksTasks = GTLTasksTasks()
   // var defaultTasklist : GTLTasksTaskList?
   // var countOfTasks:UInt = 0
    
    
    
    //MARK: Datasource for taskviewcontrollers
    // Design decision: Simple array in which each element will contain task and tasklist info.
    // This will make a simple datasource. The other option was to have just one reference of the tasklist and a 
    // array of tasks, this will lead to complexities in the data source.
    //nowTasks will contain the tasks which are due for today and before
    var nowTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    // nextTasks will contain tasks which have a due date
    
    var nextTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    // laterTasks are tasks which do not have a due date
    
    var laterTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    //defaultTasks are all tasks in a tasklist, including completed ones
    
    var defaultTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    // A task marked completed will not show up on a refresh, in nowTasks and laterTasks. It will show up
    // in the defaultTasks till it is deleted/hidden
    
    var defaultTasklist : tasklistStruct?
    

    //MARK: Datasource for new tasks
    var userNowTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var userNextTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var userLaterTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var userDefaultTasksDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    
    
    //MARK: Thread Sync
    let collateQueue = dispatch_queue_create("collate.gtask", DISPATCH_QUEUE_SERIAL)

    //MARK: Utilities
    //Properties to control the communication with google api
    var ticket:GTLServiceTicket? = nil
    
    //To ensure the singleton, dispatch_once is done only once.
    struct flag {
        static var onceflag : dispatch_once_t = 0
    }

    //MARK: INIT
    
    class func singleInstance() -> TaskAndTasklistStore {
        dispatch_once(&flag.onceflag, {()->Void in
            instance = TaskAndTasklistStore()
            })
        return instance!
    }
    
    private override init() {
        super.init()
      //  self.tasksService = tasksService
        
        
        // Download the tasklists and tasks from google and populate the data structures.
        // We will keep the authentication and authorization in the view controller for now.
        // The authentication keys would have to be passed on from the view controller
        // during instantiation, these keys would be saved for apps life time.

        var notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "initializeTheTasklistsAndTasks", name: "AuthComplete", object: nil)
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
            if error == nil
            {
                var fetchedTasklists = tasklistsReturned as? GTLTasksTaskLists
                //Do not forget to initialize the array
                self.tasklistsArray = []
                if fetchedTasklists != nil {
                    for obj in fetchedTasklists! {
                        var GTLtasklist = obj as GTLTasksTaskList
                        var newTasklist = tasklistStruct(identifier: GTLtasklist.identifier!, title: GTLtasklist.title!)
                        self.tasklistsArray.append(newTasklist)
                    }
                    LogError.log("fetched the tasklists \(self.tasklistsArray.count)")
                    self.initializeTheTasksWithinTheTasklists()
                } else {
                    LogError.log("Fetched task lists is empty)")
                }
            } else {
                LogError.log("\(error)")
            }
        })
        } else {
            LogError.log("ERROR: Query is already in progress ticket is not nil")
        }
        return true
    }
    
    //Initialize the model
    func initializeTheTasksWithinTheTasklists()  {
        if tasklistsArray.count != 0 {
            getTasksForSpecifiedTasklist(tasklistsArray[0])
            getALLTasksForALLTasklist()
        }
    }
    
    //MARK: PRIVATE UTILITY FUNCTIONS
    private func GTLTaskToCustomTask(task: GTLTasksTask, tasklist: tasklistStruct, synced: Bool) -> tasksStructWithListName {
        var duedate : NSDate?
        if task.due == nil {
            duedate = nil } else {
            duedate = task.due.date
        }
        let taskInfo = taskStruct(title: task.title, notes: task.notes, duedate: duedate, status: task.status, identifier: task.identifier)
        let tasklistInfo = tasklistStruct(identifier: tasklist.identifier, title: tasklist.title)
        let customTask = tasksStructWithListName(tasklistInfo: tasklistInfo, taskInfo: taskInfo)
        customTask.sync = synced
        return customTask
    }
    
    
    private func addTasksToDataSource(fetchedSetOfTasks: GTLTasksTasks, tasklist: tasklistStruct) {
        for obj in fetchedSetOfTasks {
            let task = obj as GTLTasksTask
            let customTask = self.GTLTaskToCustomTask(task, tasklist: tasklist, synced: true)
            if customTask.taskInfo.status != "completed" {
                addtaskToDataSource(customTask)
            }
        } // END of For loop
        
        NSNotificationCenter.defaultCenter().postNotificationName("FILTEREDTASKSREADY", object: nil)
    }
    
    private func addtaskToDataSource(customTask: tasksStructWithListName) {
        segregateTaskAndAppend(customTask)
    }
    
    private func segregateTaskAndAppend(customTask: tasksStructWithListName) {
        
        if customTask.taskInfo.duedate != nil {
            var compareresult = customTask.taskInfo.duedate!.compare(NSDate())
            if (compareresult == NSComparisonResult.OrderedAscending) || (compareresult == NSComparisonResult.OrderedSame)  {
                appendTaskToDataSource(customTask, dataSourceType: "now")
            } else {
                appendTaskToDataSource(customTask, dataSourceType: "next")
            }
        } else {
            //Insert into the later tasklist, keeping due date to be nil
            appendTaskToDataSource(customTask, dataSourceType: "later")
        }
    }
    
    private func appendTaskToDataSource(task: tasksStructWithListName, dataSourceType: String) {
        switch dataSourceType {
        case "now" :
            if task.sync == true {
                dispatch_async(collateQueue, {()->Void in self.nowTasksDataSource.append(task)})
            } else {
                dispatch_async(collateQueue, {()->Void in self.userNowTasksDataSource.append(task)})
            }
            
        case "next" :
            if task.sync == true {
                dispatch_async(collateQueue, {()->Void in self.nextTasksDataSource.append(task)})
            } else {
                dispatch_async(collateQueue, {()->Void in self.userNextTasksDataSource.append(task)})
            }
            
        case "later" :
            if task.sync == true {
                dispatch_async(collateQueue, {()->Void in self.laterTasksDataSource.append(task)})
            } else {
                dispatch_async(collateQueue, {()->Void in self.userLaterTasksDataSource.append(task)})
            }
            
        default:
            LogError.log("ERROR: Out of bounds in switch statement")
        }
    }
    
    private func addTaskToSpecifiedTasklist(tasklist: GTLTasksTaskList, task: GTLTasksTask, customTask: tasksStructWithListName) -> Bool {
        let query = GTLQueryTasks.queryForTasksInsertWithObject(task, tasklist: tasklist.identifier) as GTLQueryTasks
        ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
            if error == nil {
                self.markUploadSuccess(customTask)
            } else
            {
                LogError.log("\(error)")
            }
        })
        return true
    }

    
    private func markUploadSuccess(customTask: tasksStructWithListName) {
        if customTask.taskInfo.duedate != nil {
            var compareresult = customTask.taskInfo.duedate!.compare(NSDate())
            if (compareresult == NSComparisonResult.OrderedAscending) || (compareresult == NSComparisonResult.OrderedSame)  {
                updateSyncFlagInDataSource(customTask, dataSourceType: "now")
            } else {
                updateSyncFlagInDataSource(customTask, dataSourceType: "next")
            }
        } else {
            //Insert into the later tasklist, keeping due date to be nil
            updateSyncFlagInDataSource(customTask, dataSourceType: "later")
        }
    }
    
    
    
    private func updateSyncFlagInDataSource(customTask: tasksStructWithListName, dataSourceType: String) {
        var dataSource : Array<tasksStructWithListName>?
        
        switch dataSourceType {
        case "now" :
             dataSource = userNowTasksDataSource
            
        case "next" :
             dataSource = userNextTasksDataSource
            
        case "later" :
             dataSource = userLaterTasksDataSource
            
        default:
            LogError.log("ERROR: Out of bounds in switch statement")
        }
        
        for obj in dataSource! {
            if obj.taskInfo.identifier == customTask.taskInfo.identifier {
                obj.sync = true
            } else {
            LogError.log("ERROR: DID NOT FIND TASK!")
            }
        }
        
        // Also check the defaultTasksDataSource and update
        for obj in userDefaultTasksDataSource {
            if obj.taskInfo.identifier == customTask.taskInfo.identifier {
                obj.sync = true
            } else {
                LogError.log("ERROR: DID NOT FIND TASK!")
            }
        }
         NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
    }

    private func addtaskToUserDefaultTasksDataSource(customTask : tasksStructWithListName) {
        if defaultTasklist?.identifier == customTask.tasklistInfo.identifier {
            userDefaultTasksDataSource.append(customTask)
        }
    }
    
    


    
    //MARK: Task related methods - get, add, delete, modify (patch, move)
    
    //For populating the Tasks Control
    func getTasksForSpecifiedTasklist(tasklist: tasklistStruct) -> Bool {
        if ticket == nil {
                var query = GTLQueryTasks.queryForTasksListWithTasklist(tasklist.identifier) as GTLQueryTasks
                ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasksReturned, error)-> Void in
                    self.ticket = nil
                    let GTLTasks = tasksReturned as GTLTasksTasks
                    if error == nil {
                        self.defaultTasksDataSource = []
                        self.defaultTasklist = tasklist
                        for obj in GTLTasks {
                            let GTLTask = obj as GTLTasksTask
                            let customTask = self.GTLTaskToCustomTask(GTLTask, tasklist: tasklist, synced: true)
                            self.defaultTasksDataSource.append(customTask)
                        }
                        LogError.log("fetched the tasks \(self.defaultTasksDataSource.count)")
                        NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
                    } else {
                        LogError.log("\(error)")
                    }
                })
        } else {
            LogError.log("Get Task Query already in progress")
        }
        return true
    }
    
    
    //For populating the Tasks Control
    func getALLTasksForALLTasklist() {
        var queryQueue = dispatch_queue_create("task.tasklist.gtask", DISPATCH_QUEUE_CONCURRENT)
        for tasklist in tasklistsArray {
            dispatch_async(queryQueue, {()->Void in
            //Start of Main Block
                var query = GTLQueryTasks.queryForTasksListWithTasklist(tasklist.identifier) as GTLQueryTasks
                self.ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasksReturned, error)-> Void in
                    if error == nil {
                        let fetchedSetOfTasks = tasksReturned as GTLTasksTasks
                        self.addTasksToDataSource(fetchedSetOfTasks, tasklist: tasklist)
                    } else {
                        LogError.log("\(error)")
                    }
                }) //END of QUERY BLOCK
            }) //END of dispatch async
        } //END of For loop
    }
    
    
    func addNewTask(customTask: tasksStructWithListName) {
        // Add the task to the now, next and later data sources, so it can be preserved in case upload to google fails
        addtaskToDataSource(customTask)
        // Add the task to the userDefaultTasksDataSource, so that the default tasklist based VC will be able to display the task
        // as well as subsequent updates on the tasks, when the task is synced.
        addtaskToUserDefaultTasksDataSource(customTask)
        
        //Notification so the user view is updated.
        NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
        
        //Prepare the task so it can be uploaded to Google
        var task = GTLTasksTask()
        task.title = customTask.taskInfo.title
        task.notes = customTask.taskInfo.notes
        task.due = GTLDateTime(date: customTask.taskInfo.duedate, timeZone: NSTimeZone())
        var tasklist = GTLTasksTaskList()
        tasklist.identifier = customTask.tasklistInfo.identifier
        addTaskToSpecifiedTasklist(tasklist, task: task, customTask: customTask)
        //addTaskToSpecifiedTasklist will also update the dataSources if the upload was sucessful
        //The data sources are updated two times, once before upload to google and once after upload to google if the upload was successful.
        
        //Another notification is upload is successful it will show. Initially I kept this in the success path for upload
        // But it remains buried somewhere deep if it lies there, so I brought it ahead to improve readibility. Only caveat is 
        // addTaskToSpecifiedTasklist is asynchronous and this is may get sent sooner than needed. So moving it back!
        // NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)

    }
    
    func checkTasksForSyncToGoogle() {
        for userArrays in [userNowTasksDataSource, userNextTasksDataSource, userLaterTasksDataSource] {
            for customTask in userArrays {
                var task = GTLTasksTask()
                task.title = customTask.taskInfo.title
                task.notes = customTask.taskInfo.notes
                task.due = GTLDateTime(date: customTask.taskInfo.duedate, timeZone: NSTimeZone())
                var tasklist = GTLTasksTaskList()
                tasklist.identifier = customTask.tasklistInfo.identifier
                addTaskToSpecifiedTasklist(tasklist, task: task, customTask: customTask)
            }
        }
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
    func modifyTaskForSpecifiedTasklist(tasklist: tasklistStruct, task: taskStruct) -> Bool {
        
        var GTLtask = GTLTasksTask()
        GTLtask.identifier = task.identifier
        GTLtask.title = task.title
        GTLtask.status = task.status
        GTLtask.due = GTLDateTime(date: task.duedate, timeZone: NSTimeZone())
        
        var query = GTLQueryTasks.queryForTasksUpdateWithObject(GTLtask, tasklist: tasklist.identifier, task: task.identifier) as GTLQueryTasks
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
    func moveTaskToSpecifiedTasklist(tasklist: tasklistStruct, taskIdentifier: String) -> Bool {
        var query = GTLQueryTasks.queryForTasksMoveWithTasklist(tasklist.identifier, task: taskIdentifier) as GTLQueryTasks
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

    
    
    //MARK: Tasklists methods - get, add, delete, edit
    
    //For Tasklist Control
    func getAllTasklists() -> Bool {
        var query = GTLQueryTasks.queryForTasklistsList() as GTLQueryTasks
        if ticket == nil {
        ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistsReturned, error)-> Void in
            self.ticket = nil
            if error == nil {
                if tasklistsReturned != nil {
                    let fetchedSetOfTasklists = tasklistsReturned as? GTLTasksTaskLists
                    self.tasklistsArray = []
                    for obj in fetchedSetOfTasklists! {
                        var GTLtasklist = obj as GTLTasksTaskList
                        let tasklistInfo = tasklistStruct(identifier: GTLtasklist.identifier, title: GTLtasklist.title)
                        self.tasklistsArray.append(tasklistInfo)
                        }
                    } else {
                    LogError.log("Tasklists returned is nil")
                    }
            } else {
                LogError.log("Error fetching tasklists")
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
    
}
