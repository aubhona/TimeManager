//
//  SpecificTaskRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation

protocol SpecificTaskRepository {
    
    func getTaskByDateTime(date: Date) -> SpecificTask?
    
    func getTasksByDate(date: Date) -> [SpecificTask]
    
    func getTaskById(id: UUID) -> SpecificTask?
    
    func createTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, scheduledDate: Date?, generalTask: GeneralTask?)
    
    func updateTask(id: UUID, name: String, isCompleted: Bool, taskDescription: String, tags: NSSet, duration: Int64, scheduledDate: Date?, generalTask: GeneralTask?)
    
    func deleteTask(id: UUID)
    
    func getDelayedTasks() -> [SpecificTask]
}
