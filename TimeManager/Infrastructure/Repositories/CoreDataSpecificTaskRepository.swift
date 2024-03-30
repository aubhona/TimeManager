//
//  CoreDataSpecificTaskRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation
import UIKit
import CoreData

public final class CoreDataSpecificTaskRepository: SpecificTaskRepository {
    
    public static let shared = CoreDataSpecificTaskRepository()
    
    private init() { }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func getTaskById(id: UUID) -> SpecificTask? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SpecificTask")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request) as? [SpecificTask]
            return results?.first
        } catch let error as NSError {
            print("Error fetching task by ID: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func getTasksByDate(date: Date) -> [SpecificTask] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SpecificTask")
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = NSPredicate(format: "(scheduledDate >= %@) AND (scheduledDate < %@)", startDate as NSDate, endDate as NSDate)
        request.predicate = predicate
        
        do {
            guard let result = try context.fetch(request) as? [SpecificTask] else { return [] }
            return result
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    
    func createTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, scheduledDate: Date?, generalTask: GeneralTask?) {
        guard let taskEntityDescription = NSEntityDescription.entity(forEntityName: "SpecificTask", in: context) else { return }
        let task = SpecificTask(entity: taskEntityDescription, insertInto: context)
        task.id = id
        task.name = name
        task.isCompleted = isCompleted
        task.taskDescription = taskDescription
        task.tags = tags
        task.duration = duration
        task.scheduledDate = scheduledDate
        task.generalTask = generalTask
        
        appDelegate.saveContext()
    }
    
    func deleteTask(id: UUID) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SpecificTask")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request) as? [SpecificTask]
            if let taskToDelete = results?.first {
                context.delete(taskToDelete)
                
                try context.save()
            }
        } catch let error as NSError {
            print("Error deleting task: \(error), \(error.userInfo)")
        }
    }
    
    func updateTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, scheduledDate: Date?, generalTask: GeneralTask?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SpecificTask")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request) as? [SpecificTask]
            if let task = results?.first {
                
                task.name = name
                task.isCompleted = isCompleted
                task.taskDescription = taskDescription
                task.tags = tags
                task.duration = duration
                task.scheduledDate = scheduledDate
                task.generalTask = generalTask
                
                try context.save()
            }
        } catch {
            print("Error updating task: \(error)")
        }
    }
    
    func getDelayedTasks() -> [SpecificTask] {
        let fetchRequest: NSFetchRequest<SpecificTask> = SpecificTask.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "scheduledDate == nil")
        
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch {
            print("Error fetching delayed tasks: \(error)")
            return []
        }
    }
}
