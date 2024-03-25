//
//  GeneralTaskRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation

protocol GeneralTaskRepository {
    
    func getTasksByDate(date: Date) -> [GeneralTaskRepository];
    
    func createTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, deadlineDate: Date, specificTasks: NSSet?);
    
    func deleteTask(id: UUID);
    
    func updateTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, deadlineDate: Date, specificTasks: NSSet?);
}
