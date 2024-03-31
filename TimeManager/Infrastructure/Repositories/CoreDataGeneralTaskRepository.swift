//
//  CoreDataGeneralTaskRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation
import UIKit
import CoreData

internal final class CoreDataGeneralTaskRepository: GeneralTaskRepository {
    
    public static let shared = CoreDataGeneralTaskRepository()
    
    private init() { }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public func getTasksByName(name: String) -> [GeneralTask] {
        let request: NSFetchRequest<GeneralTask> = GeneralTask.fetchRequest()
        request.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", name)
        
        do {
            let tasks = try context.fetch(request)
            return tasks
        } catch {
            print("Error fetching tasks by name: \(error)")
            return []
        }
    }
    
    
    public func getExistingDates() -> [Date] {
        var dates: [Date] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneralTask")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["deadlineDate"]
        fetchRequest.returnsDistinctResults = true
        
        do {
            if let results = try context.fetch(fetchRequest) as? [[String: Date]] {
                for result in results {
                    if let date = result["deadlineDate"] {
                        dates.append(date)
                    }
                }
            }
        } catch {
            print("Error fetching dates: \(error)")
        }
        
        return dates
    }
    
    public func getTaskById(id: UUID) -> GeneralTask? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneralTask")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request) as? [GeneralTask]
            return results?.first
        } catch let error as NSError {
            print("Error fetching task by ID: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    public func getTasksByDate(date: Date) -> [GeneralTask] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneralTask")
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = NSPredicate(format: "(deadlineDate >= %@) AND (deadlineDate < %@)", startDate as NSDate, endDate as NSDate)
        request.predicate = predicate
        
        do {
            guard let result = try context.fetch(request) as? [GeneralTask] else { return [] }
            return result
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    public func createTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, deadlineDate: Date, specificTasks: NSSet?) {
        guard let taskEntityDescription = NSEntityDescription.entity(forEntityName: "GeneralTask", in: context) else { return }
        let task = GeneralTask(entity: taskEntityDescription, insertInto: context)
        task.id = id
        task.name = name
        task.isCompleted = isCompleted
        task.taskDescription = taskDescription
        task.tags = tags
        task.deadlineDate = deadlineDate
        task.specificTasks = specificTasks
        
        appDelegate.saveContext()
    }
    
    public func deleteTask(id: UUID) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneralTask")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request) as? [GeneralTask]
            if let taskToDelete = results?.first {
                context.delete(taskToDelete)
                
                try context.save()
            }
        } catch let error as NSError {
            print("Error deleting task: \(error), \(error.userInfo)")
        }
    }
    
    public func toggleAllSpecificTasksComplete(for generalTask: GeneralTask) {
        guard let specificTasks = generalTask.specificTasks as? Set<SpecificTask> else { return }
        
        if (!generalTask.isCompleted) {
            return
        }
        
        specificTasks.forEach { specificTask in
            specificTask.isCompleted = true
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Cannot save specific task changes: \(error), \(error.userInfo)")
        }
    }
    
    public func updateTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, deadlineDate: Date, specificTasks: NSSet?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneralTask")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request) as? [GeneralTask]
            if let task = results?.first {
                
                task.id = id
                task.name = name
                task.isCompleted = isCompleted
                task.taskDescription = taskDescription
                task.tags = tags
                task.deadlineDate = deadlineDate
                task.specificTasks = specificTasks
                toggleAllSpecificTasksComplete(for: task)
                
                try context.save()
                
            }
        } catch {
            print("Error updating task: \(error)")
        }
    }
    
    public func deleteAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneralTask")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            print("Error in deleting SpecificTask data : \(error), \(error.userInfo)")
        }
    }
}
