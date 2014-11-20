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
    var updated : NSDate? = nil
    var completed : NSDate? = nil
    
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
        self.updated = aDecoder.decodeObjectForKey("updated") as? NSDate
        self.completed = aDecoder.decodeObjectForKey("completed") as? NSDate

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
        if updated != nil {
            aCoder.encodeObject(updated!, forKey: "updated")
        }
        if completed != nil {
            aCoder.encodeObject(completed!, forKey: "completed")
        }
    }

}

class tasksStructWithListName: NSObject, NSCoding {
    var tasklistInfo : tasklistStruct
    var taskInfo : taskStruct
    var sync : Bool = true  //Default is true as this is the majority
    var retryupload : Bool = false
    var retryMove : Bool = false
    var markfordeletion : Bool = false
    
    init(tasklistInfo: tasklistStruct, taskInfo: taskStruct){
        self.tasklistInfo = tasklistInfo
        self.taskInfo = taskInfo
    }
    
    required init(coder aDecoder: NSCoder) {
        self.tasklistInfo = aDecoder.decodeObjectForKey("tasklistInfo") as tasklistStruct
        self.taskInfo = aDecoder.decodeObjectForKey("taskInfo") as taskStruct
        self.sync = aDecoder.decodeBoolForKey("sync")
        self.retryupload = aDecoder.decodeBoolForKey("retryupload")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(tasklistInfo, forKey: "tasklistInfo")
        aCoder.encodeObject(taskInfo, forKey: "taskInfo")
        aCoder.encodeBool(sync, forKey: "sync")
        aCoder.encodeBool(retryupload, forKey: "retryupload")
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
    
    var completedTasksForDefaultDataSource : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var modifiedTasksTobeSynced : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var movedTasksTobeSynced : Array<tasksStructWithListName> = [tasksStructWithListName]()
    var deletedTasksTobeSynced : Array<tasksStructWithListName> = [tasksStructWithListName]()


    
    
    //MARK: Thread Sync
    let collateQueue = dispatch_queue_create("collate.gtask", DISPATCH_QUEUE_SERIAL)

    //MARK: Utilities
    //Properties to control the communication with google api
    var ticket:GTLServiceTicket? = nil
    var networkError : Bool = false
    var initSuccessAndDataSourcesValid : Bool = false
    
    
    //Timers
    var periodicDownloadOfDataTimer : NSTimer?
    var ScheduleDownloadAfterAddTaskTimer : NSTimer?
    var addTaskFailedTimer : NSTimer?
    var initFailedTimer : NSTimer?
    var modifyTaskFailedTimer : NSTimer?
    var moveTaskFailedTimer : NSTimer?
    var deleteTaskTimer : NSTimer?



    
    
    
    
    
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
        
        
        // Download the tasklists and tasks from google and populate the data structures.
        // We will keep the authentication and authorization in the view controller for now.
        // The authentication keys would have to be passed on from the view controller
        // during instantiation, these keys would be saved for apps life time.

        let authObj = GoogleAuth.sharedInstance()

        LogError.log("Model Singleton Instantiated ....")

        scheduleGoogleDownload("periodicDownloadOfData", parameter: nil)
        var notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "initializeTheModel", name: "AuthComplete", object: nil)
        initializeTheModel()
    }
    
    func initializeTheModel() {
    LogError.log("Model Initializing ...")
    initializeTheTasklistsAndTasks()
    }
    
    private func networkIsAvailableDoBasicSetup() {
        self.ticket = nil
        self.networkError = false
        self.resetTimers()
        //We do the below checkForTasks after canceling any pending timers
        //as we do not want parallel checkTasks as it could possibly create duplicate entries.
        self.checkTasksForSyncToGoogle()
    }
    
    //Initialize the model
    func initializeTheTasklistsAndTasks() ->  Bool {
        var query = GTLQueryTasks.queryForTasklistsList() as GTLQueryTasks
        if ticket == nil {
        ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistsReturned, error)-> Void in
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
                    self.initializeTheTasksWithinTheTasklists()
                } else {
                    LogError.log("Fetched task lists is empty)")
                }
                self.networkIsAvailableDoBasicSetup()
            } else {
                self.ticket = nil
                LogError.log("ERROR Fetching the tasklists: \(error)")
                //There was an error during initialization, possibly a network problem.
                //Setup a timer and retry the initialization after 15 seconds.
                self.scheduleGoogleDownload("InitFailed", parameter: nil)
                self.networkError = true
            }
        })
        } else {
            LogError.log("ERROR : Initialization already in progress.")
        }
        return true
    }

    
    
    //MARK: PRIVATE UTILITY FUNCTIONS
    
    
    private func initializeTheTasksWithinTheTasklists()  {
        if tasklistsArray.count != 0 {
            /*if defaultTasklist == nil {
                setdefaultTasklist(tasklistsArray[0])
            }
            getTasksForSpecifiedTasklist(defaultTasklist!)*/
            getALLTasksForALLTasklist()
            scheduleGoogleDownload("deleteTaskInDeleteQ", parameter: nil)
        }
    }
    
    private func setdefaultTasklist(tasklist: tasklistStruct) {
        self.defaultTasklist = tasklist
    }
    
    private func GTLTaskToCustomTask(task: GTLTasksTask, tasklist: tasklistStruct, synced: Bool) -> tasksStructWithListName {
        var duedate : NSDate?
        var updated : NSDate?
        var completed : NSDate?
        
        if task.due == nil {
            duedate = nil } else {
            duedate = task.due.date
        }
        if task.updated == nil {
            updated = nil
        } else {
            updated = task.updated.date
        }
        
        if task.completed == nil {
            completed = nil
        } else {
            completed = task.completed.date
        }
        
        var taskInfo = taskStruct(title: task.title, notes: task.notes, duedate: duedate, status: task.status, identifier: task.identifier)
        taskInfo.updated = updated
        taskInfo.completed = completed
        
        let tasklistInfo = tasklist
        let customTask = tasksStructWithListName(tasklistInfo: tasklistInfo, taskInfo: taskInfo)
        customTask.sync = synced
        return customTask
    }
    
    private func taskPresentInDataSources(customTask: tasksStructWithListName) -> Bool{
        
        var arrayToCheckIfTaskIsInNowArray :  Array<tasksStructWithListName> = nowTasksDataSource.filter({ (existingtask) -> Bool in
            return (existingtask.taskInfo.identifier == customTask.taskInfo.identifier)
        })
        
        if arrayToCheckIfTaskIsInNowArray.isEmpty == false {
            //found the task return true
            return true
        }
        

        var arrayToCheckIfTaskIsInNextArray :  Array<tasksStructWithListName> = nextTasksDataSource.filter({ (existingtask) -> Bool in
            return (existingtask.taskInfo.identifier == customTask.taskInfo.identifier)
        })
        
        if arrayToCheckIfTaskIsInNextArray.isEmpty == false {
            //found the task return true
            return true
        }

        var arrayToCheckIfTaskIsInLaterArray :  Array<tasksStructWithListName> = laterTasksDataSource.filter({ (existingtask) -> Bool in
            return (existingtask.taskInfo.identifier == customTask.taskInfo.identifier)
        })
        
        if arrayToCheckIfTaskIsInLaterArray.isEmpty == false {
            //found the task return true
            return true
        }
        
        //else return false and add the task, as we did not find the task
        return false
        
    }
    
    
    private func addTasksToDataSource(fetchedSetOfTasks: GTLTasksTasks, tasklist: tasklistStruct) {
        for obj in fetchedSetOfTasks {
            let task = obj as GTLTasksTask
            let customTask = self.GTLTaskToCustomTask(task, tasklist: tasklist, synced: true)
            
            if !taskPresentInDataSources(customTask)
            {
            
                var arrayToCheckIfTaskIsMarkedForDeletion :  Array<tasksStructWithListName> = deletedTasksTobeSynced.filter({ (tobedeletedtask) -> Bool in
                    return (tobedeletedtask.taskInfo.title == customTask.taskInfo.title)
                })
            
                if arrayToCheckIfTaskIsMarkedForDeletion.isEmpty {
                    if customTask.taskInfo.status != "completed" {
                        addtaskToDataSource(customTask)
                    } else {
                        appendTaskToDataSource(customTask, dataSourceType: "completedTasksForDefaultVC")
                    }
                } else {
                    println("Going to delete: \(arrayToCheckIfTaskIsMarkedForDeletion.last!.taskInfo.title)")
                    updateDeleteQueueAndSendTaskForDeletion(customTask)
                }
            } // END of IF loop, task not present in sources
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
    
    //private func appendIfNotPresent(customTask: tasksStructWithListName, .. to be done.
    
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
            
        case "completedTasksForDefaultVC" :
            dispatch_async(collateQueue, {()->Void in self.completedTasksForDefaultDataSource.append(task)})
            
        default:
            LogError.log("ERROR: Out of bounds in switch statement")
        }
    }
    
    private func addTaskToSpecifiedTasklist(tasklist: GTLTasksTaskList, task: GTLTasksTask, customTask: tasksStructWithListName) -> Bool {
        
        let query = GTLQueryTasks.queryForTasksInsertWithObject(task, tasklist: tasklist.identifier) as GTLQueryTasks
        tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
            if error == nil {
                self.markUploadSuccess(customTask)
                self.scheduleGoogleDownload("ScheduleDownloadAfterAddTask", parameter: nil)
            } else
            {
                LogError.log("\(error)")
                self.scheduleGoogleDownload("AddTaskFailed", parameter: nil)
            }
        })

        return true
    }

    private func scheduleGoogleDownload(selector : String, parameter: AnyObject?) {
        
        
        
        switch selector {
        case "periodicDownloadOfData" :
            periodicDownloadOfDataTimer = NSTimer.scheduledTimerWithTimeInterval(1800, target: self, selector: "initializeTheModelOnTimerTrigger", userInfo: nil, repeats: false)
            LogError.log("scheduleGoogleDownload in 30 minutes")

            
        case "AddTaskFailed" :
            if networkError != true {
                addTaskFailedTimer?.invalidate()
                addTaskFailedTimer =  NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "checkTasksForSyncToGoogleOnTimerTrigger", userInfo: nil, repeats: false)
                LogError.log("Scheduled task upload in 1 minute")
            }
            
            
        case "ScheduleDownloadAfterAddTask" :
            if networkError != true {
                resetTimers()
                ScheduleDownloadAfterAddTaskTimer =  NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "initializeTheModelOnTimerTrigger", userInfo: nil, repeats: false)
                LogError.log("scheduleGoogleDownload in 30 second")
            }
        
        case "InitFailed" :
            initFailedTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "initializeTheModelOnTimerTrigger", userInfo: nil, repeats: false)
            LogError.log("scheduleGoogleDownload in 1 minute")

            
            
        case "ModifiedTaskFailed" :
            //if networkError != true {
                modifyTaskFailedTimer?.invalidate()
                modifyTaskFailedTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "syncModifiedTasksToGoogle", userInfo: nil, repeats: false)
            
        case "MoveTaskFailed" :
            //if networkError != true {
            moveTaskFailedTimer?.invalidate()
            moveTaskFailedTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "syncMovedTasksToGoogle", userInfo: nil, repeats: false)
            

        case "deleteTaskInDeleteQ" :
            deleteTaskTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "deleteTasksFromQ", userInfo: nil, repeats: false)
            LogError.log("schedule delete task in in 60 second")



        case "getTasksForSpecifiedTasklist" :
            if networkError != true {
            NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "getTasksForSpecifiedTasklist", userInfo: parameter, repeats: false)
            }
            

        default:
            LogError.log("Unimplemented value for scheduleGoogleDownload")
        }
    }
    
    
    func deleteTasksFromQ() {
        
        println("Delete task triggered")
        var arrayOfTasksToBeDeleted = deletedTasksTobeSynced.filter { (existingtask) -> Bool in
            return (existingtask.markfordeletion == false)
        }
        
        if !arrayOfTasksToBeDeleted.isEmpty {
            
            var tasktodelete = arrayOfTasksToBeDeleted.last
            
            println("Found task to delete : \(tasktodelete!.taskInfo.title)")

            deleteTaskFromSpecifiedTasklist(tasktodelete!)
            
            var temp = deletedTasksTobeSynced.filter({ (existingtask) -> Bool in
                return (existingtask.taskInfo.title != tasktodelete!.taskInfo.title)
            })
            deletedTasksTobeSynced.removeAll(keepCapacity: false)
            deletedTasksTobeSynced = temp
        }
        
        if arrayOfTasksToBeDeleted.count > 1 {
            scheduleGoogleDownload("deleteTaskInDeleteQ", parameter: nil)
        }
        
    }
    
    func initializeTheModelOnTimerTrigger() {
        LogError.log("Timer Triggered or tasklist add causing initialize the Model")
        resetTimers()
        initializeTheModel()
    }
    
    func checkTasksForSyncToGoogleOnTimerTrigger() {
        LogError.log("Timer Triggered checkTasksForSyncToGoogle")
        checkTasksForSyncToGoogle()
    }
    
    private func resetTimers() {
        addTaskFailedTimer?.invalidate()
        initFailedTimer?.invalidate()
        modifyTaskFailedTimer?.invalidate()
        moveTaskFailedTimer?.invalidate()
        ScheduleDownloadAfterAddTaskTimer?.invalidate()
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
        NSNotificationCenter.defaultCenter().postNotificationName("knotificationTaskSynced", object: nil)
    }

    private func addtaskToUserDefaultTasksDataSource(customTask : tasksStructWithListName) {
        if defaultTasklist?.identifier == customTask.tasklistInfo.identifier {
            dispatch_async(collateQueue, {()->Void in self.userDefaultTasksDataSource.append(customTask)})
        }

    }
    
    func addTodeletedTasksYetToBeSyncedToGoogleQueue(customTask: tasksStructWithListName){
        deletedTasksTobeSynced.append(customTask)
    }
    
    func updateDeleteQueueAndSendTaskForDeletion(customTask: tasksStructWithListName) {
        
        println("The count of tasks in deletedTasksTobeSynced  is \(deletedTasksTobeSynced.count)")
        
        println("values of customTask are  are  \(customTask.taskInfo.identifier) and \(customTask.tasklistInfo.identifier)")

        var temp = deletedTasksTobeSynced.filter { (existingTask) -> Bool in
            println("values of existing tsk are  \(existingTask.taskInfo.identifier) and \(existingTask.tasklistInfo.identifier)")

            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        customTask.markfordeletion = false
        if temp.count != deletedTasksTobeSynced.count {
            deletedTasksTobeSynced.removeAll(keepCapacity: false)
            deletedTasksTobeSynced += temp
            deletedTasksTobeSynced.append(customTask)
            LogError.log("replaced the task in deletedTasksTobeSynced ")
        }
    }
    
    func deletetaskFromDataSources(customTask: tasksStructWithListName) {
        
   /*
    for (var dataSource) in [defaultTasksDataSource, laterTasksDataSource] {
        dataSource = dataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
    } */
        
        var temp = userDefaultTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != userDefaultTasksDataSource.count {
            self.userDefaultTasksDataSource.removeAll(keepCapacity: false)
            self.userDefaultTasksDataSource += temp
            LogError.log("Removed the task from userDefaultTasksDataSource ")
        }
        
        
        temp = defaultTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != defaultTasksDataSource.count {
            self.defaultTasksDataSource.removeAll(keepCapacity: false)
            self.defaultTasksDataSource += temp
            LogError.log("Removed the task from defaultTasksDataSource ")
        }

        
        temp = userNowTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != userNowTasksDataSource.count {
            customTask.markfordeletion = true
            self.userNowTasksDataSource.removeAll(keepCapacity: false)
            self.userNowTasksDataSource += temp
            LogError.log("Removed the task from userNowTasksDataSource ")
            self.addTodeletedTasksYetToBeSyncedToGoogleQueue(customTask)
            return
        }

        temp = userNextTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != userNextTasksDataSource.count {
            customTask.markfordeletion = true
            self.userNextTasksDataSource.removeAll(keepCapacity: false)
            self.userNextTasksDataSource += temp
            LogError.log("Removed the task from userNextTasksDataSource ")
            self.addTodeletedTasksYetToBeSyncedToGoogleQueue(customTask)
            return
        }

        temp = userLaterTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != userLaterTasksDataSource.count {
            customTask.markfordeletion = true
            self.userLaterTasksDataSource.removeAll(keepCapacity: false)
            self.userLaterTasksDataSource += temp
            LogError.log("Removed the task from userLaterTasksDataSource ")
            self.addTodeletedTasksYetToBeSyncedToGoogleQueue(customTask)
            return
        }
        
        
        temp = nowTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != nowTasksDataSource.count {
            self.nowTasksDataSource.removeAll(keepCapacity: false)
            self.nowTasksDataSource += temp
            LogError.log("Removed the task from nowTasksDataSource ")
            return
        }
        
        temp = nextTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != nextTasksDataSource.count {
            self.nextTasksDataSource.removeAll(keepCapacity: false)
            self.nextTasksDataSource += temp
            LogError.log("Removed the task from nextTasksDataSource ")
            return
        }
        
        temp = laterTasksDataSource.filter { (existingTask) -> Bool in
            return (existingTask.taskInfo.title != customTask.taskInfo.title)
        }
        if temp.count != laterTasksDataSource.count {
            self.laterTasksDataSource.removeAll(keepCapacity: false)
            self.laterTasksDataSource += temp
            LogError.log("Removed the task from laterTasksDataSource ")
            return
        }
    }
    
    func addTaskBackToDataSources(customTask: tasksStructWithListName) {
        
        addtaskToUserDefaultTasksDataSource(customTask)
        addtaskToDataSource(customTask)
        
        NSNotificationCenter.defaultCenter().postNotificationName("NOTIFYSOURCEUPDATE", object: nil)
        // Need to update the view on receiving the above notification
        
        
        //Temporarily to force errors
        NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
    }
    
    
    
    //MARK: Task related methods - get, add, delete, modify (patch, move)
    
    //For populating the Tasks Control
    func getTasksForSpecifiedTasklist(tasklist: tasklistStruct) -> Bool {
        var query = GTLQueryTasks.queryForTasksListWithTasklist(tasklist.identifier) as GTLQueryTasks
            tasksService.executeQuery(query, completionHandler: {(ticket, tasksReturned, error)-> Void in
                let GTLTasks = tasksReturned as GTLTasksTasks
                if error == nil {
                    self.defaultTasksDataSource = []
                    self.setdefaultTasklist(tasklist)
                    for obj in GTLTasks {
                        let GTLTask = obj as GTLTasksTask
                        let customTask = self.GTLTaskToCustomTask(GTLTask, tasklist: tasklist, synced: true)
                        self.addDownloadedTaskToDefaultTasksDataSource(customTask)
                    }
                    self.removeSyncedTasksFromUserArrays("default")
                    NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
                    } else {
                    LogError.log("\(error)")
                    self.scheduleGoogleDownload("getTasksForSpecifiedTasklist", parameter: tasklist)
                }
            })
    return true
    }
    
    func addDownloadedTaskToDefaultTasksDataSource(customTask: tasksStructWithListName) {
        
        var arrayOfOneTask = deletedTasksTobeSynced.filter { (taskMarkedForDeletion) -> Bool in
            return (taskMarkedForDeletion.taskInfo.title == customTask.taskInfo.title)
        }
        
        if arrayOfOneTask.isEmpty {
            self.defaultTasksDataSource.append(customTask)
        } else
        {
            println("found task \(customTask.taskInfo.title) and did not add to default task list")
        }
    }
    
    
    //MARK: LOCAL DATA SOURCE UPDATIONS
    func updateDefaultTaskDataSourcesAndSendNotification (tasklist: tasklistStruct) {
        // Update defaultTasksDataSource, userDefaultTasksDataSource, defaultTasklist
        
        var tasksForTasklist : Array <tasksStructWithListName>?
        defaultTasksDataSource = []
        for obj in [nowTasksDataSource, nextTasksDataSource, laterTasksDataSource, userNowTasksDataSource, userNextTasksDataSource, userLaterTasksDataSource, completedTasksForDefaultDataSource]
        {
            tasksForTasklist = obj.filter { (taskindatasource: tasksStructWithListName) -> Bool in
                return (taskindatasource.tasklistInfo.identifier == tasklist.identifier)
            }
            if tasksForTasklist != nil {
                /*
                for tsks in tasksForTasklist! {
                    LogError.log("Adding to default tasklist:: \(tsks.taskInfo.title)")
                }
                LogError.log("COMPLETED")*/
                self.defaultTasksDataSource += tasksForTasklist!
                tasksForTasklist = nil
            }
        }
        
        /*
        LogError.log("count of nowTasksDataSource  \(nowTasksDataSource.count)")
        LogError.log("count of nextTasksDataSource  \(nowTasksDataSource.count)")
        LogError.log("count of laterTasksDataSource  \(nowTasksDataSource.count)") */


        
        // V.IMP update the default tasklist, this flag is used so that the offline tasks are visible.
        self.defaultTasklist = tasklist
        LogError.log("updated defaulttasklist to \(defaultTasklist?.title)")
        
        
        //V.IMP update the userdefault data source should be emptied as this is only for displaying purposes
        // and we have got all relevant tasks from the data sources
        self.userDefaultTasksDataSource = []
        
        /*
        LogError.log("updated values for userDefaultTasksDataSource are \(userDefaultTasksDataSource)")
        LogError.log("updated values for defaultTasksDataSource are \(defaultTasksDataSource)")
        */
        NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)
    }
    
    
    func removeSyncedTasksFromUserArrays(dataSource: String) {
        // Updates userDefaultTasksDataSource, userNowTasksDataSource, userNextTasksDataSource, userLaterTasksDataSource
        // Invoked only after a sucessfull download of all tasks.
        
        switch dataSource {
        case "default" :
            var temp = userDefaultTasksDataSource.filter({ (element: tasksStructWithListName) -> Bool in
                return (element.sync == false)
            })
            self.userDefaultTasksDataSource = temp
            
            
        case "nowNextLater" :
            var temp = userNowTasksDataSource.filter({ (element: tasksStructWithListName) -> Bool in
                return (element.sync == false)
            })
            self.userNowTasksDataSource = temp
            
            temp = userNextTasksDataSource.filter({ (element: tasksStructWithListName) -> Bool in
                return (element.sync == false)
            })
            self.userNextTasksDataSource = temp
            
            temp = userLaterTasksDataSource.filter({ (element: tasksStructWithListName) -> Bool in
                return (element.sync == false)
            })
            self.userLaterTasksDataSource = temp
            
        default:
            LogError.log("Unimplementd case while filtering user arrays")
            
        }
    }


    //For populating the Tasks Control
    func getALLTasksForALLTasklist() {
        var queryQueue = dispatch_queue_create("task.tasklist.gtask", DISPATCH_QUEUE_SERIAL)
        for tasklist in tasklistsArray {

            dispatch_sync(queryQueue, {()->Void in
            //Start of Main Block
                println("**Fetching Tasks in \(tasklist.title)")
                var query = GTLQueryTasks.queryForTasksListWithTasklist(tasklist.identifier) as GTLQueryTasks
                tasksService.executeQuery(query, completionHandler: {(ticket, tasksReturned, error)-> Void in
                    if error == nil {
                        let fetchedSetOfTasks = tasksReturned as GTLTasksTasks
                        println("Fetched Tasks in \(tasklist.title)")
                        
                        if tasklist.title == "poli heck" {
                            for tasks in fetchedSetOfTasks {
                                let tsk = tasks as GTLTasksTask
                                println("task####: \(tsk.title)")
                            }
                        }
                        
                        self.addTasksToDataSource(fetchedSetOfTasks, tasklist: tasklist)
                        self.removeSyncedTasksFromUserArrays("nowNextLater")
                        // ModelReady Notification here?
                        self.initSuccessAndDataSourcesValid = true
                    } else {
                        self.initSuccessAndDataSourcesValid = false
                        LogError.log("\(error)")
                        // No retry here for now as if this has to fail, it will be preceded by other failures which already has retries.
                    }
                }) //END of QUERY BLOCK
            }) //END of dispatch async
        } //END of For loop
    }
    
    
    func addNewTask(customTask: tasksStructWithListName) {
        //Update the task with the updated time. For local display rather than upload. Newly added tasks will show first
        customTask.taskInfo.updated = NSDate()
        
        // Add the task to the now, next and later data sources, so it can be preserved in case upload to google fails
        addtaskToDataSource(customTask)
        // Add the task to the userDefaultTasksDataSource, so that the default tasklist based VC will be able to display the task
        // as well as subsequent updates on the tasks, when the task is synced.
        addtaskToUserDefaultTasksDataSource(customTask)
        
        //Notification so the user view is updated.
        NSNotificationCenter.defaultCenter().postNotificationName("NEWTASK", object: nil)    //Not being used.
        
        //Prepare the task so it can be uploaded to Google
        var task = GTLTasksTask()
        task.title = customTask.taskInfo.title
        task.notes = customTask.taskInfo.notes
        task.due = GTLDateTime(date: customTask.taskInfo.duedate, timeZone: NSTimeZone())
        var tasklist = GTLTasksTaskList()
        tasklist.identifier = customTask.tasklistInfo.identifier
        tasklist.title = customTask.tasklistInfo.title
        addTaskToSpecifiedTasklist(tasklist, task: task, customTask: customTask)
        //addTaskToSpecifiedTasklist will also update the dataSources if the upload was sucessful
        //The data sources are updated two times, once before upload to google and once after upload to google if the upload was successful.
        
        //Another notification is upload is successful it will show. Initially I kept this in the success path for upload
        // But it remains buried somewhere deep if it lies there, so I brought it ahead to improve readibility. Only caveat is 
        // addTaskToSpecifiedTasklist is asynchronous and this is may get sent sooner than needed. So moving it back!
        // NSNotificationCenter.defaultCenter().postNotificationName("ModelReady", object: nil)

    }
    
    //can we make this provate?
    func checkTasksForSyncToGoogle() {
        println("Checking tasks to sync .... ****")
        for userArrays in [userNowTasksDataSource, userNextTasksDataSource, userLaterTasksDataSource] {
            for customTask in userArrays {
                if customTask.sync == false {
                    println("Found task: \(customTask.taskInfo.title)")
                    var task = GTLTasksTask()
                    task.title = customTask.taskInfo.title
                    task.notes = customTask.taskInfo.notes
                    task.status = customTask.taskInfo.status
                    //task.completed = customTask.taskInfo.completed
                    task.due = GTLDateTime(date: customTask.taskInfo.duedate, timeZone: NSTimeZone())
                    var tasklist = GTLTasksTaskList()
                    tasklist.identifier = customTask.tasklistInfo.identifier
                    addTaskToSpecifiedTasklist(tasklist, task: task, customTask: customTask)
                }
            }
        }
    }
    
    

    //For Delete Task Controller
    func deleteTaskFromSpecifiedTasklist(customTask: tasksStructWithListName) -> Bool {
        //This is not thread safe and empties the queue and filters, so think before moving it.
        deletetaskFromDataSources(customTask)
        
    
        if customTask.markfordeletion == false {
        //delete the task from google. Only tasks which are on google.
        
        println("Sending query for deleting task \(customTask.taskInfo.title)")
            
            
        var tasklist = customTask.tasklistInfo
        var task = customTask.taskInfo
        
        println("values are  \(tasklist.identifier) and \(task.identifier)")
    
        let query = GTLQueryTasks.queryForTasksDeleteWithTasklist(tasklist.identifier, task: task.identifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    LogError.log("Deleted Task: \(task.title)")
                } else
                {
                    LogError.log("Error deleting: \(error)")
                    self.addTaskBackToDataSources(customTask)
                    NSNotificationCenter.defaultCenter().postNotificationName("NOTIFYDELETEFAILED", object: nil)
                    self.ticket = nil
                }
            })
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("NOTIFYDELETEFAILED", object: nil)
            println("Error: Query Operation in Progress")
            return false
        }
        }
        return true
    }
    
    func syncModifiedTasksToGoogle() {
        for modifiedtask in modifiedTasksTobeSynced {
            // task which are outof sync are already in the add task queue
            if modifiedtask.sync == true {
                    modifyTaskForSpecifiedTasklist(modifiedtask)
            }
        }
    }
    
    func syncMovedTasksToGoogle() {
        for movedtask in movedTasksTobeSynced {
            // task which are outof sync (new tasks) are already in the add task queue
            if movedtask.sync == true {
                moveTaskToSpecifiedTasklist(movedtask)
            }
        }
    }

    
    func removeTaskFromModifiedTasksToBeSynced(modifiedtask: tasksStructWithListName) {
        
        
        var tempArray = modifiedTasksTobeSynced.filter { (tasksinarray) -> Bool in
            return (tasksinarray.taskInfo.identifier != modifiedtask.taskInfo.identifier)
        }
        modifiedTasksTobeSynced.removeAll(keepCapacity: false)
        modifiedTasksTobeSynced += tempArray
        println("After removing task \(modifiedtask.taskInfo.title) from modify queue, count is:  \(modifiedTasksTobeSynced.count)")

    }
    
    func removeTaskFromMovedTasksToBeSynced(movedtask: tasksStructWithListName) {
        
        println("Going to remove from queue, count is:  \(movedTasksTobeSynced.count)")
        
        var tempArray = movedTasksTobeSynced.filter { (tasksinarray) -> Bool in
            return (tasksinarray.taskInfo.identifier != movedtask.taskInfo.identifier)
        }
        movedTasksTobeSynced.removeAll(keepCapacity: false)
        movedTasksTobeSynced += tempArray
        println("Removing from queue, count is:  \(movedTasksTobeSynced.count)")
        
    }


    
    //For ModifyTask control, could also be invoked from task control
    func modifyTaskForSpecifiedTasklist(customTask : tasksStructWithListName) -> Bool {
       
        
        var tasklist = customTask.tasklistInfo
        var task = customTask.taskInfo
        var GTLtask = GTLTasksTask()
        GTLtask.identifier = task.identifier
        GTLtask.title = task.title
        GTLtask.status = task.status
        GTLtask.notes = task.notes
        GTLtask.due = GTLDateTime(date: task.duedate, timeZone: NSTimeZone())
        
        var query = GTLQueryTasks.queryForTasksUpdateWithObject(GTLtask, tasklist: tasklist.identifier, task: task.identifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    println("Sucessfully modified task, removing from queue")
                    self.removeTaskFromModifiedTasksToBeSynced(customTask)

                } else {
                    if customTask.retryupload != true {
                        customTask.retryupload = true
                        self.modifiedTasksTobeSynced.append(customTask)
                        println("error modifying task \(error), ADDED task to queue")
                    }
                    self.scheduleGoogleDownload("ModifiedTaskFailed", parameter: nil)
                    println("Queue count  \(self.modifiedTasksTobeSynced.count)")
                }
            })
        } else {
            if customTask.retryupload != true {
                customTask.retryupload = true
                self.modifiedTasksTobeSynced.append(customTask)
                println("ADDED task to queue")
            }
            self.scheduleGoogleDownload("ModifiedTaskFailed", parameter: nil)
            println("Queue count  \(self.modifiedTasksTobeSynced.count)")
            println("Error: Query Operation in Progress, added task to queue")
        }
        return true
    }
    
    
    func moveTask(customTask: tasksStructWithListName, newTasklist: tasklistStruct) {
        //Fix needed for offline mode
        deleteTaskFromSpecifiedTasklist(customTask)
        customTask.tasklistInfo = newTasklist
        addNewTask(customTask)
    }
    
    
    //For ModifyTask control, could also be invoked from task control
    func moveTaskToSpecifiedTasklist(customTask: tasksStructWithListName) -> Bool {
        
        //updated the tasklist info within the task
        
        let taskIdentifier: String = customTask.taskInfo.identifier
        let tasklistIdentifier = customTask.tasklistInfo.identifier
        
        var query = GTLQueryTasks.queryForTasksMoveWithTasklist(tasklistIdentifier, task: taskIdentifier) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, taskReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    println("Sucessfully moved task, removing from queue")
                    self.removeTaskFromMovedTasksToBeSynced(customTask)
                    //Now add the remaining items updated to the new tasklist
                    self.modifyTaskForSpecifiedTasklist(customTask)
                } else {
                    if customTask.retryMove != true {
                        customTask.retryMove = true
                        self.movedTasksTobeSynced.append(customTask)
                        println("error moving task \(error), ADDED task to queue")
                    }
                    self.scheduleGoogleDownload("MoveTaskFailed", parameter: nil)
                    println("Queue count  \(self.movedTasksTobeSynced.count)")

                }
            })
        } else {
            if customTask.retryMove != true {
                customTask.retryMove = true
                self.movedTasksTobeSynced.append(customTask)
                println("ADDED task to queue")
            }
            self.scheduleGoogleDownload("MoveTaskFailed", parameter: nil)
            println("Queue count  \(self.movedTasksTobeSynced.count)")
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
                    println("Delete tasklist failed with error :  \(error)")
                }
            })
        } else {
            println("Error: Query Operation in Progress")
        }
        return true
    }
    
    //For EditTasklist control, could also be invoked from task control
    func addSpecifiedTasklist(tasklistName: String) -> Bool {
        var tasklist = GTLTasksTaskList()
        tasklist.title = tasklistName
        LogError.log("adding \(tasklist.title)")
        var query = GTLQueryTasks.queryForTasklistsInsertWithObject(tasklist) as GTLQueryTasks
        if ticket == nil {
            ticket = tasksService.executeQuery(query, completionHandler: {(ticket, tasklistReturned, error)-> Void in
                self.ticket = nil
                if error == nil {
                    LogError.log("Added \(tasklist.title)")
                    var objreturned = tasklistReturned as GTLTasksTaskList
                    LogError.log("received \(objreturned.title) \n")
    
                    self.addTasklistToDataSource(objreturned)
                } else {
                    println("Tasklist add failed with error : \(error)")
                    NSNotificationCenter.defaultCenter().postNotificationName("NOTIFYTASKLISTADDFAILED", object: nil)
                }
            })
        } else {
            println("Error: Query Operation in Progress")
        }
        return true
    }
    
    func addTasklistToDataSource(newTasklist : GTLTasksTaskList) {
        var newTasklist = tasklistStruct(identifier: newTasklist.identifier!, title: newTasklist.title!)
        self.tasklistsArray.append(newTasklist)
        NSNotificationCenter.defaultCenter().postNotificationName("NOTIFYTASKLISTADD", object: nil)
    }
    
}
