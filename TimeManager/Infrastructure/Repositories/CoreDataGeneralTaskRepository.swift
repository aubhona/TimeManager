//
//  CoreDataGeneralTaskRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation
import UIKit
import CoreData

public final class CoreDataGeneralTaskRepository: GeneralTaskRepository {
    
    public static let shared = CoreDataGeneralTaskRepository()
    
    private init() { }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func getTasksByDate(date: Date) -> [GeneralTaskRepository] {
        return []
    }
    
    func createTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, deadlineDate: Date, specificTasks: NSSet?) {
        return
    }
    
    func deleteTask(id: UUID) {
        return
    }
    
    func updateTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, deadlineDate: Date, specificTasks: NSSet?) {
        return
    }
    
    
}
