//
//  GeneralTaskRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation

protocol GeneralTaskRepository {
    
    func getExistingDates() -> [Date]
    
    func getTaskById(id: UUID) -> GeneralTask?
    
    func getTasksByDate(date: Date) -> [GeneralTask]
    
    func createTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, deadlineDate: Date, specificTasks: NSSet?)
    
    func deleteTask(id: UUID)
    
    func updateTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, deadlineDate: Date, specificTasks: NSSet?)
}
